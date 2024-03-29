import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private var isFetchingProfileImage = false
    private let unsplashAPIBaseURL = "https://api.unsplash.com"
    private let session = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private (set) var avatarURL: String?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard !isFetchingProfileImage else {
            return
        }
        
        isFetchingProfileImage = true
        
        guard let url = URL(string: "\(unsplashAPIBaseURL)/users/\(username)") else {
            let error = NSError(domain: "Invalid URL", code: -1, userInfo: nil)
            print("[ProfileImageService]: Invalid URL error")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = session.objectTask(for: request) { (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage.large
                completion(.success(userResult.profileImage.large))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": url])
            case .failure(let error):
                print("[ProfileImageService]: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.isFetchingProfileImage = false
        }
        
        task.resume()
    }
}
