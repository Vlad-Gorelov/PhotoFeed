import UIKit

final class ProfileService {

    private var task: URLSessionTask?
    private var urlSession = URLSession.shared
    var profile: ProfileResult?
    private let urlRequestFactory: URLRequestFactory
    static let shared = ProfileService()

    init(urlRequestFactory: URLRequestFactory = .shared) {
        self.urlRequestFactory = urlRequestFactory
    }

    func fetchProfile(completion: @escaping (Result<ProfileResult, Error>) -> Void) {

        assert(Thread.isMainThread)

        task?.cancel()

        guard let request = urlRequestFactory.makeHTTPRequest(path: "/me", httpMethod: "GET") else {
            assertionFailure("Failed to make HTTP request")
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let profileResult):
                self.profile = profileResult
                completion(.success(profileResult))

            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
