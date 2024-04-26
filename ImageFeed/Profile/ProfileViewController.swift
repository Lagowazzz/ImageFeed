import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateAvatar()
    func updateProfileDetails(profile: Profile?)
    var presenter: ProfileViewPresenterProtocol? {get set}
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    private let imageView = UIImageView()
    private let label = UILabel()
    private let labelSecond = UILabel()
    private let labelThird = UILabel()
    private let button = UIButton()
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileLogoutService = ProfileLogoutService.shared
    private let noPhoto = UIImageView()
    private let favorites = UILabel()
    private let notification = UILabel()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        presenter?.notificationObserver()
        presenter = ProfileViewPresenter(view: self)
        setupUI()
        setupConstraints()
        updateProfileDetails(profile: profileService.profile)
        updateAvatar()
    }
    
    func updateAvatar() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let profileImageURL = ProfileImageService.shared.avatarURL,
                  let url = URL(string: profileImageURL) else { return }
            let processor = RoundCornerImageProcessor(cornerRadius: 35)
            self.imageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Stub"),
                options: [.processor(processor)]
            )
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        setupImageView()
        setupLabel()
        setupSecondLabel()
        setupThirdLabel()
        setupButton()
        setupNoPhoto()
        setupFavorites()
        setupNotification()
    }
    
    private func setupImageView() {
        let profileImage = UIImage(named: "Stub")
        imageView.image = profileImage
        imageView.tintColor = .gray
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    private func setupNoPhoto() {
        let noPhotoImage = UIImage(named: "NoPhoto")
        noPhoto.image = noPhotoImage
        noPhoto.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noPhoto)
    }
    
    private func setupFavorites() {
        favorites.text = "Избранное"
        favorites.textColor = .white
        favorites.font = .boldSystemFont(ofSize: 23)
        favorites.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(favorites)
    }
    
    private func setupNotification() {
        notification.text = "27"
        notification.textColor = .white
        notification.backgroundColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1.0)
        notification.font = .boldSystemFont(ofSize: 13)
        notification.layer.cornerRadius = 13
        notification.clipsToBounds = true
        notification.textAlignment = .center
        notification.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notification)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupLabel() {
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    }
    
    private func setupSecondLabel() {
        labelSecond.text = "@ekaterina_nov"
        labelSecond.textColor = .gray
        labelSecond.font = .systemFont(ofSize: 13)
        labelSecond.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelSecond)
    }
    
    private func setupThirdLabel() {
        labelThird.text = "Hello, world!"
        labelThird.textColor = .white
        labelThird.font = .systemFont(ofSize: 13)
        labelThird.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelThird)
    }
    
    private func setupButton() {
        let buttonImage = UIImage(systemName: "ipad.and.arrow.forward")
        guard let buttonImage = buttonImage else { return }
        button.setImage(buttonImage, for: .normal)
        button.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.accessibilityIdentifier = "logout button"
        button.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            
            labelSecond.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            labelSecond.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            
            labelThird.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            labelThird.topAnchor.constraint(equalTo: labelSecond.bottomAnchor, constant: 8),
            
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            noPhoto.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 130),
            noPhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 376),
            noPhoto.widthAnchor.constraint(equalToConstant: 115),
            noPhoto.heightAnchor.constraint(equalToConstant: 115),
            
            favorites.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            favorites.topAnchor.constraint(equalTo: labelThird.bottomAnchor, constant: 22),
            
            notification.leadingAnchor.constraint(equalTo: favorites.trailingAnchor, constant: 10),
            notification.topAnchor.constraint(equalTo: labelThird.bottomAnchor, constant: 22),
            
            notification.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            notification.heightAnchor.constraint(equalToConstant: 26),
            
            
        ])
    }

    
    func updateProfileDetails(profile: Profile?) {
        label.text = profile?.name
        labelSecond.text = profile?.loginName
        labelThird.text = profile?.bio
    }
    
    @objc private func showAlert() {
        let alertController = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .destructive) { _ in
            self.presenter?.logout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
