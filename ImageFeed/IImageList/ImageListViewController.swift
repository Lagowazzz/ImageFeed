import UIKit
import Kingfisher

class ImageListViewController: UIViewController, ImageListCellDelegate {
  
    
    
    @IBOutlet private var tableView: UITableView!
    var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private var didRegisterNotifications = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        if !didRegisterNotifications {
            NotificationCenter.default.addObserver(self, selector: #selector(handleImagesListServiceDidChangeNotification), name: ImagesListService.didChangeNotification, object: nil)
            didRegisterNotifications = true
        }
        
        imagesListService.fetchPhotosNextPage()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleImagesListServiceDidChangeNotification() {
        updateTableViewAnimated()
    }
    
    func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        cell.imageViewCell.kf.indicatorType = .activity
        
        if let regularnailURL = URL(string: photo.regularImageURL) {
            cell.imageViewCell.kf.setImage(with: regularnailURL, placeholder: UIImage(named: "Stub2"), options: [.transition(.fade(0.2))])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let cell = tableView.cellForRow(at: indexPath) as? ImageListCell,
                let image = cell.imageViewCell.image
            else {
                assertionFailure("Invalid Segue Destination")
                return
            }
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}

extension ImageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count - 1, !imagesListService.isLoading {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath) as? ImageListCell else {
            fatalError("Failed to dequeue ImageListCell")
        }
        configCell(for: cell, with: indexPath)
        addGradient(to: cell)
        cell.delegate = self
        return cell
    }
    
    private func addGradient(to cell: UITableViewCell) {
        cell.contentView.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 16
        gradientLayer.frame = CGRect(x: 16, y: cell.contentView.bounds.height - 33, width: cell.contentView.bounds.width - 32, height: 30)
        gradientLayer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1).cgColor]
        gradientLayer.locations = [0, 1]
        cell.contentView.layer.addSublayer(gradientLayer)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = imagesListService.photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func updateTableViewAnimated() {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = imagesListService.photos.count
        let indexPaths = (oldCount..<newCount).map { i in
            IndexPath(row: i, section: 0)
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
    }


func imageListCellDidTapLike(_ cell: ImageListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
    let photo = imagesListService.photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLiked: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.presentErrorAlert()
            }
        }
    }
    
    private func presentErrorAlert() {
        let alertController = UIAlertController(title: "Что-то пошло не так(", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}


