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
}
