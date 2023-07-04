import UIKit

final class ProfileViewController: UIViewController {

    private var label: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

//MARK: Profile photo
        let profileImage = UIImage(named: "Photo")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true

//MARK: Name Label
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        self.label = nameLabel

//MARK: Nickname Label
        let nicknameLabel = UILabel()
        nicknameLabel.text = "@ekaterina_nov"
        nicknameLabel.textColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.0)
        nicknameLabel.font = UIFont.systemFont(ofSize: 13)

        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nicknameLabel)
        nicknameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        self.label = nicknameLabel

//MARK: Text
        let textLabel = UILabel()
        textLabel.text = "Hello, World"
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 13)

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        textLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8).isActive = true
        self.label = textLabel

//MARK: Logout button
        let exitButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        exitButton.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1.0)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        exitButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }


    @objc
    private func didTapButton() {
        //label?.removeFromSuperview()
       // label = nil
    }
}
