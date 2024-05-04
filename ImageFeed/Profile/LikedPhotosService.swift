import UIKit

final class LikedPhotosService {
    static let shared = LikedPhotosService()
    private init() {}
private let profileService = ProfileService.shared
    private var isLoading = false
    private var currentPage = 1

    func fetchNextPage(completion: @escaping ([Photo]) -> Void) {
        guard !isLoading else { return }
        
        isLoading = true
        let perPage = 10
        let username = profileService.profile?.username
        let accessKey = Constants.accessKey
        let urlString = "https://api.unsplash.com/users/\(String(describing: username))/likes?page=\(currentPage)&per_page=\(perPage)&client_id=\(accessKey)"
        print("Fetching liked photos with URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                self.isLoading = false
                return
            }

            do {
                let decoder = JSONDecoder()
                let newPhotosResult = try decoder.decode([PhotoResult].self, from: data)
                let newPhotos = newPhotosResult.map { $0.toPhoto() }
                
                DispatchQueue.main.async {
                    completion(newPhotos)
                    self.currentPage += 1
                    self.isLoading = false
                }
            } catch {
                print("Error decoding JSON: \(error)")
                self.isLoading = false
            }
        }

        task.resume()
    }
}
