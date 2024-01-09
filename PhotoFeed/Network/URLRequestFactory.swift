import Foundation

final class URLRequestFactory {

    private init() {}

    static let shared = URLRequestFactory()
    private let storage = OAuthToTokenStorage.shared

    // MARK: - HTTP Request
    func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURLString: String = AuthConfiguration.standard.defaultApiBaseURLString
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
