import Foundation

public enum XMLParserError: Error {
    case general(Error)
    case custom(String)
}
