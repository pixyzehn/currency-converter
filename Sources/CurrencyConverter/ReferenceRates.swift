import Foundation

/// Represents the reference rates that has the date code and rates.
public struct ReferenceRates: Codable, Hashable, Sendable {
    private static let defaultCurrencyCode = "EUR"

    /// The date string, e.g. 2021-05-13.
    public let date: String
    var rates: [CurrencyRate]

    public init(date: String, rates: [CurrencyRate]) {
        self.date = date
        self.rates = rates
    }

    /// Returns array of currency rates from the given parameters.
    /// Invalid rates and nonfinite results are omitted; nonfinite amounts return an empty array.
    ///
    /// - Parameters:
    ///     - amount: The amount of the currency. The default is 1.
    ///     - baseCurrencyCode: The base currency code for the currency rates. The default is "EUR".
    public func rates(amount: Double = 1, baseCurrencyCode: String = "EUR") -> [CurrencyRate] {
        guard amount.isFinite,
              CurrencyCodeValidator.isValidCurrencyCode(baseCurrencyCode) else {
            return []
        }

        if baseCurrencyCode == Self.defaultCurrencyCode {
            return rates.compactMap { entry in
                guard CurrencyCodeValidator.isValidCurrencyCode(entry.currencyCode),
                      entry.rate.isFinite, entry.rate > 0 else {
                    return nil
                }
                let converted = amount * entry.rate
                guard converted.isFinite else { return nil }
                return CurrencyRate(currencyCode: entry.currencyCode, rate: converted)
            }
        }
        var currencyCodes = rates.map(\.currencyCode).filter { $0 != baseCurrencyCode }
        currencyCodes.append(Self.defaultCurrencyCode)
        return currencyCodes.compactMap { currencyCode in
            guard let converted = rate(
                amount: amount,
                fromCurrencyCode: baseCurrencyCode,
                toCurrencyCode: currencyCode
            ) else {
                return nil
            }
            return CurrencyRate(currencyCode: currencyCode, rate: converted)
        }
    }

    /// Returns the rate from the given parameters.
    /// Returns nil for nonfinite amounts, invalid rates, or nonfinite results.
    ///
    /// - Parameters:
    ///     - amount: The amount of the currency. The default is 1.
    ///     - fromCurrencyCode: The currency code that you'd like to converted from.
    ///     - toCurrencyCode: The currency code that you'd like to converted to.
    public func rate(amount: Double = 1, fromCurrencyCode: String, toCurrencyCode: String) -> Double? {
        guard amount.isFinite,
              CurrencyCodeValidator.isValidCurrencyCode(fromCurrencyCode),
              CurrencyCodeValidator.isValidCurrencyCode(toCurrencyCode) else {
            return nil
        }

        guard fromCurrencyCode != toCurrencyCode else {
            return amount
        }

        guard let fromRate = referenceRate(for: fromCurrencyCode),
              let toRate = referenceRate(for: toCurrencyCode) else {
            return nil
        }
        let converted = amount * (toRate / fromRate)
        return converted.isFinite ? converted : nil
    }

    private func referenceRate(for currencyCode: String) -> Double? {
        if currencyCode == Self.defaultCurrencyCode {
            return 1
        }
        guard let rate = rates.first(where: { $0.currencyCode == currencyCode })?.rate,
              rate.isFinite, rate > 0 else {
            return nil
        }
        return rate
    }
}
