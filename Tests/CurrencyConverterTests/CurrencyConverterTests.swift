@testable import CurrencyConverter
import XCTest

final class CurrencyConverterTests: XCTestCase {
    func testConverterFetch() {
        let converter = CurrencyConverter()
        converter.fetch { result in
            switch result {
            case let .success(referenceRates):
                // The reference rates are usually updated around 16:00 CET on every working day, except on TARGET closing days.
                // Working hours: Monday to Friday: 8:30 to 17:30 CET. Saturday, Sunday, and public holidays: closed
                // More info: https://www.ecb.europa.eu/home/contacts/working-hours/html/index.en.html
                let date = referenceRates.date
                // Given the Christmas holidays, the referenceRates should be updated within 4 days (3 [the Christmas holidays] + 1 [buffer for Timezone differences]).
                // Otherwise, we see it as an exceptional error.
                let now = Date()
                let dateFormatter = DateFormatter.yyyyMMddFormatter

                let today = dateFormatter.string(from: now)
                let oneDayAgo = dateFormatter.string(from: now.addingTimeInterval(-24 * 60 * 60 * 1))
                let twoDaysAgo = dateFormatter.string(from: now.addingTimeInterval(-24 * 60 * 60 * 2))
                let threeDaysAgo = dateFormatter.string(from: now.addingTimeInterval(-24 * 60 * 60 * 3))
                let fourDaysAgo = dateFormatter.string(from: now.addingTimeInterval(-24 * 60 * 60 * 4))
                let possibleDates = [today, oneDayAgo, twoDaysAgo, threeDaysAgo, fourDaysAgo]
                XCTAssertTrue(possibleDates.contains(date))

                let datePattern = #"^\d{4}[-]\d{2}[-]\d{2}$"# // 2021-05-07
                XCTAssertNotNil(date.range(of: datePattern, options: .regularExpression))

                // Currently, the supported currency codes are 32. The number can be updated if the source is changed.
                // ref: https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html
                XCTAssertEqual(referenceRates.rates().count, 32)
                XCTAssertEqual(referenceRates.rates(baseCurrencyCode: "USD").count, 32)
                XCTAssertEqual(referenceRates.rates(baseCurrencyCode: "JPY").count, 32)
                XCTAssertEqual(referenceRates.rates(baseCurrencyCode: "XXX").count, 0)
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
    }

    func testReferenceRatesRate() {
        let converter = CurrencyConverter(data: testXMLData)
        converter.fetch { result in
            switch result {
            case let .success(referenceRates):
                XCTAssertEqual(referenceRates.rate(amount: 6, fromCurrencyCode: "EUR", toCurrencyCode: "JPY"), 131.76 * 6)
                XCTAssertEqual(referenceRates.rate(amount: 10, fromCurrencyCode: "USD", toCurrencyCode: "JPY"), 131.76 / 1.2059 * 10)
                XCTAssertEqual(referenceRates.rate(amount: 100, fromCurrencyCode: "BRL", toCurrencyCode: "NZD"), 1.6730 / 6.3801 * 100)
                XCTAssertEqual(referenceRates.rate(amount: 2, fromCurrencyCode: "USD", toCurrencyCode: "EUR"), 1 / 1.2059 * 2)
                XCTAssertEqual(referenceRates.rate(amount: 2, fromCurrencyCode: "USD", toCurrencyCode: "USD"), 2)
                XCTAssertEqual(referenceRates.rate(amount: 2, fromCurrencyCode: "USD", toCurrencyCode: "XXX"), nil)
                XCTAssertEqual(referenceRates.rate(amount: 2, fromCurrencyCode: "XXX", toCurrencyCode: "USD"), nil)
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
    }

    func testReferenceRatesRates() {
        let converter = CurrencyConverter(data: testXMLData)
        converter.fetch { result in
            switch result {
            case let .success(referenceRates):
                XCTAssertEqual(referenceRates.rates(amount: 1, baseCurrencyCode: "EUR").first(where: { $0.currencyCode == "USD" })?.rate, 1.2059)
                XCTAssertEqual(referenceRates.rates(amount: 1, baseCurrencyCode: "USD").first(where: { $0.currencyCode == "EUR" })?.rate, 1 / 1.2059)
                XCTAssertEqual(referenceRates.rates(amount: 1, baseCurrencyCode: "JPY").first(where: { $0.currencyCode == "USD" })?.rate, 1.2059 / 131.76)
                XCTAssertEqual(referenceRates.rates(amount: 1, baseCurrencyCode: "XXX"), [])
            case let .failure(error):
                fatalError(error.localizedDescription)
            }
        }
    }

    private let testXMLData = """
        <gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref">
        <gesmes:subject>Reference rates</gesmes:subject>
        <gesmes:Sender>
        <gesmes:name>European Central Bank</gesmes:name>
        </gesmes:Sender>
        <Cube>
        <Cube time="2021-05-07">
        <Cube currency="USD" rate="1.2059"/>
        <Cube currency="JPY" rate="131.76"/>
        <Cube currency="BGN" rate="1.9558"/>
        <Cube currency="CZK" rate="25.682"/>
        <Cube currency="DKK" rate="7.4361"/>
        <Cube currency="GBP" rate="0.86810"/>
        <Cube currency="HUF" rate="358.01"/>
        <Cube currency="PLN" rate="4.5754"/>
        <Cube currency="RON" rate="4.9265"/>
        <Cube currency="SEK" rate="10.1263"/>
        <Cube currency="CHF" rate="1.0963"/>
        <Cube currency="ISK" rate="150.50"/>
        <Cube currency="NOK" rate="10.0125"/>
        <Cube currency="HRK" rate="7.5345"/>
        <Cube currency="RUB" rate="89.4671"/>
        <Cube currency="TRY" rate="10.0019"/>
        <Cube currency="AUD" rate="1.5523"/>
        <Cube currency="BRL" rate="6.3801"/>
        <Cube currency="CAD" rate="1.4689"/>
        <Cube currency="CNY" rate="7.7809"/>
        <Cube currency="HKD" rate="9.3661"/>
        <Cube currency="IDR" rate="17208.37"/>
        <Cube currency="ILS" rate="3.9438"/>
        <Cube currency="INR" rate="88.6375"/>
        <Cube currency="KRW" rate="1350.52"/>
        <Cube currency="MXN" rate="24.2006"/>
        <Cube currency="MYR" rate="4.9587"/>
        <Cube currency="NZD" rate="1.6730"/>
        <Cube currency="PHP" rate="57.747"/>
        <Cube currency="SGD" rate="1.6061"/>
        <Cube currency="THB" rate="37.588"/>
        <Cube currency="ZAR" rate="17.1863"/>
        </Cube>
        </Cube>
        </gesmes:Envelope>
        """.data(using: .utf8)!
}

private extension DateFormatter {
    // E.g. 2022-01-01
    static var yyyyMMddFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
