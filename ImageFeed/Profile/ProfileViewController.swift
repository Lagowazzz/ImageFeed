import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let imageView = UIImageView()
    private let label = UILabel()
    private let labelSecond = UILabel()
    private let labelThird = UILabel()
    private let button = UIButton()
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateProfileDetails(profile: profileService.profile)
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification, object: nil,
                         queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
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
        setupImageView()
        setupLabel()
        setupSecondLabel()
        setupThirdLabel()
        setupButton()
    }
    
    private func setupImageView() {
        let profileImage = UIImage(named: "Photo")
        imageView.image = profileImage
        imageView.tintColor = .gray
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
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
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.addTarget(self, action: #selector(deleteToken), for: .touchUpInside)
    }
    
    @objc func deleteToken() {
        let tokenStorage = OAuth2TokenStorage()
        tokenStorage.token = nil
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
            button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    private func updateProfileDetails(profile: Profile?) {
        label.text = profile?.name
        labelSecond.text = profile?.loginName
        labelThird.text = profile?.bio
    }
}

