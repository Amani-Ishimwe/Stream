import Fluent
import Vapor

struct NotificationController: RouteCollection, Sendable {
    func boot(routes: RoutesBuilder) throws {
        let notifications = routes.grouped("notifications")
        
        let protected = notifications.grouped(
            UserPayload.authenticator(),
            UserPayload.guardMiddleware()
        )
        
        protected.get(use: getNotifications)
        protected.post(":id", "read", use: markAsRead)
    }
    
    // Helper to get user from token
    private func getUser(req: Request) async throws -> User {
        let payload = try req.auth.require(UserPayload.self)
        
        guard let user = try await User.find(UUID(uuidString: payload.sub.value), on: req.db) else {
            throw Abort(.unauthorized, reason: "User not found")
        }
        return user
    }
    
    @Sendable func getNotifications(req: Request) async throws -> StreamResponse<[Notification]> {
        let user = try await getUser(req: req)
        
        let notifications = try await Notification.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .sort(\.$createdAt, .descending)
            .all()
        return StreamResponse(success: true, data: notifications)
    }
    
    @Sendable func markAsRead(req: Request) async throws -> StreamResponse<EmptyResponse> {
        let user = try await getUser(req: req)
        
        guard let notificationID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Notification ID")
        }
        
        guard let notification = try await Notification.find(notificationID, on: req.db),
              notification.$user.id == user.id else {
            throw Abort(.notFound, reason: "Notification not found")
        }
        
        notification.isRead = true
        try await notification.save(on: req.db)
        
        return StreamResponse(success: true, message: "Notification marked as read")
    }
}
