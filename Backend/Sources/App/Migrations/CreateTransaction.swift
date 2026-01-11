import Fluent

struct CreateTransaction: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("transactions")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("type", .string, .required)
            .field("amount", .double, .required)
            .field("description", .string)
            .field("counterparty", .string)
            .field("status", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("transactions").delete()
    }
}
