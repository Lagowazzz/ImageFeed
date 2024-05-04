
import Foundation

struct UnsplashPhoto: Codable {
    let id: String
    let createdAt: Date
    let likedByUser: Bool
    let urls: URLs
    let width: Int
    let height: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
        case urls
        case width
        case height
    }
}

struct URLs: Codable {
    let regular: String
    let full: String
    let thumb: String
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

extension UnsplashPhoto {
    func toPhoto() -> Photo {
        return Photo(id: id, size: CGSize(width: width, height: height), createdAt: Date(), welcomeDescription: nil, thumdImageURL: urls.thumb , largeImageURL: urls.full, regularImageURL: urls.regular, isLiked: likedByUser)
    }
}

  
    
