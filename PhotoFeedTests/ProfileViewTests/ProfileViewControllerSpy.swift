import UIKit
@testable import PhotoFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {

    var presenter: PhotoFeed.ProfileViewPresenterProtocol?
    var alertCheck = false
    var presenterSpy = ProfileViewPresenterSpy()

    func cleanAndGoToMainScreen() {}

    func updateAvatar() {}

    func showAlert() {
        let input = presenterSpy.prepareAlert()

        let alert = UIAlertController(title: input.title, message: input.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: input.actionYes, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: input.actionNo, style: .default, handler: nil))
        alertCheck = true
    }
}
