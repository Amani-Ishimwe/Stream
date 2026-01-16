import Fluent
import Vapor

struct InstitutionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let institutions = routes.grouped("institutions").grouped(SessionValidationMiddleware())
        institutions.get(use: index)
        institutions.get(":institutionID", use: getDetail)
        institutions.get(":institutionID", "transactions", use: getTransactions)
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
        
        let dto = InstitutionDTO(linked: linked)
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
        let dailyLimit: Double
        let monthlyLimit: Double

        init(linked: LinkedAccount) {
            self.id = linked.institution.id!
            self.name = linked.institution.name
            self.type = linked.institution.type
            self.iconSymbol = linked.institution.iconSymbol
            self.primaryColorHex = linked.institution.primaryColorHex
            self.balance = linked.balance
            self.accountNumber = linked.accountNumber
            self.lastSynced = linked.lastSynced
            self.isFrozen = linked.isFrozen
            self.dailyLimit = linked.dailyLimit
            self.monthlyLimit = linked.monthlyLimit
        }
    }
    
    // GET /institutions
    func index(req: Request) async throws -> StreamResponse<[InstitutionDTO]> {
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()

        let linkedAccounts = try await LinkedAccount.query(on: req.db)
            .filter(\.$user.$id == userId)
            .with(\.$institution)
            .all()
        
        let dtos = linkedAccounts.map { InstitutionDTO(linked: $0) }
        return StreamResponse(success: true, data: dtos)
    }

    // GET /institutions/:id
    func getDetail(req: Request) async throws -> StreamResponse<InstitutionDTO> {
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()
        let instID = try req.parameters.require("institutionID", as: UUID.self)

        guard let linked = try await LinkedAccount.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$institution.$id == instID)
            .with(\.$institution)
            .first() else {
            throw Abort(.notFound)
        }

        return StreamResponse(success: true, data: InstitutionDTO(linked: linked))
    }

    // GET /institutions/:id/transactions
    func getTransactions(req: Request) async throws -> StreamResponse<[Transaction]> {
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()
        let instID = try req.parameters.require("institutionID", as: UUID.self)

        let transactions = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == userId)
            .group(.or) { group in
                group.filter(\.$sourceInstitutionID == instID)
                     .filter(\.$destinationInstitutionID == instID)
            }
            .sort(\.$createdAt, .descending)
            .all()

        return StreamResponse(success: true, data: transactions)
    }
}
