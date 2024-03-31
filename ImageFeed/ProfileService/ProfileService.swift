import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    
    private let tokenStorage = OAuth2TokenStorage()
    private let unsplashAPIBaseURL = "https://api.unsplash.com"
    private var isFetchingProfile = false
    private(set) var profile: Profile?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard !isFetchingProfile else {
            return
        }
        
        isFetchingProfile = true
        
        guard let request = makeUserProfileRequest(token: token) else {
            let error = NSError(domain: "Invalid request", code: -1, userInfo: nil)
            print("[ProfileService]: Invalid request error")
            completion(.failure(error))
            isFetchingProfile = false
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService]: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.isFetchingProfile = false
        }
        
        task.resume()
    }
    
    private func makeUserProfileRequest(token: String) -> URLRequest? {
        let endpoint = "/me"
        let urlString = unsplashAPIBaseURL + endpoint
        guard let url = URL(string: urlString) else {
            print("[ProfileService]: Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}


enum ProfileServiceError: Error {
    case invalidRequest
    case invalidResponse
    case invalidData
}
