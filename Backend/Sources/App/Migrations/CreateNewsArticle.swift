import Fluent

struct CreateNewsArticle: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("news_articles")
            .id()
            .field("title", .string, .required)
            .field("summary", .string, .required)
            .field("source", .string, .required)
            .field("image_url", .string, .required)
            .field("published_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("news_articles").delete()
    }
}
