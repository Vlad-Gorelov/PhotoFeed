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

    func fetchProfileImageURL(
        username: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = profileImageRequest(username: username) else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userPhoto):
                guard let profileImageURL = userPhoto.profileImage?.large else { return }
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: nil
                )
                self.task = nil

            case .failure(let error):
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }
}

extension ProfileImageService {

    private func profileImageRequest(username: String) -> URLRequest? {
        urlRequestFactory.makeHTTPRequest(
            path: "/users/\(username)",
            httpMethod: "GET"
        )
    }

    func clean() {
        avatarURL = nil
        task = nil
    }
}
