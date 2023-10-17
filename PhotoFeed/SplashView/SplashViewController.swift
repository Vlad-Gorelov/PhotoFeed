import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    private let networkService = OAuthToService()
    private let profileService = ProfileService.shared //new
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"


    private let oauthToTokenStorage = OAuthToTokenStorage()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
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

        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
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
                assertionFailure(error.localizedDescription)
            }
        }
    }

    private func fetchProfile(with token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success (let profile):
                // new
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                //
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                assertionFailure(error.localizedDescription)
            }
        }
    }
}


