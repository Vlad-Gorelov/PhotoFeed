import UIKit
@testable import PhotoFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {

    var view: PhotoFeed.ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    var profileData = Profile(result: ProfileResult(username: "testNickname",
                                                     firstName: "test1stName",
                                                     lastName: "test2ndName",
                                                     bio: "aboutMe"))
    var viewDidLoadCalled = false
    var profileImageCheck = false
    var logoutCheck = false

    func profileImageObserver() {
        viewDidLoadCalled = true
    }

    func prepareAlert() -> (title: String, message: String, actionYes: String, actionNo: String) {
        return ("AlertTitle", "AlertMessage", "Yes", "No")
    }

    func getProfileImageURL() -> URL? {
        profileImageCheck = true
        return nil
    }

    func getProfileDetails() -> PhotoFeed.Profile? {
        let profile = profileData
        return profile
    }

    func cleanAndGoToMainScreen() {
        logoutCheck = true
    }

}

