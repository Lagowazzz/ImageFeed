import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    @objc func logout() {
        cleanCookies()
        cleanData()
        navigateToInitialScreen()
    }
    
     func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
     func navigateToInitialScreen() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        let initialVC = SplashViewController()
        let navigationController = UINavigationController(rootViewController: initialVC)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
     func cleanData() {
        cleanProfileData()
        cleanImageData()
        deleteToken()
    }
    
    private func cleanProfileData() {
        ProfileService.shared.fetchProfile("") { _ in }
    }
    
    private func cleanImageData() {
        ProfileImageService.shared.fetchProfileImageURL(username: "") { _ in }
        ImagesListService().clearPhotos()
    }
    
    @objc func deleteToken() {
        let tokenStorage = OAuth2TokenStorage()
        tokenStorage.token = nil
    }
}
