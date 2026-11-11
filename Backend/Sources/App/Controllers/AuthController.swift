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
        auth.post("reset-password", use: resetPassword)
    }

    // MARK: - Signup
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable func signup(req: Request) async throws -> StreamResponse<SignupResponse> {
        try SignupRequest.validate(content: req)
        let input = try req.content.decode(SignupRequest.self)
        
        let validatedName = try InputValidator.validateName(input.name)
        let validatedEmail = try InputValidator.validateEmail(input.email)
        let validatedPhone = try InputValidator.validatePhone(input.phone)
        try InputValidator.validatePassword(input.password)
        let validatedPin = try InputValidator.validatePin(input.pin)
        
        // Check if user exists
        if let _ = try await User.query(on: req.db)
            .filter(\.$email == validatedEmail)
            .first() {
            throw Abort(.conflict, reason: "An account with this email already exists.")
        }
        
        // Hash password
        let hashedPassword = try Bcrypt.hash(input.password)
        
        // Create user
        let user = User(
            name: validatedName,
            email: validatedEmail,
            phone: validatedPhone,
            pin: validatedPin,
            passwordHash: hashedPassword,
            balance: 100000.0 // Starting balance in RWF
        )
        
        try await user.save(on: req.db)
        EmailService.shared.sendWelcomeEmail(to: user.email, name: user.name)
        return StreamResponse(success: true, message: "Account created successfully!", data: SignupResponse(message: "Success"))
    }

    // MARK: - Login
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable func login(req: Request) async throws -> StreamResponse<LoginResponse> {
        let loginRequest = try req.content.decode(LoginRequest.self)
        let validatedEmail = try InputValidator.validateEmail(loginRequest.email)
        
        guard !loginRequest.password.isEmpty && loginRequest.password.count <= 128 else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == validatedEmail)
            .first() else {
                throw Abort(.unauthorized, reason: "Invalid email or password")
            }
        
        let isPasswordCorrect = try Bcrypt.verify(loginRequest.password, created: user.passwordHash)
        guard isPasswordCorrect else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }
        
        let payload = UserPayload(
            sub: .init(value: user.id!.uuidString),
            name: user.name,
            email: user.email,
            tokenVersion: user.tokenVersion
        )
        
        let token = try req.jwt.sign(payload)
        return StreamResponse(success: true, message: "Login successful", data: LoginResponse(token: token))
    }

    // MARK: - Forgot Password
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable func forgotPassword(req: Request) async throws -> StreamResponse<ForgotPasswordResponse> {
        let input = try req.content.decode(ForgotPasswordRequest.self)
        let cleanEmail = try InputValidator.validateEmail(input.email)
        
        if let user = try await User.query(on: req.db)
            .filter(\.$email == cleanEmail)
            .first() {
            let code = await PasswordResetManager.shared.createResetCode(for: cleanEmail)
            EmailService.shared.sendPasswordResetEmail(to: cleanEmail, code: code, name: user.name)
        }
        
        return StreamResponse(
            success: true, 
            message: "If an account exists for \(cleanEmail), a 6-digit password reset code has been sent to your email.", 
            data: ForgotPasswordResponse(message: "Sent")
        )
    }

    // MARK: - Reset Password
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable func resetPassword(req: Request) async throws -> StreamResponse<ResetPasswordResponse> {
        let input = try req.content.decode(ResetPasswordRequest.self)
        let cleanEmail = try InputValidator.validateEmail(input.email)
        let cleanCode = try InputValidator.validateCode(input.code)
        try InputValidator.validatePassword(input.newPassword, fieldName: "New password")
        
        guard await PasswordResetManager.shared.verifyResetCode(code: cleanCode, for: cleanEmail) else {
            throw Abort(.badRequest, reason: "The verification code is incorrect or has expired. Please check your email or request a new code.")
        }
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == cleanEmail)
            .first() else {
            throw Abort(.notFound, reason: "Account not found.")
        }
        
        let hashedPassword = try Bcrypt.hash(input.newPassword)
        user.passwordHash = hashedPassword
        try await user.save(on: req.db)
        await PasswordResetManager.shared.clearCode(for: cleanEmail)
        
        EmailService.shared.sendEmail(
            to: cleanEmail,
            subject: "Your Stream Password Has Been Reset",
            body: """
            Hello \(user.name),

            Your Stream Mobile Banking password was successfully reset. You can now log in using your new password.

            If you did not make this change, please contact support immediately.

            Best regards,
            The Stream Banking Team
            """
        )
        
        return StreamResponse(
            success: true, 
            message: "Your password has been reset successfully. You can now sign in.", 
            data: ResetPasswordResponse(message: "Success")
        )
    }
}

// MARK: - Data Transfer Objects (DTOs)

struct ResetPasswordRequest: Content {
    let email: String
    let code: String
    let newPassword: String
}

struct ResetPasswordResponse: Content {
    let message: String
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
