
import Foundation

 protocol ImageListViewPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? {get set}
    var imagesListService: ImagesListService {get}
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    weak var view: ImageListViewControllerProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    let imagesListService = ImagesListService.shared
    
    func viewDidLoad() {
        addObserver()
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage(){
        imagesListService.fetchPhotosNextPage()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.view?.updateTableViewAnimated()
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLiked: isLike, {[weak self] result in
            guard self != nil else { return }
            switch result{
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
                print(error.localizedDescription)
            }
        })
    }
}
