
import Foundation

public struct Profile {
    let username: String
    let name: String
    let loginName: String
    let likes: Double
    let bio: String?
    
    init(from profileResult: ProfileResult) {
        username = profileResult.username
        likes = profileResult.likes
        let firstName = profileResult.firstName
        let lastName = profileResult.lastName ?? ""
        name = lastName.isEmpty ? firstName : "\(firstName) \(lastName)"
        loginName = "@\(profileResult.username)"
        bio = profileResult.bio
    }
}
