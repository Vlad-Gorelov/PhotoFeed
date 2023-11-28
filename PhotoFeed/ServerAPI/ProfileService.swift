import UIKit

final class ProfileService {

    private struct ProfileResult: Decodable {
        let username: String
        let firstName: String
        let lastName: String
        let bio: String?
    }

    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
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
    private var urlSession = URLSession.shared
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

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.firstName) \(profileResult.lastName)",
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                    )
                completion(.success(profile))
                self.profile = profile
                self.task = nil

            case .failure(let error):
                self.task = nil
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}
