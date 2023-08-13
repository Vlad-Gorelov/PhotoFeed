import Foundation

final class OAuthToService {

    struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
    }

    enum NetworkError: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError(Error)
    }

    enum ParseError: Error {
        case decodeError(Error)
    }

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String? 


    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        if lastCode == code { return }
        task?.cancel()
        lastCode = code

        guard let request = makeRequest(with: code) else {
            assertionFailure("Failed to make request")
            return
        }

        let task = urlSession.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError(error)))
                    self.lastCode = nil
                }
                return
            }

            if let response = response as? HTTPURLResponse {
                if response.statusCode < 200 || response.statusCode >= 300 {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                        self.lastCode = nil
                    }
                    return
                }
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(responseBody.accessToken))
                        self.task = nil
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(ParseError.decodeError(error)))
                        self.task = nil
                    }
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func makeRequest(with code: String) -> URLRequest? {

        guard var urlComponents = URLComponents(string: accessTokenURL) else {
            assertionFailure("Failed to make URL Components from \(accessTokenURL)")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = urlComponents.url else {
            assertionFailure("Failed to make URL from \(urlComponents)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return request
    }
}
