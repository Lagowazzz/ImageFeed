import UIKit
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    weak var delegate: AuthViewControllerDelegate? 

    private let oauth2Service = OAuth2Service.shared
    private let splashViewController = SplashViewController()
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self, didAuthenticateWithCode: code)
            case .failure(let error):
                print(error)
            }
        }
    }

 
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var enterButton: UIButton!

    private let showWebViewSegueIdentifier = "ShowWebView"
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
     
}
