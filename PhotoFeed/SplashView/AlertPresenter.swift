import UIKit

final class AlertPresenter {
    weak var delegate: UIViewController?

    func showAlert(
        title: String,
        message: String,
        handler: @escaping () -> Void) {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                handler()
            }
            alert.addAction(okAction)
            delegate?.present(alert, animated: true)
        }
}
