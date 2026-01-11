import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        port: Environment.get("DB_PORT").flatMap(Int.init(_:)) ?? 5432,
        username: Environment.get("DB_USERNAME") ?? "postgres",
        password: Environment.get("DB_PASSWORD") ?? "tequiero2024",
        database: Environment.get("DB_NAME") ?? "TUngaDB"
    ), as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateTransaction())
    app.migrations.add(CreateNewsArticle())
    
    // Auto-migrate for demo purposes
    try await app.autoMigrate()
    
    // Seed data
    try await SeedData.seed(on: app.db)
    
    // Authentication
    app.middleware.use(User.authenticator())
    
    // JWT Configuration
    let jwtSecret = Environment.get("JWT_SECRET") ?? "SECRET_KEY_DEV"
    app.jwt.signers.use(.hs256(key: jwtSecret))

    // register routes
    try routes(app)
}
