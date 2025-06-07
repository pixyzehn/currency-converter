@testable import CurrencyConverter
import Testing
import Foundation

struct CurrencyConverterTests {
    @Test func converterFetch() async throws {
        let converter = CurrencyConverter()
        let referenceRates = try await converter.fetch()
        let date = referenceRates.date
        let now = Date()
        let dateFormatter = DateFormatter.yyyyMMddFormatter

        let today = dateFormatter.string(from: now)
        let oneDayAgo = dateFormatter.string(from: now.addingTimeInterval(-24 * 60 * 60 * 1))
        let twoDaysAgo = dateFormatter.string(from: now.addingTimeInterval(-24 * 60 * 60 * 2))
        let possibleDates = [today, oneDayAgo, twoDaysAgo]
        #expect(possibleDates.contains(date))

        let datePattern = #"^\d{4}[-]\d{2}[-]\d{2}$"# // 2021-05-07
        #expect(date.range(of: datePattern, options: .regularExpression) != nil)

        #expect(referenceRates.rates(baseCurrencyCode: "USD").count == referenceRates.rates(baseCurrencyCode: "JPY").count)
        #expect(referenceRates.rates(baseCurrencyCode: "XXX").count == 0)
    }

    @Test func referenceRatesRate() async throws {
        let converter = CurrencyConverter(data: testXMLData)
        let referenceRates = try await converter.fetch()
        #expect(referenceRates.rate(amount: 6, fromCurrencyCode: "EUR", toCurrencyCode: "JPY") == 131.76 * 6)
        #expect(referenceRates.rate(amount: 10, fromCurrencyCode: "USD", toCurrencyCode: "JPY") == 131.76 / 1.2059 * 10)
        #expect(referenceRates.rate(amount: 100, fromCurrencyCode: "BRL", toCurrencyCode: "NZD") == 1.6730 / 6.3801 * 100)
        #expect(referenceRates.rate(amount: 2, fromCurrencyCode: "USD", toCurrencyCode: "EUR") == 1 / 1.2059 * 2)
        #expect(referenceRates.rate(amount: 2, fromCurrencyCode: "USD", toCurrencyCode: "USD") == 2)
        #expect(referenceRates.rate(amount: 2, fromCurrencyCode: "USD", toCurrencyCode: "XXX") == nil)
        #expect(referenceRates.rate(amount: 2, fromCurrencyCode: "XXX", toCurrencyCode: "USD") == nil)
    }

    @Test func referenceRatesRates() async throws {
        let converter = CurrencyConverter(data: testXMLData)
        let referenceRates = try await converter.fetch()
        #expect(referenceRates.rates(amount: 1, baseCurrencyCode: "EUR").first(where: { $0.currencyCode == "USD" })?.rate == 1.2059)
        #expect(referenceRates.rates(amount: 1, baseCurrencyCode: "USD").first(where: { $0.currencyCode == "EUR" })?.rate == 1 / 1.2059)
        #expect(referenceRates.rates(amount: 1, baseCurrencyCode: "JPY").first(where: { $0.currencyCode == "USD" })?.rate == 1.2059 / 131.76)
        #expect(referenceRates.rates(amount: 1, baseCurrencyCode: "XXX") == [])
    }

    private let testXMLData = """
        <gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="https://expenses.cash/eurofxref">
        <gesmes:subject>Reference rates</gesmes:subject>
        <gesmes:Sender>
        <gesmes:name>Expenses</gesmes:name>
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
