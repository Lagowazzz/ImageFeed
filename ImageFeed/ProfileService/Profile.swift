
import Foundation

public struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from profileResult: ProfileResult) {
        username = profileResult.username
        let firstName = profileResult.firstName
        let lastName = profileResult.lastName
        name = "\(firstName) \(lastName)"
        loginName = "@\(profileResult.username)"
        bio = profileResult.bio
    }
}
