import Foundation

enum CurrencyCodeValidator {
    private static let unsupportedCurrencyCodes: Set<String> = [
        "XTS",
        "XXX",
    ]

    static func isValidCurrencyCode(_ currencyCode: String) -> Bool {
        guard isoCurrencyCodes.contains(currencyCode) else {
            return false
        }

        return !unsupportedCurrencyCodes.contains(currencyCode)
    }

    private static let isoCurrencyCodes: Set<String> = {
        if #available(iOS 16, macOS 13, *) {
            return Set(Locale.Currency.isoCurrencies.map(\.identifier))
        } else {
            return Set(Locale.isoCurrencyCodes)
        }
    }()
}
