import Foundation

struct Message: Codable, Equatable {
    let id: Int
    let roomId: Int
    let userId: Int?
    let username: String?
    let displayName: String?
    let content: String
    let messageType: String
    let fileUrl: String?
    let fileName: String?
    var status: String // "sent", "delivered", "read"
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case userId = "user_id"
        case username
        case displayName = "display_name"
        case content
        case messageType = "message_type"
        case fileUrl = "file_url"
        case fileName = "file_name"
        case status
        case createdAt = "created_at"
    }
    
    // Viết thêm hàm init custom để bọc an toàn chống lỗi "missing data"
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        // Bọc an toàn cho ID tin nhắn và Room ID (nếu thiếu gán tạm là -1)
        id          = try c.decodeIfPresent(Int.self, forKey: .id) ?? -1
        roomId      = try c.decodeIfPresent(Int.self, forKey: .roomId) ?? -1
        
        // Các trường vốn đã là Optional (?) thì dùng thẳng decodeIfPresent
        userId      = try c.decodeIfPresent(Int.self, forKey: .userId)
        username    = try c.decodeIfPresent(String.self, forKey: .username)
        displayName = try c.decodeIfPresent(String.self, forKey: .displayName)
        
        // Nội dung tin nhắn: Nếu chưa có tin nhắn nào, hiển thị dòng trạng thái gợi ý mượt mà
        content     = try c.decodeIfPresent(String.self, forKey: .content) ?? "Chưa có tin nhắn nào trong phòng này."
        
        // Thể loại tin nhắn (mặc định là text) và trạng thái tin nhắn
        messageType = try c.decodeIfPresent(String.self, forKey: .messageType) ?? "text"
        status      = try c.decodeIfPresent(String.self, forKey: .status) ?? "sent"
        
        // Các trường file đính kèm dạng Optional (?)
        fileUrl     = try c.decodeIfPresent(String.self, forKey: .fileUrl)
        fileName    = try c.decodeIfPresent(String.self, forKey: .fileName)
        
        // Thời gian tạo tin nhắn
        createdAt   = try c.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    }
}
