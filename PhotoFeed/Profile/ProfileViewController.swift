import UIKit
import Kingfisher
import SwiftKeychainWrapper
import WebKit

final class ProfileViewController: UIViewController {

    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    private let token = OAuthToTokenStorage()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Photo")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "___ ___"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let profileNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@___"
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "___"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: self,
            action: #selector(didTapLogoutButton))
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }

    deinit {
        removeObserver()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(profileNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)

        constraintsSet()
        updateProfileDetails()
    }

    private func updateProfileDetails() {
        guard let profile = profileService.profile else { return }

        profileImageView.contentMode = .scaleAspectFill
        nameLabel.text = "\(profile.firstName) \(profile.lastName ?? "")"
        profileNameLabel.text = "@\(profile.username)"
        descriptionLabel.text = profile.bio

        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            let processor = RoundCornerImageProcessor(cornerRadius: 35, backgroundColor: .clear)
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholderAvatar"),
                options: [.processor(processor),
                          .transition(.fade(1)),
                          .cacheSerializer(FormatIndicatedCacheSerializer.png)]
            )
            let cache = ImageCache.default
            cache.clearMemoryCache()
            cache.clearDiskCache()
        }
    }

    private func constraintsSet() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),

            profileNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            profileNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: profileNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profileNameLabel.leadingAnchor),

            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }

    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }

    @objc private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let _ = URL(string: profileImageURL)
        else { return }
    }

    @objc private func didTapLogoutButton() {
        showAlert()
    }
}

extension ProfileViewController {

    private func showAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] alertAction in
            guard let self = self else { return }
            self.cleanAndGoToMainScreen()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func cleanAndGoToMainScreen() {
        WebViewViewController.clean()
        profileImageService.clean()
        profileService.clean()
        imagesListService.clean()
        token.clean()

        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }

}
