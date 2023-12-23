import Foundation

final class URLRequestFactory {

    static let shared = URLRequestFactory()

    private let storage: OAuthToTokenStorage

    init(storage: OAuthToTokenStorage = .shared) {
        self.storage = storage
    }

    func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURLString: String = Constants.defaultBaseUrl
    ) -> URLRequest? {
        guard
            let url = URL(string: baseURLString),
            let baseURL = URL(string: path, relativeTo: url)
        else { return nil }

        var request = URLRequest(url: baseURL)
        request.httpMethod = httpMethod

        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

extension URLSession {

    func objectTask<DecodingType: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<DecodingType, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError(error)))
                }
            }

            if let response = response as? HTTPURLResponse {
                if !(200..<300 ~= response.statusCode) {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                    }
                }
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(DecodingType.self, from: data)

                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(ParseError.decodeError(error)))
                    }
                }
            }
        }
        return task
    }
}

extension Array {
    func withReplaced(itemAt: Int, newValue: Photo) -> [Photo] {
        var photos = ImagesListService.shared.photos
        photos.replaceSubrange(itemAt...itemAt, with: [newValue])
        return photos
    }
}
