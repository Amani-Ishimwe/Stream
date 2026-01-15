import Fluent

struct AddInstitutionFieldsToTransaction: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("transactions")
            .field("source_institution_id", .uuid, .references("institutions", "id"))
            .field("destination_institution_id", .uuid, .references("institutions", "id"))
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("transactions")
            .deleteField("source_institution_id")
            .deleteField("destination_institution_id")
            .update()
    }
}
