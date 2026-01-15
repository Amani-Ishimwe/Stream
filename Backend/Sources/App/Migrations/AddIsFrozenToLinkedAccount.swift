import Fluent

struct AddIsFrozenToLinkedAccount: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("linked_accounts")
            .field("is_frozen", .bool, .required, .sql(.default(false)))
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("linked_accounts")
            .deleteField("is_frozen")
            .update()
    }
}
