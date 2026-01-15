import Fluent

struct CreateLinkedAccount: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("linked_accounts")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("institution_id", .uuid, .required, .references("institutions", "id"))
            .field("account_number", .string, .required)
            .field("balance", .double, .required)
            .field("last_synced", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("linked_accounts").delete()
    }
}
