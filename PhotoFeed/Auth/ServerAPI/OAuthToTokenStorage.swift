import UIKit
import SwiftKeychainWrapper

final class OAuthToTokenStorage {

    static var shared = OAuthToTokenStorage()

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "token")
        }
        set {
            assert(newValue != "", "Token is wrong")
            KeychainWrapper.standard.set(newValue!, forKey: "token")
        }
    }
}

extension OAuthToTokenStorage {
    func clean() {
        KeychainWrapper.standard.removeAllKeys()
    }
}
