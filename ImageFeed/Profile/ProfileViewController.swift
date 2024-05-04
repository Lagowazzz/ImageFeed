import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateAvatar()
    func updateProfileDetails(profile: Profile?)
    var presenter: ProfileViewPresenterProtocol? { get set }
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
    var likedPhotos: [UnsplashPhoto] = []
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        presenter?.notificationObserver()
        presenter = ProfileViewPresenter(view: self)
        setupUI()
        setupNotification(profile: profileService.profile)
        setupConstraints()
        updateProfileDetails(profile: profileService.profile)
        updateAvatar()
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        fetchLikedPhotos()
        
    }
    
    func updateUIWithPhotos(_ photos: [UnsplashPhoto]) {
        self.likedPhotos = photos
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.setupNotification(profile: self.profileService.profile)
        }
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
        setupNotification(profile: profileService.profile)
        setupTableView()
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
    
    private func setupNotification(profile: Profile?) {
        notification.text = String(likedPhotos.count)
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
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        view.addSubview(tableView)
    }
    
    @objc private func refreshData() {
        likedPhotos.removeAll()
        tableView.reloadData()
        fetchLikedPhotos()
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
            
            tableView.topAnchor.constraint(equalTo: favorites.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func configCell(for cell: CustomTableViewCell, with indexPath: IndexPath) {
        guard indexPath.row < likedPhotos.count else {
            return
        }
        
        let photo = likedPhotos[indexPath.row]
        
        if let imageUrl = URL(string: photo.urls.regular) {
            cell.customImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "Stub2"), options: [.transition(.fade(0.2))])
        }
        
        cell.dateLabel.text = DateFormatter.russian.string(from: photo.createdAt)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedPhotos.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard indexPath.row < likedPhotos.count else {
            return
        }

        let selectedPhoto = likedPhotos[indexPath.row]

        guard let singleImageViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else {
            assertionFailure("Failed to instantiate SingleImageViewController from storyboard.")
            return}

        let photo = Photo(id: selectedPhoto.id,
                          size: CGSize(width: selectedPhoto.width, height: selectedPhoto.height),
                          createdAt: selectedPhoto.createdAt,
                          welcomeDescription: nil,
                          thumdImageURL: selectedPhoto.urls.thumb,
                          largeImageURL: selectedPhoto.urls.full,
                          regularImageURL: selectedPhoto.urls.regular,
                          isLiked: selectedPhoto.likedByUser)
        singleImageViewController.photo = photo
        print("Selected row at index: \(indexPath.row)")
        

        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        
        let photo = likedPhotos[indexPath.row]
        let imageUrlString = photo.urls.regular
        if let imageUrl = URL(string: imageUrlString) {
            cell.customImageView.kf.setImage(with: imageUrl)
            
            addGradient(to: cell)
            configCell(for: cell, with: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: "\(indexPath.row)") else {
            return UITableView.automaticDimension
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    private func addGradient(to cell: UITableViewCell) {
        cell.contentView.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 15
        gradientLayer.frame = CGRect(x: 0, y: cell.contentView.bounds.height - 34, width: cell.contentView.bounds.width - 0, height: 30)
        gradientLayer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1).cgColor]
        gradientLayer.locations = [0, 2]
        cell.contentView.layer.addSublayer(gradientLayer)
    }
}

extension ProfileViewController {
    func fetchLikedPhotos() {
        guard let userLikesURL = URL(string: "https://api.unsplash.com/users/lagowazzz/likes?page=1&per_page=100") else { return }
        
        var request = URLRequest(url: userLikesURL)
        request.httpMethod = "GET"
        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Не удалось получить данные")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                self.parsePhotos(data)
            } else {
                print("Ошибка: \(String(describing: response))")
            }
        }
        task.resume()
    }
    
    func parsePhotos(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let photos = try decoder.decode([UnsplashPhoto].self, from: data)
            DispatchQueue.main.async { [weak self] in
                self?.updateUIWithPhotos(photos)
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            fetchNextPage()
        }
    }
}

extension ProfileViewController {
    func fetchNextPage() {
        LikedPhotosService.shared.fetchNextPage { [weak self] newPhotos in
            guard let self = self else { return }
            let unsplashPhotos = newPhotos.map { photo -> UnsplashPhoto in
                let urls = URLs(regular: photo.regularImageURL, full: photo.largeImageURL, thumb: photo.thumdImageURL)
                return UnsplashPhoto(id: photo.id,
                                     createdAt: photo.createdAt ?? Date(),
                                     likedByUser: photo.isLiked,
                                     urls: urls,
                                     width: Int(photo.size.width),
                                     height: Int(photo.size.height))
            }
            self.likedPhotos += unsplashPhotos
            self.tableView.reloadData()
        }
    }
}
