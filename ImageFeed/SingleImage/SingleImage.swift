
import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    var image: UIImage?
    
    @IBOutlet private  var imageView: UIImageView!
    
   
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}
