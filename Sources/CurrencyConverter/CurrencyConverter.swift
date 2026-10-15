import Foundation

/// The converter to fetch foreign exchange reference rates.
public class CurrencyConverter {
    private let source: ReferenceRatesXMLParser.Source
    private let session: URLSession

    public init() {
        source = .url(ReferenceRatesXMLParser.defaultXMLURL)
        session = .shared
    }

    public init(data: Data) {
        source = .data(data)
        session = .shared
    }

    init(contentsOf url: URL, session: URLSession = .shared) {
        source = .url(url)
        self.session = session
    }

    /// Fetch the latest reference rates from the source.
    ///
    /// Network requests run asynchronously and call completion on the URL session's
    /// delegate queue. Data-backed instances call completion synchronously.
    public func fetch(completion: @escaping @Sendable (Result<ReferenceRates, XMLParserError>) -> Void) {
        switch source {
        case .url(let url) where url.isFileURL:
            Self.parse(ReferenceRatesXMLParser(contentsOf: url), completion: completion)
        case .url(let url):
            session.dataTask(with: url) { data, response, error in
                if let error {
                    completion(.failure(.general(error)))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    completion(.failure(.custom("Unexpected HTTP response")))
                    return
                }
                guard let data else {
                    completion(.failure(.custom("No reference rate data received")))
                    return
                }
                Self.parse(ReferenceRatesXMLParser(data: data), completion: completion)
            }.resume()
        case .data(let data):
            Self.parse(ReferenceRatesXMLParser(data: data), completion: completion)
        }
    }

    private static func parse(
        _ parser: ReferenceRatesXMLParser,
        completion: @escaping @Sendable (Result<ReferenceRates, XMLParserError>) -> Void
    ) {
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
