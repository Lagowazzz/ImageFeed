import Kingfisher
import UIKit

protocol SingleImageViewControllerDelegate: AnyObject {
    func singleImageViewControllerDidTapLike(_ viewController: SingleImageViewController)
}

final class SingleImageViewController: UIViewController {

    var photo: Photo?
    var isLiked: Bool = false
    weak var delegate: SingleImageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageScrollView()
        setupSwipeGesture()
       
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
        likeButton.setImage(likeImage, for: .normal)

        guard let photo = photo, let fullImageUrl = URL(string: photo.largeImageURL) else {
            return
        }
        
        imageView.kf.indicatorType = .activity
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageUrl, placeholder: UIImage(named: "Stub2")) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.imageScrollView.set(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
        
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(sharingButton)
        view.bringSubviewToFront(backGroundButton)
        view.bringSubviewToFront(likeButton)
    }
    
    @IBOutlet private weak var sharingButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction private func didTapLikeButton(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isLiked.toggle()
            let imageName = self.isLiked ? "Active" : "NoActive"
            self.likeButton.setImage(UIImage(named: imageName), for: .normal)
            self.delegate?.singleImageViewControllerDidTapLike(self)
        }
    }

    @IBOutlet weak var backGroundButton: UIImageView!
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        
        do {
            
            let fileManager = FileManager.default
            let tempDirectoryURL = fileManager.temporaryDirectory
            let fileURL = tempDirectoryURL.appendingPathComponent("sharedImage.jpg")
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                try imageData.write(to: fileURL)
                
                let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                present(activityViewController, animated: true, completion: nil)
            } else {
                print("Failed to convert image to data")
            }
        } catch {
            print("Error creating temporary file URL: \(error)")
        }
    }
    
    @IBOutlet private weak var backButton: UIButton!
    
    @IBAction private func didTapBackButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.imageScrollView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            self.view.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private  var imageScrollView: ImageScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
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
    
    deinit {
            imageView.kf.cancelDownloadTask()
        }
}

extension SingleImageViewController {
    
    func showError() {
        let alertController = UIAlertController(title: "Что-то пошло не так", message: "Попробовать ещё раз?", preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self = self, let photo = self.photo, let fullImageUrl = URL(string: photo.largeImageURL) else {
                return
            }
            
            self.imageView.kf.indicatorType = .activity
            UIBlockingProgressHUD.show()
            self.imageView.kf.setImage(with: fullImageUrl) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                switch result {
                case .success(let imageResult):
                    self.imageScrollView.set(image: imageResult.image)
                case .failure:
                    self.showError()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: nil)
        
        alertController.addAction(retryAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension SingleImageViewController {
    
    func setupSwipeGesture() {
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight(_:)))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
    }
    
    @objc func didSwipeRight(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            didTapBackButton(backButton)
        }
    }
}

