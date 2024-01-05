import UIKit
@testable import PhotoFeed

final class ImagesListPresenterSpy: ImagesListViewPresenterProtocol {

    var view: PhotoFeed.ImageListViewControllerProtocol?
    var imagesListService: PhotoFeed.ImagesListService
    var photos: [PhotoFeed.Photo] = []
    var viewDidLoadCalled = false
    var changeLikeCalled = false
    var tableViewUpdateCheck = false

    init(imagesListService: ImagesListService) {
        self.imagesListService = imagesListService
    }

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func imagesListCellDidTapLike(_ cell: PhotoFeed.ImagesListCell, indexPath: IndexPath) {
        changeLike(photoId: "123", isLike: false) { _ in }
    }

    func updateTableViewAnimation() {
        tableViewUpdateCheck = true
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
    }

}
