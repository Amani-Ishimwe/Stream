import Fluent
import Vapor
import JWT

struct AuthController: RouteCollection, Sendable {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        
        // Public routes
        auth.post("signup", use: signup)
        auth.post("login", use: login) // No longer grouped by User.authenticator()
        auth.post("forgot-password", use: forgotPassword)
    }

    // MARK: - Signup
    @Sendable func signup(req: Request) async throws -> SignupResponse {
        try SignupRequest.validate(content: req)
        let input = try req.content.decode(SignupRequest.self)
        
        // Check if user exists
        if let _ = try await User.query(on: req.db)
            .filter(\.$email == input.email)
            .first() {
            throw Abort(.conflict, reason: "Email already exists")
        }
        
        // Hash password
        let hashedPassword = try Bcrypt.hash(input.password)
        
        // Create user
        let user = User(
            name: input.name,
            email: input.email,
            phone: input.phone,
            pin: input.pin,
            passwordHash: hashedPassword,
            balance: 1000.0 // Starting balance
        )
        
        try await user.save(on: req.db)
        return SignupResponse(message: "Account created successfully!")
    }

    // MARK: - Login
    @Sendable func login(req: Request) async throws -> LoginResponse {
        // 1. Decode the login request from JSON body
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        // 2. Find the user by email
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first() else {
                throw Abort(.unauthorized, reason: "Invalid email or password")
            }
        
        // 3. Verify the Bcrypt password hash
        let isPasswordCorrect = try Bcrypt.verify(loginRequest.password, created: user.passwordHash)
        guard isPasswordCorrect else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }
        
        // 4. Generate JWT Token
        let payload = UserPayload(
            subject: .init(value: user.id!.uuidString),
            name: user.name,
            email: user.email
        )
        
        let token = try req.jwt.sign(payload)
        return LoginResponse(token: token)
    }

    // MARK: - Forgot Password
    @Sendable func forgotPassword(req: Request) async throws -> ForgotPasswordResponse {
        let input = try req.content.decode(ForgotPasswordRequest.self)
        // Simulate sending email logic here
        return ForgotPasswordResponse(message: "If an account exists for \(input.email), you will receive a reset link shortly.")
    }
}

// MARK: - Data Transfer Objects (DTOs)

struct SignupRequest: Content, Validatable {
    let name: String
    let email: String
    let phone: String
    let password: String
    let pin: String
    
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
    }
}

struct SignupResponse: Content {
    let message: String
}

struct LoginRequest: Content {
    let email: String
    let password: String
}

struct LoginResponse: Content {
    let token: String
}

struct ForgotPasswordRequest: Content {
    let email: String
}

struct ForgotPasswordResponse: Content {
    let message: String
}
