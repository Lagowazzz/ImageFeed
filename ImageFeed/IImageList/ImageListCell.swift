import UIKit
import Foundation

final class ImageListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: imageViewCell.bounds.height - (-40), width: imageViewCell.bounds.width, height: 40)
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.withAlphaComponent(0.2).cgColor]
        let gradientEndPoint = Float(50) / Float(imageViewCell.bounds.height)
        gradientLayer.locations = [0.0, NSNumber(value: gradientEndPoint)]
        imageViewCell.layer.addSublayer(gradientLayer)
    }
}
