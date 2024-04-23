@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        //When
        _ = viewController.view
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        //Given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        //When
        presenter.viewDidLoad()
        //Then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        //Then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        //Then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //Given
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        //When
        let url = authHelper.authURL()
        let urlString = url?.absoluteString
        //Then
        XCTAssertTrue(((urlString?.contains(configuration.authURLString)) != nil))
        XCTAssertTrue(((urlString?.contains(configuration.accessKey)) != nil))
        XCTAssertTrue(((urlString?.contains(configuration.redirectURI)) != nil))
        XCTAssertTrue(((urlString?.contains("code")) != nil))
        XCTAssertTrue(((urlString?.contains(configuration.accessScope)) != nil))
    }
    
    func testCodeFromURL() {
        //Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [URLQueryItem(name: "code", value: "test code")]
        guard let url = urlComponents?.url else { return }
        let authHelper = AuthHelper()
        //Then
        let code = authHelper.code(from: url)
        //When
        XCTAssertEqual(code, "test code")
    }
    
}
