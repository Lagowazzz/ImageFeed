import UIKit
import Kingfisher

protocol ImageListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImageListCell)
}

final class ImageListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImageListCellDelegate?
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBAction func didTapLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewCell.kf.cancelDownloadTask()
        imageViewCell.image = nil
    }
    
    func setIsLiked(isLiked: Bool) {
        DispatchQueue.main.async {
            let imageName = isLiked ? "Active" : "NoActive"
            self.likeButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }
}
