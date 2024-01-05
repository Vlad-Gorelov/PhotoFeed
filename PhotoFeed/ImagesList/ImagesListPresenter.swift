import UIKit

protocol ImagesListViewPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? { get set }
    var imagesListService: ImagesListService { get }
    var photos: [Photo] { get set }

    func viewDidLoad()
    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath)
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


    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(
            photoId: photo.id,
            isLike: photo.isLiked) { result in
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(entryValue: self.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    //TODO: Show Alert
    #warning("Show Alert something gone wrong")
                    //self.showAlertLikes()
                }
            }
    }

    func updateTableViewAnimation() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }

    /* func showAlertLikes() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так :(",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Понятно", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    } */
    
}
