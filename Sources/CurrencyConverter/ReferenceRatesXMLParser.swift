import Foundation

class ReferenceRatesXMLParser: NSObject, XMLParserDelegate {
    private static let defaultXMLURL = URL(string: "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")!

    private let parser: XMLParser?

    private var resultDate: String?
    private var resultRates: [CurrencyRate] = []
    var callbacks = Callbacks()

    struct Callbacks {
        var parseSucceeded: ((ReferenceRates) -> Void)?
        var parseErrorOccurred: ((XMLParserError) -> Void)?
    }

    enum XMLParserKeys: String {
        case time
        case currency
        case rate
    }

    init(contentsOf url: URL = defaultXMLURL) {
        parser = XMLParser(contentsOf: url)
        super.init()
        parser?.delegate = self
    }

    init(data: Data) {
        parser = XMLParser(data: data)
        super.init()
        parser?.delegate = self
    }

    func parse() {
        parser?.parse()
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        guard elementName == "Cube", !attributeDict.isEmpty else {
            // Skip throwing an error as there will be element names to ignore,
            // such as 'gesmes:Envelope', 'gesmes:subject', and so on.
            return
        }

        var currencyRate: (currencyCode: String?, rate: Double?)

        for attribute in attributeDict {
            switch attribute.key {
            case XMLParserKeys.time.rawValue:
                let datePattern = #"^\d{4}[-]\d{2}[-]\d{2}$"# // 2021-05-07
                if attribute.value.range(of: datePattern, options: .regularExpression) != nil {
                    resultDate = attribute.value
                } else {
                    callbacks.parseErrorOccurred?(.custom("Unexpected time value: \(attribute.value)"))
                    return
                }
            case XMLParserKeys.rate.rawValue:
                if let rate = Double(attribute.value) {
                    currencyRate.rate = rate
                } else {
                    callbacks.parseErrorOccurred?(.custom("Unexpected rate value: \(attribute.value)"))
                    return
                }
            case XMLParserKeys.currency.rawValue:
                if Locale.isoCurrencyCodes.contains(attribute.value) {
                    currencyRate.currencyCode = attribute.value
                } else {
                    callbacks.parseErrorOccurred?(.custom("Unexpected currency value: \(attribute.value)"))
                    return
                }
            default:
                break
            }
        }

        if let currencyCode = currencyRate.currencyCode, let rate = currencyRate.rate {
            resultRates.append(.init(currencyCode: currencyCode, rate: rate))
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        if let resultDate = resultDate {
            callbacks.parseSucceeded?(.init(date: resultDate, rates: resultRates))
        } else {
            callbacks.parseErrorOccurred?(.custom("Parse failed"))
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        callbacks.parseErrorOccurred?(.general(parseError))
    }
}
