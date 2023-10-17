import UIKit
final class OAuthToTokenStorage {

    // new
    static var shared = OAuthToTokenStorage()
    //

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: "token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
}
