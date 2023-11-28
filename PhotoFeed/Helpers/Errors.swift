import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError(Error)
}

enum ParseError: Error {
    case decodeError(Error)
}
