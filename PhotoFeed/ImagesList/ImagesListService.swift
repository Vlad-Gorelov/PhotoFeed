import Foundation

final class ImagesListService {

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()

    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let storageToken = OAuthToTokenStorage()
    private let urlRequestFactory: URLRequestFactory

    init(urlRequestFactory: URLRequestFactory = .shared) {
        self.urlRequestFactory = urlRequestFactory
    }

    func fetchPhotoNextPage() {
        task?.cancel()
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        guard let request = photosRequest(page: nextPage, perPage: 10) else {
            assertionFailure("\(NetworkError.invalidRequest)")
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let bodies):
                let newPhotos = bodies.map { Photo(decoded: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                self.task = nil
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
            case .failure(let error):
                assertionFailure(error.localizedDescription)
            }
        }
        self.task = task
        task.resume()
    }
}

extension ImagesListService {
    private func photosRequest(page: Int, perPage: Int) -> URLRequest? {
        urlRequestFactory.makeHTTPRequest(path: ("/photos?"
                                                 + "page=\(page)"
                                                 + "&&per_page=\(perPage)"),
                                          httpMethod: "GET"
        )
    }
}

