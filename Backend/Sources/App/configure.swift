import Fluent
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {

    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = Environment.get("PORT").flatMap(Int.init) ?? 8080


    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    app.middleware.use(AppLoggerMiddleware())
    
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    if let databaseURL = Environment.get("DATABASE_URL"), !databaseURL.isEmpty {
        app.logger.info("Configuring PostgreSQL connection using DATABASE_URL...")
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
        let hostname = Environment.get("DB_HOST") ?? "localhost"
        let port = Environment.get("DB_PORT").flatMap(Int.init) ?? 5432
        let username = Environment.get("DB_USERNAME") ?? "postgres"
        let password = Environment.get("DB_PASSWORD") ?? "tequiero2024"
        let database = Environment.get("DB_NAME") ?? "TUngaDB"

        app.logger.warning("DATABASE_URL environment variable is not set. Falling back to default host: \(hostname):\(port)")
        app.databases.use(.postgres(
            hostname: hostname,
            port: port,
            username: username,
            password: password,
            database: database
        ), as: .psql)
    }


    app.migrations.add(CreateUser())
    app.migrations.add(CreateTransaction())
    app.migrations.add(CreateNewsArticle())
    app.migrations.add(CreateNotification())
    app.migrations.add(CreateInstitution())
    app.migrations.add(AddInstitutionFieldsToTransaction())
    app.migrations.add(CreateLinkedAccount())
    app.migrations.add(AddIsFrozenToLinkedAccount())
    app.migrations.add(CreateEnhancementFields())
    
    try await app.autoMigrate()

    try await SeedData.seed(on: app.db)
  
    app.middleware.use(User.authenticator())
    
    let jwtSecret = Environment.get("JWT_SECRET") ?? "SECRET_KEY_DEV"
    app.jwt.signers.use(.hs256(key: jwtSecret))

    try routes(app)
}
