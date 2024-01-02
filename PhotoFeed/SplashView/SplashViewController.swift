import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        return imageView
    }()

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauthToTokenStorage = OAuthToTokenStorage.shared
    private let oauthToService = OAuthToService.shared
    private let profileServiсe = ProfileService.shared
    private let profileImageService = ProfileImageService.shared


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func showAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так :(",
            message: "Не удаётся войти в систему",
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            switchToAuthViewController()
        }

        alertController.addAction(action)
        present(alertController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UIBlockingProgressHUD.isShowing == false else { return }
        checkAuthTokenAndFetchProfile()
    }

    private func switchToAuthViewController() {
        guard let authVC = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        else { return }
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBar = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBar
    }
}

//MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {

        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(with: code)
            self.checkAuthTokenAndFetchProfile()
        }
    }

    func checkAuthTokenAndFetchProfile() {
        if oauthToService.isAuthenticated {
            fetchProfile()
        } else {
            presentAuthViewController()
        }
    }

    private func fetchOAuthToken(with code: String) {
        oauthToService.fetchAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                fetchProfile()
            case.failure(let error):
                UIBlockingProgressHUD.dismiss()
                print(error.localizedDescription)
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

            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showAlert()
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
}


