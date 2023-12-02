import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    private let networkService = OAuthToService.shared
    private let profileService = ProfileService.shared 
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauthToTokenStorage = OAuthToTokenStorage()

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
            self.performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }

        alertController.addAction(action)
        present(alertController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        imageView.image = UIImage(named: "logo")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauthToTokenStorage.token {
            fetchProfile(with: token)
        } else {

            if !networkService.isLoading {
                performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let rootVC = navigationController.viewControllers[0] as? AuthViewController
            else { assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            rootVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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

        UIBlockingProgressHUD.show()

        networkService.isLoading = true
        dismiss(animated: true) {
            self.fetchOAuthToken(with: code)
        }
    }

    private func fetchOAuthToken(with code: String) {
        networkService.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                oauthToTokenStorage.token = token
                fetchProfile(with: token)
                UIBlockingProgressHUD.dismiss()
            case.failure(let error):
                UIBlockingProgressHUD.dismiss()
                //assertionFailure(error.localizedDescription)
                print(error.localizedDescription)
                showAlert()
            }
        }
    }

    private func fetchProfile(with token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success (let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                assertionFailure(error.localizedDescription)
            }
        }
    }
}


