import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("phone", .string, .required)
            .field("pin", .string, .required)
            .field("password_hash", .string, .required)
            .field("balance", .double, .required, .sql(.default(0.0)))
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
