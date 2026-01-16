import Vapor
import Fluent

struct SessionValidationMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let payload = try? request.jwt.verify(as: UserPayload.self) else {
            return try await next.respond(to: request)
        }
        
        guard let userID = UUID(payload.sub.value) else {
            throw Abort(.unauthorized)
        }
        
        guard let user = try await User.find(userID, on: request.db) else {
            throw Abort(.unauthorized)
        }
        
        if user.tokenVersion != payload.tokenVersion {
            throw Abort(.unauthorized, reason: "Session has been terminated. Please log in again.")
        }
        
        request.auth.login(user)
        return try await next.respond(to: request)
    }
}
