import UIKit
import Kingfisher

final class ProfileService {

    static let shared = ProfileService()
    private var urlSession = URLSession.shared
    private var task: URLSessionTask?

    private (set) var profile: Profile?
    private let urlRequestFactory = URLRequestFactory.shared

    private init() {}

    func fetchProfile(
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {

        task?.cancel()

        guard let request = profileRequest() else {
            assertionFailure("Invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let profile = Profile(result: body)
                self.profile = profile
                completion(.success(profile))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}

extension ProfileService {
    private func profileRequest() -> URLRequest? {
        urlRequestFactory.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET"
        )
    }

    func clean() {
        profile = nil
        task = nil
    }
}
