import Foundation

struct User: Codable, Equatable {
    let id: Int
    let username: String
    let email: String?
    let displayName: String
    let avatarUrl: String?
    var isOnline: Bool
    let lastSeenAt: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case isOnline = "is_online"
        case lastSeenAt = "last_seen_at"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id          = try container.decode(Int.self, forKey: .id)
        username    = try container.decode(String.self, forKey: .username)
        email       = try container.decodeIfPresent(String.self, forKey: .email)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? username
        avatarUrl   = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        isOnline    = try container.decodeIfPresent(Bool.self, forKey: .isOnline) ?? false
        lastSeenAt  = try container.decodeIfPresent(String.self, forKey: .lastSeenAt)
        createdAt   = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    }
}
