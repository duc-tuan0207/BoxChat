import Foundation

struct Room: Codable {
    let id: Int
    var name: String
    var description: String?
    let inviteCode: String
    let createdBy: String?
    var members: [RoomMember]?
    var lastMessage: Message?
    var unreadCount: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case inviteCode = "invite_code"
        case createdBy = "created_by"
        case members
        case lastMessage = "last_message"
        case unreadCount = "unread_count"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id          = try c.decode(Int.self, forKey: .id)
        name        = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        inviteCode  = try c.decodeIfPresent(String.self, forKey: .inviteCode) ?? ""
        createdBy   = try c.decodeIfPresent(String.self, forKey: .createdBy)
        members     = try c.decodeIfPresent([RoomMember].self, forKey: .members)
        lastMessage = try c.decodeIfPresent(Message.self, forKey: .lastMessage)
        unreadCount = try c.decodeIfPresent(Int.self, forKey: .unreadCount) ?? 0
        createdAt   = try c.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    }
}

struct RoomMember: Codable {
    let userId: Int
    let username: String
    let displayName: String
    let role: String
    var isOnline: Bool
    let joinedAt: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case displayName = "display_name"
        case role
        case isOnline = "is_online"
        case joinedAt = "joined_at"
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        userId      = try c.decode(Int.self, forKey: .userId)
        username    = try c.decode(String.self, forKey: .username)
        displayName = try c.decodeIfPresent(String.self, forKey: .displayName) ?? username
        role        = try c.decodeIfPresent(String.self, forKey: .role) ?? "member"
        isOnline    = try c.decodeIfPresent(Bool.self, forKey: .isOnline) ?? false
        joinedAt    = try c.decodeIfPresent(String.self, forKey: .joinedAt) ?? ""
    }
}
