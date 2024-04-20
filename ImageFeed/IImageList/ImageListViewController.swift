import UIKit
import Kingfisher

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol? {get set}
    func updateTableViewAnimated()
    var photos: [Photo] {get set}
}

final class ImageListViewController: UIViewController, ImageListCellDelegate, ImageListViewControllerProtocol  {
    var presenter: ImageListViewPresenterProtocol? = {
        return ImageListViewPresenter()
    } ()
    var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.view = self
        presenter?.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        cell.dateLabel.text = DateFormatter.russian.string(from: photo.createdAt ?? Date())
        
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
                let photo = sender as? Photo
            else {
                assertionFailure("Invalid Segue Destination")
                return
            }
            viewController.photo = photo
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: photo)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count - 1, !imagesListService.isLoading {
            presenter?.fetchPhotosNextPage()
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
    
    internal func updateTableViewAnimated() {
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
        presenter?.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                guard let newPhotos = self.presenter?.imagesListService.photos else {return}
                self.photos = newPhotos
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


