import XCTest
@testable import PhotoFeed

final class ImagesListViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        //given
        let vc = ImagesListViewController()
        let presenter = ImagesListPresenterSpy(imagesListService: ImagesListService())
        vc.presenter = presenter
        presenter.view = vc

        //when
        _ = vc.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testSetLike() {
        //given
        let vc = ImagesListViewController()
        let presenter = ImagesListPresenterSpy(imagesListService: ImagesListService())
        let photo = Photo(id: "123", size: CGSize(width: 400, height: 400), createdAt: Date(), description: "testDesc", thumbImageURL: "url1", fullImageURL: "url2", isLiked: false)
        let indexPath = IndexPath(row: 0, section: 0)

        let cell = ImagesListCell()
        cell.delegate = vc
        vc.presenter = presenter
        presenter.view = vc

        //when
        presenter.imagesListCellDidTapLike(cell, indexPath: indexPath)

        //then
        XCTAssertTrue(presenter.changeLikeCalled)
    }

    func testTableViewUpdate() {
        //given
        let vc = ImagesListViewController()
        let presenter = ImagesListPresenterSpy(imagesListService: ImagesListService())
        vc.presenter = presenter
        presenter.view = vc

        //when
        presenter.updateTableViewAnimation()

        //then
        XCTAssertTrue(presenter.tableViewUpdateCheck)
    }
}
