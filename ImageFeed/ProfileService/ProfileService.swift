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
            completion(.failure(ProfileServiceError.invalidRequest))
            isFetchingProfile = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            defer {
                self.isFetchingProfile = false
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(ProfileServiceError.invalidResponse))
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let profileResult = try decoder.decode(ProfileResult.self, from: data)
                    let profile = Profile(from: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(ProfileServiceError.invalidData))
            }
        }
        
        task.resume()
    }
    
    private func makeUserProfileRequest(token: String) -> URLRequest? {
        let endpoint = "/me"
        let urlString = unsplashAPIBaseURL + endpoint
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
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
