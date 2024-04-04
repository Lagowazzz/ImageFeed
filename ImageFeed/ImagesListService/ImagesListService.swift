import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    var isLoading = false
    
    func fetchPhotosNextPage() {
        print("ImagesListService: Fetching next page...")
        
        guard !isLoading else { return }
        
        isLoading = true
        let perPage = 10
        let nextPage = (lastLoadedPage ?? 0) + 1
        let accessKey = Constants.accessKey
        let urlString = "https://api.unsplash.com/photos/?page=\(nextPage)&per_page=\(perPage)&client_id=\(accessKey)"
        print("ImageListService: Fetching photos with URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                self?.isLoading = false
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let newPhotos = try decoder.decode([PhotoResult].self, from: data)
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos.map { $0.toPhoto() })
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    self.lastLoadedPage = nextPage
                    self.isLoading = false
                    print("Fetched \(newPhotos.count) new photos. Total photos: \(self.photos.count)")
                }
            } catch {
                print("Error decoding JSON: \(error)")
                self.isLoading = false
            }
        }
        
        task.resume()
    }
    
    func clearPhotos() {
        photos.removeAll()
    }
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        print("Changing like for photoId: \(photoId)")
        
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = isLiked ? "POST" : "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = OAuth2TokenStorage().token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                    if let photo = self?.photos[index] {
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumdImageURL: photo.thumdImageURL,
                            largeImageURL: photo.largeImageURL,
                            regularImageURL: photo.regularImageURL,
                            isLiked: !photo.isLiked
                        )
                        self?.photos[index] = newPhoto
                    }
                }
                
                completion(.success(()))
            }
            task.resume()
        } else {
            print("Invalid URL")
            isLoading = false
        }
    }
}
