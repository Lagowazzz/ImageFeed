import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private let lock = NSLock()
    
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else { fatalError("Invalid Base URL") }
        guard let url = URL(string: "/oauth/token" +
                            "?client_id=\(Constants.accessKey)" +
                            "&&client_secret=\(Constants.secretKey)" +
                            "&&redirect_uri=\(Constants.redirectURI)" +
                            "&&code=\(code)" +
                            "&&grant_type=authorization_code", relativeTo: baseURL) else { fatalError("Invalid URL")}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                let error = AuthServiceError.invalidRequest
                print("[OAuth2Service]: Invalid request error")
                completion(.failure(error))
                return
            }
        }
        
        lastCode = code
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = AuthServiceError.invalidRequest
            print("[OAuth2Service]: Invalid request error")
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("[OAuth2Service]: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let data = data,
               let tokenResponse = try? JSONDecoder().decode(OAuthTokenResponseBody.self, from: data) {
                self.tokenStorage.token = tokenResponse.accessToken
                completion(.success(tokenResponse.accessToken))
            } else {
                let error = AuthServiceError.invalidRequest
                print("[OAuth2Service]: Invalid request error")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}
