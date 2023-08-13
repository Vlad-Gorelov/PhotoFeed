import UIKit

final class ProfileService {

    private struct ProfileResult: Decodable {
        let username: String
        let firstName: String
        let lastName: String
        let bio: String
    }

    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String
    }

    enum NetworkError: Error {
        case httpStatusCode(Int)
        case urlRequestError(Error)
        case urlSessionError(Error)
    }

    private enum ParseError: Error {
        case decodeError(Error)
    }

    private var task: URLSessionTask?
    private(set) var profile: Profile?

    static let shared = ProfileService()

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {

        assert(Thread.isMainThread)

        task?.cancel()

        guard var request = URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET") else {
            assertionFailure("Failed to make HTTP request")
            return
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError(error)))
                }
            }

            if let response = response as? HTTPURLResponse {
                assert(response.statusCode != 401, "Failed with bearer token")

                if response.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                    }
                }
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let profileResult = try decoder.decode(ProfileResult.self, from: data)

                    let profile = Profile(
                        username: profileResult.username,
                        name: "\(profileResult.firstName) \(profileResult.lastName)",
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio
                        )
                    DispatchQueue.main.async {
                        completion(.success(profile))
                        self.profile = profile
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(ParseError.decodeError(error)))
                    }
                }
            }
        }
        self.task = task
        task.resume()
    }
}
