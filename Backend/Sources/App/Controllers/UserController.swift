import Fluent
import Vapor

struct UserController: RouteCollection, Sendable {
    func boot(routes: RoutesBuilder) throws {
        let user = routes.grouped("user")
        
        // Protect user routes with custom session validation middleware
        let tokenProtected = user.grouped(SessionValidationMiddleware())
        
        tokenProtected.get("profile", use: getProfile)
        tokenProtected.put("profile", use: updateProfile)
        tokenProtected.post("pin", use: changePin)
        tokenProtected.post("terminate-sessions", use: terminateSessions)
    }
    
    // Helper to get user from request (SessionValidationMiddleware already logged them in)
    private func getUser(req: Request) throws -> User {
        try req.auth.require(User.self)
    }
    
    @Sendable func getProfile(req: Request) async throws -> StreamResponse<UserProfileResponse> {
        let user = try getUser(req: req)
        let profile = UserProfileResponse(
            id: user.id!,
            name: user.name,
            email: user.email,
            phone: user.phone,
            balance: user.balance,
            avatarUrl: user.avatarUrl
        )
        return StreamResponse(success: true, data: profile)
    }
    
    @Sendable func updateProfile(req: Request) async throws -> StreamResponse<EmptyResponse> {
        let user = try getUser(req: req)
        let input = try req.content.decode(UpdateProfileRequest.self)
        
        let validatedName = try InputValidator.validateName(input.name)
        let validatedPhone = try InputValidator.validatePhone(input.phone)
        let validatedAvatar = try InputValidator.validateUrl(input.avatarUrl)
        
        user.name = validatedName
        user.phone = validatedPhone
        user.avatarUrl = validatedAvatar
        try await user.save(on: req.db)
        
        return StreamResponse(success: true, message: "Profile updated successfully")
    }
    
    @Sendable func changePin(req: Request) async throws -> StreamResponse<EmptyResponse> {
        let user = try getUser(req: req)
        let input = try req.content.decode(ChangePinRequest.self)
        
        let validatedOldPin = try InputValidator.validatePin(input.oldPin, fieldName: "Current PIN")
        let validatedNewPin = try InputValidator.validatePin(input.newPin, fieldName: "New PIN")
        
        guard user.pin == validatedOldPin else {
            throw Abort(.unauthorized, reason: "Current PIN is incorrect. Please try again.")
        }
        
        guard validatedNewPin != validatedOldPin else {
            throw Abort(.badRequest, reason: "New PIN must be different from your current PIN.")
        }
        
        user.pin = validatedNewPin
        try await user.save(on: req.db)
        
        return StreamResponse(success: true, message: "PIN changed successfully")
    }

    @Sendable func terminateSessions(req: Request) async throws -> StreamResponse<EmptyResponse> {
        let user = try getUser(req: req)
        
        user.tokenVersion += 1
        try await user.save(on: req.db)
        
        return StreamResponse(success: true, message: "All sessions terminated successfully")
    }
}

// DTOs
struct UserProfileResponse: Content {
    let id: UUID
    let name: String
    let email: String
    let phone: String
    let balance: Double
    let avatarUrl: String?
}

struct UpdateProfileRequest: Content {
    let name: String
    let phone: String
    let avatarUrl: String?
}

struct ChangePinRequest: Content {
    let oldPin: String
    let newPin: String
}

struct MessageResponse: Content {
    let message: String
}
