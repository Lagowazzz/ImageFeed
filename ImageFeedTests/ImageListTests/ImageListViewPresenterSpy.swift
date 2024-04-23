@testable import ImageFeed

final class ImageListViewPresenterSpy: ImageListViewPresenterProtocol {
    
    var view: ImageListViewControllerProtocol?
    var viewDidLoadCalled = false
    var didChangeLikeCalled: Bool = false
    var didFetchPhotosNextPageCalled: Bool = false
    var imagesListService: ImageFeed.ImagesListService
    
    init(imagesListService: ImagesListService){
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        didFetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        didChangeLikeCalled = true
    }
}
