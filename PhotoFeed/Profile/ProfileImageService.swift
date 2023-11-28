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

    private let urlSession = URLSession.shared 

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

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in

            guard let self = self else { return }

            switch result {
            case .success(let user):
                completion(.success(user.profileImage.small))
                NotificationCenter.default.post(
                    name: ProfileImageService.DidChangeNotification,
                    object: self,
                    userInfo: ["URL": user.profileImage.small]
                )
                self.avatarURL = user.profileImage.small
                self.task = nil

            case .failure(let error):
                self.task = nil
                completion(.failure(error))

            }
        }
        self.task = task
        task.resume()
    }
// end fetchImage
}

