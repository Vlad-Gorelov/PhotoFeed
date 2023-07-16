import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    static let WebViewSegueIdentifier = "ShowWebView"

    @IBOutlet private var webView: WKWebView!
    @IBAction private func didTapBackButton(_ sender: Any?) {

    }

}
