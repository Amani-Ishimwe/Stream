import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "SwiftPay Plus Backend is running!"
    }

    app.get("health") { req -> [String: String] in
        return ["status": "ok"]
    }
    
    try app.register(collection: UserController())
    try app.register(collection: AuthController()) // [NEW]
    try app.register(collection: TransactionController())
    try app.register(collection: NewsController())
    try app.register(collection: InstitutionController()) // [NEW]
    try app.register(collection: NotificationController()) // [NEW]
}
