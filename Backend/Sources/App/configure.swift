import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // Middleware
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    // Request Logging
    app.middleware.use(AppLoggerMiddleware()) // Custom logger
    
    // JSON Strategy
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    // Database
    app.databases.use(.postgres(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        port: Environment.get("DB_PORT").flatMap(Int.init(_:)) ?? 5432,
        username: Environment.get("DB_USERNAME") ?? "postgres",
        password: Environment.get("DB_PASSWORD") ?? "tequiero2024",
        database: Environment.get("DB_NAME") ?? "TUngaDB"
    ), as: .psql)

    // Migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateTransaction())
    app.migrations.add(CreateNewsArticle())
    app.migrations.add(CreateNotification()) // [NEW]
    app.migrations.add(CreateInstitution()) // [NEW]
    app.migrations.add(AddInstitutionFieldsToTransaction())
    app.migrations.add(CreateLinkedAccount())
    app.migrations.add(AddIsFrozenToLinkedAccount()) // [NEW]
    
    // Auto-migrate for demo purposes
    // Auto-migrate in development
    if app.environment == .development {
        try await app.autoMigrate()
    } else {
        try await app.autoMigrate() // Keep original behavior for non-dev if not explicitly removed
    }
    
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
