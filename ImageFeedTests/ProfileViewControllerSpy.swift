import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: ProfileViewPresenterProtocol?

    func updateAvatar() {
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile?) {
    }
}
