// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "TungaBackend",
    platforms: [
       .macOS(.v13) // Keeping v13 as requested
    ],
    dependencies: [
        // 💧 Vapor - Updated to latest 4.x for better Swift 6 support
        .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
        // 🗄 Fluent
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🗄 PostgreSQL Driver
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        // 🔐 JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "JWT", package: "jwt"),
            ],
            swiftSettings: [
                // This helps manage the transition to Swift 6 concurrency
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: [
                .target(name: "App")
            ],
            path: "Sources/Run"  
        )
    ]
)
