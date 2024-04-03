
import UIKit

final class SingleImageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageScrollView()
        imageView.image = image
        if let image = image {
            imageScrollView.set(image: image)
        }
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(sharingButton)
    }
    
    var image: UIImage?
    
    @IBOutlet private weak var sharingButton: UIButton!
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    @IBOutlet private weak var backButton: UIButton!
    
    @IBAction private func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private var imageScrollView: ImageScrollView!
    
    @IBOutlet private  var imageView: UIImageView!
    
    private func setupImageScrollView() {
        imageScrollView = ImageScrollView(frame: view.bounds)
        view.addSubview(imageScrollView)
        
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
}


