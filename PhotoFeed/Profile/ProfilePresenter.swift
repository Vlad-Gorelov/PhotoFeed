import Foundation

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func profileImageObserver()
    func prepareAlert() -> (title: String, message: String, actionYes: String, actionNo: String)
    func getProfileImageURL() -> URL?
    func getProfileDetails() -> Profile?
    func cleanAndGoToMainScreen()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {

    weak var view: ProfileViewControllerProtocol?

    private let imagesListService = ImagesListService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let token = OAuthToTokenStorage.shared

    func profileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                view?.updateAvatar()
            }
    }

    func getProfileImageURL() -> URL? {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL)
        else { return nil }
        return url
    }

    func getProfileDetails() -> Profile? {
        guard let profile = profileService.profile else { return nil }
        return profile
    }

    func prepareAlert() -> (title: String, message: String, actionYes: String, actionNo: String) {
        let title = "Пока, пока!"
        let message = "Уверены, что хотите выйти?"
        let actionYes = "Да"
        let actionNo = "Нет"
        return (title, message, actionYes, actionNo)
    }

    func cleanAndGoToMainScreen() {
        WebViewPresenter.clean()
        profileImageService.clean()
        profileService.clean()
        imagesListService.clean()
        token.clean()
        view?.cleanAndGoToMainScreen()
    }
}
