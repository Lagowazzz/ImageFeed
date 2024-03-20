import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

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
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        guard
            let request = makeOAuthTokenRequest(code: code)
        else { completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    let unknownError = NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown response from server"])
                    print("Unknown response from server")
                    completion(.failure(unknownError))
                    return
                }

                guard (200..<300).contains(httpResponse.statusCode) else {
                    let statusCodeError = NSError(domain: "OAuth2Service", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP status code \(httpResponse.statusCode)"])
                    print("Unsuccessful response from server: \(httpResponse.statusCode)")
                    completion(.failure(statusCodeError))
                    return
                }

                guard let data = data else {
                    let missingDataError = NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing data in response"])
                    print("Missing data in response")
                    completion(.failure(missingDataError))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self?.tokenStorage.token = tokenResponse.accessToken
                    completion(.success(tokenResponse.accessToken))
                    
                } catch let decodingError {
                    print("Decoding Error: \(decodingError)")
                    completion(.failure(decodingError))
                    
                }
                self?.task = nil
                self?.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}
