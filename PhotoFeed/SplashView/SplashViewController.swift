import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    enum TokenState {
        case notLoaded
        case loading
        case didLoaded
    }

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauthToService = OAuthToService.shared
    private let oauthToTokenStorage = OAuthToTokenStorage.shared
    private let profileServiсe = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let alertPresenter = AlertPresenter()

    private var tokenState: TokenState = .notLoaded

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        alertPresenter.delegate = self
        tokenState = oauthToService.isAuthenticated
        ? .didLoaded
        : .notLoaded
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UIBlockingProgressHUD.isShowing == false else { return }
        switchTokenState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        return imageView
    }()

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBar = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBar
    }

    private func switchTokenState() {
        switch tokenState {
        case .notLoaded:
            presentAuthViewController()
        case .loading:
            break
        case .didLoaded:
            fetchProfile()
        }
    }

}

//MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {

    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        tokenState = .loading
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauthToService.fetchAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                tokenState = .didLoaded
                switchTokenState()
            case.failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showLoginAlert(error: error)
                break
            }
        }
    }

    private func fetchProfile() {
        profileServiсe.fetchProfile() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                guard let username = self.profileServiсe.profile?.username else { return }
                self.profileImageService.fetchProfileImageURL(username: username) { _ in }
                self.switchToTabBarController()

            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showLoginAlert(error: error)
                break
            }
        }
    }

    // Alert
    func presentAuthViewController() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        else {
            assertionFailure("Failed to show Authentication Screen")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        self.present(authViewController, animated: true, completion: nil)
    }

    func showLoginAlert(error: Error) {
        alertPresenter.showAlert(title: "Что-то пошло не так :(",
                                 message: "Не удалось войти в систему: \(error.localizedDescription)") { [weak self] in
            self?.presentAuthViewController()
        }
    }
}


extension SplashViewController {
    func setUpSplashImageView() {
        view.backgroundColor = .ypBlack
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
