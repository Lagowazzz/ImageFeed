import UIKit

class CustomTableViewCell: UITableViewCell {
    
    let customImageView = UIImageView()
    static let reuseIdentifier = "ProfileCustomCell"
    var likeButton =  UIButton()
    var dateLabel =  UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(customImageView)
        customImageView.contentMode = .scaleAspectFill
        customImageView.clipsToBounds = true
        contentView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        customImageView.layer.cornerRadius = 15
        customImageView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        NSLayoutConstraint.activate([
            customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),])
        contentView.addSubview(likeButton)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(UIImage(named: "NoActive"), for: .normal)
        NSLayoutConstraint.activate([
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        contentView.addSubview(dateLabel)
        dateLabel.text = "your text"
        dateLabel.textColor = .white
        dateLabel.font = UIFont.boldSystemFont(ofSize: 13)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.kf.cancelDownloadTask()
        customImageView.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
