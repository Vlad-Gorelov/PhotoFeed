import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?

    init(result profileResult: ProfileResult) {
        self.username = profileResult.username ?? ""
        self.name = "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")"
        self.loginName = "@" + self.username
        self.bio = profileResult.bio
    }
}
