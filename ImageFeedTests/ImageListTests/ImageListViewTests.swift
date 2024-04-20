@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad(){
        //Given
        let imageListService = ImagesListService.shared
        let viewController = ImageListViewController()
        let presenter = ImageListViewPresenterSpy(imagesListService: imageListService)
        viewController.presenter = presenter
        presenter.view = viewController
        //When
        presenter.viewDidLoad()
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testFetchPhotos() {
        //Given
        let tableView = UITableView()
        let tableCell = UITableViewCell()
        let indexPath: IndexPath = IndexPath(row: 2, section: 2)
        let photos: [Photo] = []
        let imagesListService = ImagesListService.shared
        let view = ImageListViewControllerSpy(photos: photos)
        let presenter = ImageListViewPresenterSpy(imagesListService: imagesListService)
        view.presenter = presenter
        presenter.view = view
        //When
        view.tableView(tableView, willDisplay: tableCell, forRowAt: indexPath)
        //Then
        XCTAssertTrue(presenter.didFetchPhotosNextPageCalled)
    }
    
    func testChangeLike(){
        //Given
        let photos: [Photo] = []
        let imagesListService = ImagesListService.shared
        let view = ImageListViewControllerSpy(photos: photos)
        let presenter = ImageListViewPresenterSpy(imagesListService: imagesListService)
        view.presenter = presenter
        presenter.view = view
        //When
        view.changeLike()
        //Then
        XCTAssertTrue(presenter.didChangeLikeCalled)
    }
}
