import Fluent
import Vapor

struct InstitutionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let institutions = routes.grouped("institutions")
        institutions.get(use: index)
        // Toggle Freeze
        institutions.post(":institutionID", "freeze", use: toggleFreeze)
    }
    
    // POST /institutions/:id/freeze
    func toggleFreeze(req: Request) async throws -> StreamResponse<InstitutionDTO> {
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()
        
        guard let institutionIDStr = req.parameters.get("institutionID"),
              let institutionID = UUID(uuidString: institutionIDStr) else {
            throw Abort(.badRequest, reason: "Invalid Institution ID")
        }
        
        guard let linked = try await LinkedAccount.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$institution.$id == institutionID)
            .with(\.$institution)
            .first() else {
            throw Abort(.notFound, reason: "Account not found")
        }
        
        // Toggle
        linked.isFrozen.toggle()
        try await linked.save(on: req.db)
        
        let dto = InstitutionDTO(
            id: linked.institution.id!,
            name: linked.institution.name,
            type: linked.institution.type,
            iconSymbol: linked.institution.iconSymbol,
            primaryColorHex: linked.institution.primaryColorHex,
            balance: linked.balance,
            accountNumber: linked.accountNumber,
            lastSynced: linked.lastSynced,
            isFrozen: linked.isFrozen
        )
        
        return StreamResponse(success: true, message: "Card \(linked.isFrozen ? "frozen" : "unfrozen") successfully", data: dto)
    }

    // DTO: Returns Institution details + User's specific balance
    struct InstitutionDTO: Content {
        let id: UUID
        let name: String
        let type: String
        let iconSymbol: String
        let primaryColorHex: String
        let balance: Double 
        let accountNumber: String?
        let lastSynced: Date?
        let isFrozen: Bool
    }
    
    // GET /institutions
    func index(req: Request) async throws -> StreamResponse<[InstitutionDTO]> {
        let linkedAccounts = try await LinkedAccount.query(on: req.db)
            .with(\.$institution)
            .all()
        
        let dtos = linkedAccounts.map { linked in
            return InstitutionDTO(
                id: linked.institution.id!,
                name: linked.institution.name,
                type: linked.institution.type,
                iconSymbol: linked.institution.iconSymbol,
                primaryColorHex: linked.institution.primaryColorHex,
                balance: linked.balance,
                accountNumber: linked.accountNumber,
                lastSynced: linked.lastSynced,
                isFrozen: linked.isFrozen
            )
        }
        
        return StreamResponse(success: true, data: dtos)
    }
}
