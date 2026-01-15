@preconcurrency import Fluent
@preconcurrency import Vapor
import JWT

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String
    
    @Field(key: "phone")
    var phone: String

    @Field(key: "pin")
    var pin: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "balance")
    var balance: Double

    init() { }

    init(id: UUID? = nil, name: String, email: String, phone: String, pin: String, passwordHash: String, balance: Double = 0.0) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.pin = pin
        self.passwordHash = passwordHash
        self.balance = balance
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

struct UserPayload: JWTPayload, Authenticatable {
    // Maps to the "sub" (subject) claim
    var sub: SubjectClaim
    var name: String
    var email: String
    
    func verify(using signer: JWTSigner) throws {
        // Here you can verify expiration, etc.
    }
}
