import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError(Error)
    case invalidRequest(Error)
}

enum ParseError: Error {
    case decodeError(Error)
}
