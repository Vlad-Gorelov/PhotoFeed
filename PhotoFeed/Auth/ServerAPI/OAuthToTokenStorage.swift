import UIKit
import SwiftKeychainWrapper

final class OAuthToTokenStorage {

    static var shared = OAuthToTokenStorage()
    private let keychain = KeychainWrapper.standard

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "bearerToken")
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: "bearerToken")
            } else {
                KeychainWrapper.standard.removeObject(forKey: "bearerToken")
            }
        }
    }
}

extension OAuthToTokenStorage {
    func clean() {
        keychain.removeAllKeys()
    }
}
