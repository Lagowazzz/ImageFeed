
import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profileImage = UIImage(named: "Photo")
        
        let imageView = UIImageView(image: profileImage)
        let label = UILabel()
        let labelSecond = UILabel()
        let labelThird = UILabel()
        let buttonImage = UIImage(systemName: "ipad.and.arrow.forward")
        guard let buttonImage = buttonImage else { return }
        let button = UIButton.systemButton(with: buttonImage, target: self, action: nil)
        
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        labelSecond.text = "@ekaterina_nov"
        labelSecond.textColor = .gray
        labelSecond.font = .systemFont(ofSize: 13)
        labelSecond.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelSecond)
        labelSecond.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        labelSecond.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        
        labelThird.text = "Hello, world!"
        labelThird.textColor = .white
        labelThird.font = .systemFont(ofSize: 13)
        labelThird.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelThird)
        labelThird.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        labelThird.topAnchor.constraint(equalTo: labelSecond.bottomAnchor, constant: 8).isActive = true
        
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
}
