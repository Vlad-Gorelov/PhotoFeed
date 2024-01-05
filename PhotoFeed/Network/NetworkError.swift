import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
}

/* enum ParseError: Error {
    case decodeError(Error)
}
*/
