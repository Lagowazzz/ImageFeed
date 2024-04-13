import Kingfisher
import UIKit

final class SingleImageViewController: UIViewController {
    
    var photo: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageScrollView()
        
        guard let photo = photo, let fullImageUrl = URL(string: photo.largeImageURL) else {
            return
        }
        print("Image size: \(photo.size)")
        
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
    }
    
    @IBOutlet private weak var sharingButton: UIButton!
    
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
        dismiss(animated: true, completion: nil)
    }
    
    private var imageScrollView: ImageScrollView!
    
    @IBOutlet private var imageView: UIImageView!
    
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
