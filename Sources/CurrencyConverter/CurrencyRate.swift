import Foundation

/// Represents the currency rate that has the currency code and rate.
public struct CurrencyRate: Codable, Hashable {
    /// The currency code, such as "USD", "EUR", and "JPY".
    public let currencyCode: String
    /// The currency rate in the currency code.
    public let rate: Double

    public init(currencyCode: String, rate: Double) {
        self.currencyCode = currencyCode
        self.rate = rate
    }
}
