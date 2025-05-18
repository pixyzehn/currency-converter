import Foundation

/// The converter to fetch foreign exchange reference rates.
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
        let safe = SafeCallback()
        parser.callbacks.parseSucceeded = { referenceRates in
            safe.call {
                completion(.success(referenceRates))
            }
        }
        parser.callbacks.parseErrorOccurred = { error in
            safe.call {
                completion(.failure(error))
            }
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
