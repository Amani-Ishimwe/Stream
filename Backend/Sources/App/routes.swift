import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "SwiftPay Plus Backend is running!"
    }

    try app.register(collection: AuthController())
    try app.register(collection: WalletController())
    try app.register(collection: NewsController())
    try app.register(collection: UserController())
}
