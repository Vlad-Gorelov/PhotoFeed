import UIKit

final class ProfileImageService {

    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    private let urlSession = URLSession.shared
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private let urlRequestFactory: URLRequestFactory

    init(urlRequestFactory: URLRequestFactory = .shared) {
        self.urlRequestFactory = urlRequestFactory
    }

    // add fetchImage
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {

        guard var request = urlRequestFactory.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET"),
              let token = OAuthToTokenStorage.shared.token else {
            assertionFailure("Failed to make HTTP request")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in

            guard let self = self else { return }

            switch result {
            case .success(let user):
                completion(.success(user.profileImage.medium))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": user.profileImage.medium]
                )
                self.avatarURL = user.profileImage.medium
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

extension ProfileImageService {
    func clean() {
        avatarURL = nil
        task = nil
    }
}
