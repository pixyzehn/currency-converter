import Foundation

/// The converter to fetch foreign exchange reference rates from European Central Bank (ECB).
/// Source: https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html
public class CurrencyConverter {
    private let parser: ReferenceRatesXMLParser

    public init() {
        parser = ReferenceRatesXMLParser()
    }

    public init(data: Data) {
        parser = ReferenceRatesXMLParser(data: data)
    }

    /// Fetch the latest reference rates from the source.
    public func fetch(completion: @escaping (Result<ReferenceRates, XMLParserError>) -> Void) {
        parser.callbacks.parseSucceeded = { referenceRates in
            completion(.success(referenceRates))
        }
        parser.callbacks.parseErrorOccurred = { error in
            completion(.failure(error))
        }
        parser.parse()
    }

    /// Asynchronously fetch the latest reference rates from the source.
    public func fetch() async throws -> ReferenceRates {
        try await withCheckedThrowingContinuation { continuation in
            fetch { result in
                switch result {
                case .success(let referenceRates):
                    continuation.resume(returning: referenceRates)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
