import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateAvatar()
    func showAlert()
    func cleanAndGoToMainScreen()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {

    var presenter: ProfileViewPresenterProtocol?

    //MARK: - Private Properties

    private var profileImageView: UIImageView!
    private var nameLabel: UILabel!
    private var profileNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var logoutButton: UIButton!


    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
        updateAvatar()
        presenter?.profileImageObserver()
        updateProfileDetails()
        view.backgroundColor = UIColor.ypBlack
    }

    //MARK: - Setup User Interface

    private func setupUserInterface() {
        setupProfileImageView()
        setupNameLabel()
        setupProfileNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
    }

    //MARK: - Private Functions

    private func setupProfileImageView() {
        profileImageView = UIImageView(image: UIImage(named: "Photo"))
        profileImageView.tintColor = .ypGray
        profileImageView.layer.cornerRadius = 35
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)

        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }

    private func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.text = "___ ___"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: 0)
        ])
    }

    private func setupProfileNameLabel() {
        profileNameLabel = UILabel()
        profileNameLabel.text = "___ ___"
        profileNameLabel.font = UIFont.systemFont(ofSize: 13)
        profileNameLabel.textColor = .ypWhite50
        profileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileNameLabel)

        NSLayoutConstraint.activate([
            profileNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            profileNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0)
        ])
    }

    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: profileNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profileNameLabel.leadingAnchor, constant: 0)
        ])
    }

    private func setupLogoutButton() {
        logoutButton = UIButton(type: .custom)
        logoutButton.tintColor = .ypRed
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setImage(UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        logoutButton.accessibilityIdentifier = "logoutButton"
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])

        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }

    //MARK: - Button Actions
    @objc private func didTapLogoutButton() {
        showAlert()
    }
}
//MARK: - Extensions


extension ProfileViewController {

    func configure(_ presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }

    private func updateProfileDetails() {
        guard let profile = presenter?.getProfileDetails() else { return }
        nameLabel.text = profile.name
        profileNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

    func updateAvatar() {
        guard let url = presenter?.getProfileImageURL() else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 70, backgroundColor: .clear)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderAvatar"),
            options: [.processor(processor),
                      .cacheSerializer(FormatIndicatedCacheSerializer.png)]
        )
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }

    func showAlert() {
        guard let inputValue = presenter?.prepareAlert() else { return }
        let alert = UIAlertController(
            title: inputValue.title,
            message: inputValue.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: inputValue.actionYes, style: .default) { [weak self] alertAction in
            guard let self = self else { return }
            presenter?.cleanAndGoToMainScreen()
        })
        alert.addAction(UIAlertAction(title: inputValue.actionNo, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func cleanAndGoToMainScreen() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
}

