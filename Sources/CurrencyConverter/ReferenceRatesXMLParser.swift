import Foundation

class ReferenceRatesXMLParser: NSObject, XMLParserDelegate {
    private static let defaultXMLURL = URL(string: "https://expenses.cash/eurofxref/eurofxref.xml")!

    private let source: Source

    private let resultRatesQueue = DispatchQueue(label: "ReferenceRatesXMLParser.resultRatesQueue")
    private var _resultRates: [CurrencyRate] = []
    private var resultDate: String?
    private var callbackGuard = SafeCallback()

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

    enum Source {
        case url(URL)
        case data(Data)
    }

    private func appendRate(_ rate: CurrencyRate) {
        resultRatesQueue.sync {
            _resultRates.append(rate)
        }
    }

    private var resultRates: [CurrencyRate] {
        resultRatesQueue.sync { _resultRates }
    }

    init(contentsOf url: URL = defaultXMLURL) {
        source = .url(url)
        super.init()
    }

    init(data: Data) {
        source = .data(data)
        super.init()
    }

    func parse() {
        resetParseState()
        callbackGuard = SafeCallback()
        let parser: XMLParser?
        switch source {
        case .url(let url):
            parser = XMLParser(contentsOf: url)
        case .data(let data):
            parser = XMLParser(data: data)
        }
        guard let parser else {
            callbackGuard.call {
                callbacks.parseErrorOccurred?(.custom("Failed to initialize XMLParser"))
            }
            return
        }
        parser.delegate = self
        let succeeded = parser.parse()
        if !succeeded {
            if let error = parser.parserError {
                callbackGuard.call {
                    callbacks.parseErrorOccurred?(.general(error))
                }
            } else {
                callbackGuard.call {
                    callbacks.parseErrorOccurred?(.custom("Parse failed"))
                }
            }
        }
    }

    private func resetParseState() {
        resultRatesQueue.sync {
            _resultRates.removeAll(keepingCapacity: true)
        }
        resultDate = nil
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
            appendRate(.init(currencyCode: currencyCode, rate: rate))
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        if let resultDate = resultDate {
            callbackGuard.call {
                callbacks.parseSucceeded?(.init(date: resultDate, rates: resultRates))
            }
        } else {
            callbackGuard.call {
                callbacks.parseErrorOccurred?(.custom("Parse failed"))
            }
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        callbackGuard.call {
            callbacks.parseErrorOccurred?(.general(parseError))
        }
    }
}
