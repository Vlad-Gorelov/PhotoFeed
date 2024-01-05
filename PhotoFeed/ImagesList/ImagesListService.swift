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
    let dateFormater = ISO8601DateFormatter()

    init(urlRequestFactory: URLRequestFactory = .shared) {
        self.urlRequestFactory = urlRequestFactory
    }

    func fetchPhotoNextPage() {
        guard task == nil else { return }

        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        guard let request = photosRequest(page: nextPage, perPage: 10) else {
            assertionFailure("\(NetworkError.invalidRequest)")
            return
        }
        self.task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let photoResults):
                for photoResult in photoResults {
                    self.photos.append(self.decodedResult(photoResult))
                }

                self.lastLoadedPage = nextPage
                self.task = nil
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
            case .failure(let error):
                if error is NetworkError {
                }
                self.handleNetworkError(error)
            }
        }
        self.task?.resume()
    }

    private func handleNetworkError(_ error: Error) {
        switch error {
        case let networkError as NetworkError:
            switch networkError {
            case .httpStatusCode(let statusCode):
                print("HTTP Status Code: \(statusCode)")
            case .urlRequestError(let requestError):
                print("URL Request Error: \(requestError.localizedDescription)")
            case .urlSessionError:
                print("URL Session Error")
            case .invalidRequest:
                print("Invalid Request")
            }
        default:
            print("Unexpected Error: \(error.localizedDescription)")
        }
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) { //
        assert(Thread.isMainThread)
        guard task == nil else { return }
        guard let token = storageToken.token else { return }
        guard let request = likeRequest(token,
                                        photoId: photoId,
                                        httpMethod: isLike ? "DELETE" : "POST"
        ) else {
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.task = nil

                switch result {
                case .success(let photoResult):
                    if let index = self.photos.firstIndex(where: { $0.id == photoResult.photo?.id }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(id: photo.id,
                                             size: photo.size,
                                             createdAt: photo.createdAt,
                                             description: photo.description,
                                             thumbImageURL: photo.thumbImageURL,
                                             fullImageURL: photo.fullImageURL,
                                             isLiked: !photo.isLiked)
                        self.photos = self.photos.replacingElement(itemAt: index, newValue: newPhoto)
                    }
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func likeRequest(_ token: String,
                             photoId: String,
                             httpMethod: String) -> URLRequest? {
        let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like")!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func decodedResult(_ photoResult: PhotoResult) -> Photo {
        return Photo.init(id: photoResult.id,
                          size: CGSize(width: photoResult.width ?? 0, height: photoResult.height ?? 0),
                          createdAt: dateFormater.date(from: photoResult.createdAt ?? ""),
                          description: photoResult.description,
                          thumbImageURL: photoResult.urls?.thumb,
                          fullImageURL: photoResult.urls?.full,
                          isLiked: photoResult.likedByUser ?? false)
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

    func clean() {
        task = nil
        photos = []
        lastLoadedPage = nil
    }
    
}
