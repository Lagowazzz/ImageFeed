import UIKit
import Foundation

final class ImageListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBAction func tappedLikeButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
               
               let isLiked = button.isSelected
               button.isSelected = !isLiked
               
               let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
               likeButton.setImage(likeImage, for: .normal)
               
               // Проверяем, изменился ли статус лайка
               if !isLiked {
                   // Если статус лайка стал неактивным, удаляем снег
                   removeSnowEffect()
               } else {
                   // Если статус лайка стал активным, добавляем снег
                   addSnowEffect()
               }
           }
           
           // Функция для добавления снега
           private func addSnowEffect() {
               // Проверяем, есть ли изображение в ячейке
               if let _ = imageViewCell.image {
                   // Создаем и добавляем снеговой эффект
                   let snowView = SnowView(frame: imageViewCell.bounds)
                   imageViewCell.addSubview(snowView)
                   snowView.setupSnowfall()
                   snowView.animateSnowfall()
               }
           }
           
           // Функция для удаления снега
           private func removeSnowEffect() {
               // Удаляем все снеговые эффекты из ячейки
               imageViewCell.subviews.forEach { subview in
                   if subview is SnowView {
                       subview.removeFromSuperview()
                   }
               }
           }
       }
