import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

import Foundation

final class OAuth2Service {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
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
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                let error = NSError(domain: "Invalid request", code: -1, userInfo: nil)
                print("[OAuth2Service]: Invalid request error")
                completion(.failure(error))
                return
            }
        } else {
            if lastCode == code {
                let error = NSError(domain: "Invalid request", code: -1, userInfo: nil)
                print("[OAuth2Service]: Invalid request error")
                completion(.failure(error))
                return
            }
        }
        lastCode = code
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NSError(domain: "Invalid request", code: -1, userInfo: nil)
            print("[OAuth2Service]: Invalid request error")
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenResponse):
                self.tokenStorage.token = tokenResponse.accessToken
                completion(.success(tokenResponse.accessToken))
            case .failure(let error):
                print("[OAuth2Service]: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}
