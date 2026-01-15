import Fluent

struct CreateNotification: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("notifications")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("title", .string, .required)
            .field("message", .string, .required)
            .field("type", .string, .required)
            .field("is_read", .bool, .required, .custom("DEFAULT FALSE"))
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("notifications").delete()
    }
}
