@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    
    var viewDidLoadCalled: Bool = false
    var logoutCalled: Bool = false
    var view: ImageFeed.ProfileViewControllerProtocol?
    var notificationCalled: Bool = false
    
    func notificationObserver() {
        notificationCalled = true
    }
    
    func logout() {
        logoutCalled = true
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}
