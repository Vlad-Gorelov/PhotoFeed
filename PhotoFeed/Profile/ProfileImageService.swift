import UIKit

final class ProfileImageService {

    private struct UserResult: Decodable {
       let profileImage: ProfileImage
    }

    private struct ProfileImage: Decodable {
           let small: String
       }

    private enum NetworkError: Error {
            case httpStatusCode(Int)
            case urlRequestError(Error)
            case urlSessionError(Error)
        }

    private enum ParseError: Error {
           case decodeError(Error)
       }

    private var task: URLSessionTask?
    private(set) var avatarURL: String?

    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()

// add fetchImage
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {

        guard var request = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET"),
              let token = OAuthToTokenStorage.shared.token else {
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
                    let user = try decoder.decode(UserResult.self, from: data)
                    print(user.profileImage.small)

                    DispatchQueue.main.async {
                        completion(.success(user.profileImage.small))
                        NotificationCenter.default.post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["URL": user.profileImage.small]
                        )
                        self.avatarURL = user.profileImage.small
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(ParseError.decodeError(error)))
                    }
                }
            }
        }
        task.resume()
    }
// end fetchImage
}

