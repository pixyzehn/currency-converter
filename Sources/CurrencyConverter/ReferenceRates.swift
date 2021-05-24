import Foundation

/// Represents the reference rates that has the date code and rates.
public struct ReferenceRates: Codable, Hashable {
    private static let defaultCurrencyCode = "EUR"

    /// The date string, e.g. 2021-05-13.
    public let date: String
    var rates: [CurrencyRate]

    public init(date: String, rates: [CurrencyRate]) {
        self.date = date
        self.rates = rates
    }

    /// Returns array of currency rates from the given parameters.
    ///
    /// - Parameters:
    ///     - amount: The amount of the currency. The default is 1.
    ///     - baseCurrencyCode: The base currency code for the currency rates. The default is "EUR".
    public func rates(amount: Double = 1, baseCurrencyCode: String = "EUR") -> [CurrencyRate] {
        guard Locale.isoCurrencyCodes.contains(baseCurrencyCode) else {
            return []
        }

        if baseCurrencyCode == Self.defaultCurrencyCode {
            return rates
        } else {
            var newRates = rates.filter { $0.currencyCode != baseCurrencyCode }

            if let rate = rate(fromCurrencyCode: baseCurrencyCode, toCurrencyCode: Self.defaultCurrencyCode) {
                newRates.append(.init(currencyCode: Self.defaultCurrencyCode, rate: rate))
            }

            newRates = newRates.compactMap {
                if let rate = rate(fromCurrencyCode: baseCurrencyCode, toCurrencyCode: $0.currencyCode) {
                    return .init(currencyCode: $0.currencyCode, rate: amount * rate)
                }
                return nil
            }

            return newRates
        }
    }

    /// Returns the rate from the given parameters.
    ///
    /// - Parameters:
    ///     - amount: The amount of the currency. The default is 1.
    ///     - fromCurrencyCode: The currency code that you'd like to converted from.
    ///     - toCurrencyCode: The currency code that you'd like to converted to.
    public func rate(amount: Double = 1, fromCurrencyCode: String, toCurrencyCode: String) -> Double? {
        guard fromCurrencyCode != toCurrencyCode else {
            return amount
        }

        let isoCurrencyCodes = Locale.isoCurrencyCodes

        guard isoCurrencyCodes.contains(fromCurrencyCode) && isoCurrencyCodes.contains(toCurrencyCode) else {
            return nil
        }

        if let rate = rates.first(where: { $0.currencyCode == toCurrencyCode })?.rate, fromCurrencyCode == Self.defaultCurrencyCode {
            return amount * rate
        }

        if let rate = rates.first(where: { $0.currencyCode == fromCurrencyCode })?.rate, toCurrencyCode == Self.defaultCurrencyCode {
            return amount * 1 / rate
        }

        if  let fromRate = rates.first(where: { $0.currencyCode == fromCurrencyCode })?.rate,
            let toRate = rates.first(where: { $0.currencyCode == toCurrencyCode })?.rate {
            let actualRate = toRate / fromRate
            return amount * actualRate
        }

        return nil
    }
}
