import Fluent
import Vapor

struct UserController: RouteCollection, Sendable {
    func boot(routes: RoutesBuilder) throws {
        let user = routes.grouped("user")
        
        // Protect user routes with JWT middleware
        let tokenProtected = user.grouped(UserPayload.authenticator(), UserPayload.guardMiddleware())
        
        tokenProtected.get("profile", use: getProfile)
        tokenProtected.put("profile", use: updateProfile)
        tokenProtected.post("pin", use: changePin)
    }
    
    // Helper to get user from token
    private func getUser(req: Request) async throws -> User {
        let payload = try req.auth.require(UserPayload.self)
        
        guard let user = try await User.find(UUID(uuidString: payload.subject.value), on: req.db) else {
            throw Abort(.unauthorized, reason: "User not found")
        }
        return user
    }
    
    @Sendable func getProfile(req: Request) async throws -> UserProfileResponse {
        let user = try await getUser(req: req)
        return UserProfileResponse(
            id: user.id!,
            name: user.name,
            email: user.email,
            phone: user.phone,
            balance: user.balance
        )
    }
    
    @Sendable func updateProfile(req: Request) async throws -> MessageResponse {
        let user = try await getUser(req: req)
        let input = try req.content.decode(UpdateProfileRequest.self)
        
        user.name = input.name
        user.phone = input.phone
        try await user.save(on: req.db)
        
        return MessageResponse(message: "Profile updated successfully")
    }
    @Sendable func changePin(req: Request) async throws -> MessageResponse {
        let user = try await getUser(req: req)
        let input = try req.content.decode(ChangePinRequest.self)
        
        guard user.pin == input.oldPin else {
            throw Abort(.unauthorized, reason: "Incorrect old PIN")
        }
        
        guard input.newPin.count == 4 && input.newPin.allSatisfy({ $0.isNumber }) else {
            throw Abort(.badRequest, reason: "PIN must be 4 digits")
        }
        
        user.pin = input.newPin
        try await user.save(on: req.db)
        
        return MessageResponse(message: "PIN changed successfully")
    }
}

// DTOs
struct UserProfileResponse: Content {
    let id: UUID
    let name: String
    let email: String
    let phone: String
    let balance: Double
}

struct UpdateProfileRequest: Content {
    let name: String
    let phone: String
}

struct ChangePinRequest: Content {
    let oldPin: String
    let newPin: String
}

struct MessageResponse: Content {
    let message: String
}
