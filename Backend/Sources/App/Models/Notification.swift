import Fluent
import Vapor

final class Notification: Model, Content, @unchecked Sendable {
    static let schema = "notifications"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "message")
    var message: String
    
    @Field(key: "type")
    var type: String // "INFO", "ALERT", "TRANSACTION"
    
    @Field(key: "is_read")
    var isRead: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, userID: User.IDValue, title: String, message: String, type: String = "INFO", isRead: Bool = false) {
        self.id = id
        self.$user.id = userID
        self.title = title
        self.message = message
        self.type = type
        self.isRead = isRead
    }
}
