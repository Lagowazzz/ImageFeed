
import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    let user: UserResult
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
        case user
    }
}

extension PhotoResult {
    func toPhoto() -> Photo {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = dateFormatter.date(from: createdAt) else {
            return Photo(
                id: id,
                size: CGSize(width: width, height: height),
                createdAt: nil,
                welcomeDescription: description,
                thumdImageURL: urls.thumb.absoluteString,
                largeImageURL: urls.full.absoluteString,
                regularImageURL: urls.regular.absoluteString,
                isLiked: likedByUser
            )
        }
        
        return Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: date,
            welcomeDescription: description,
            thumdImageURL: urls.thumb.absoluteString,
            largeImageURL: urls.full.absoluteString,
            regularImageURL: urls.regular.absoluteString,
            isLiked: likedByUser
        )
    }
}
