import Foundation

/// The converter to fetch foreign exchange reference rates.
public class CurrencyConverter {
    private let source: ReferenceRatesXMLParser.Source

    public init() {
        source = .url(ReferenceRatesXMLParser.defaultXMLURL)
    }

    public init(data: Data) {
        source = .data(data)
    }

    init(contentsOf url: URL) {
        source = .url(url)
    }

    /// Fetch the latest reference rates from the source.
    public func fetch(completion: @escaping (Result<ReferenceRates, XMLParserError>) -> Void) {
        let parser: ReferenceRatesXMLParser
        switch source {
        case .url(let url):
            parser = ReferenceRatesXMLParser(contentsOf: url)
        case .data(let data):
            parser = ReferenceRatesXMLParser(data: data)
        }
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
