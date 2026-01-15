import Fluent

struct CreateInstitution: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("institutions")
            .id()
            .field("name", .string, .required)
            .field("type", .string, .required)
            .field("icon_symbol", .string, .required)
            .field("primary_color_hex", .string, .required)
            .field("is_active", .bool, .required, .custom("DEFAULT TRUE"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("institutions").delete()
    }
}
