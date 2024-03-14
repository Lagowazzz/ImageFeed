import Foundation

final class OAuth2Service {
  
        
    
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}

    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard let baseURL = URL(string: "https://unsplash.com") else { fatalError("Invalid Base URL") }
        guard let url = URL(string: "/oauth/token" +
                            "?client_id=\(Constants.AccessKey)" +
                            "&&client_secret=\(Constants.SecretKey)" +
                            "&&redirect_uri=\(Constants.RedirectURI)" +
                            "&&code=\(code)" +
                            "&&grant_type=authorization_code", relativeTo: baseURL) else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.data(for: request) { [self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = tokenResponse.accessToken
                    completion(.success(data))
                } catch let decodingError {
                    print("Decoding Error: \(decodingError)")
                    completion(.failure(decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }

}
