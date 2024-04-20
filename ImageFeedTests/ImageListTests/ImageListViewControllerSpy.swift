@testable import ImageFeed
import UIKit

final class ImageListViewControllerSpy: ImageListViewControllerProtocol {
    var presenter: ImageFeed.ImageListViewPresenterProtocol?
    var photos: [ImageFeed.Photo]
    init(photos: [Photo]) {
        self.photos = photos
    }
    
    func updateTableViewAnimated() {
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.fetchPhotosNextPage()
    }
    
    func changeLike() {
        presenter?.changeLike(photoId: "some", isLike: true)
        {[weak self ] result in
            guard self != nil else { return }
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
