import Foundation

public protocol ProfileViewPresenterProtocol {
    func notificationObserver()
    func logout()
    func viewDidLoad()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    private weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService = ProfileService.shared
    private let shared = ProfileLogoutService.shared
    init(view: ProfileViewControllerProtocol) {
        self.view = view
        notificationObserver()
    }
    
    func notificationObserver() {
        profileImageServiceObserver = 
        NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification,
                                               object: nil, queue: .main) { [weak self] _ in
            self?.view?.updateAvatar()
        }
    }
    
    func logout() {
        shared.cleanCookies()
        shared.cleanData()
        shared.navigateToInitialScreen()
    }
    
    func viewDidLoad() {
        guard let profile = profileService.profile else {
            return
        }
        view?.updateProfileDetails(profile: profile)
        notificationObserver()
    }
}

