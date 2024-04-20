import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //Given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //When
        _ = viewController.view
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsLogout() {
        //Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //When
        presenter.logout()
        //Then
        XCTAssertTrue(presenter.logoutCalled)
    }
    
    func testViewControllerCallsObserver() {
        //Given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //When
        presenter.notificationObserver()
        //Then
        XCTAssertTrue(presenter.notificationCalled)
    }
}
