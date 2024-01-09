import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? { get set }
    var imagesListService: ImagesListService { get }
    var photos: [Photo] { get set }
    
    func viewDidLoad()
    func updateTableViewAnimation()
}

final class ImagesListPresenter: ImagesListViewPresenterProtocol {
    
    var photos: [Photo] = []
    weak var view: ImageListViewControllerProtocol?
    let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        observeImagesList()
    }
    
    // MARK: - Observing Image List Changes
    
    func observeImagesList() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            updateTableViewAnimation()
        }
        imagesListService.fetchPhotoNextPage()
    }
    
    func updateTableViewAnimation() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
}
