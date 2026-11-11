import Fluent
import Vapor

struct InstitutionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let institutions = routes.grouped("institutions").grouped(SessionValidationMiddleware())
        institutions.get(use: index)
        institutions.get("available", use: getAvailable)
        institutions.post("link", use: linkInstitution)
        institutions.get(":institutionID", use: getDetail)
        institutions.get(":institutionID", "transactions", use: getTransactions)
        institutions.post(":institutionID", "freeze", use: toggleFreeze)
        institutions.post(":institutionID", "limits", use: updateLimits)
    }
    
    struct UpdateLimitsRequest: Content {
        let dailyLimit: Double
        let monthlyLimit: Double
    }

    // POST /institutions/:id/limits
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
    func updateLimits(req: Request) async throws -> StreamResponse<InstitutionDTO> {
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()
        let instID = try req.parameters.require("institutionID", as: UUID.self)
        let input = try req.content.decode(UpdateLimitsRequest.self)
        let validatedLimits = try InputValidator.validateLimits(daily: input.dailyLimit, monthly: input.monthlyLimit)
        
        guard let linked = try await LinkedAccount.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$institution.$id == instID)
            .with(\.$institution)
            .first() else {
            throw Abort(.notFound, reason: "Account not found.")
        }
        
        linked.dailyLimit = validatedLimits.daily
        linked.monthlyLimit = validatedLimits.monthly
        try await linked.save(on: req.db)
        
        return StreamResponse(success: true, message: "Limits updated successfully", data: InstitutionDTO(linked: linked))
    }
    
    // GET /institutions/available
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
    func getAvailable(req: Request) async throws -> StreamResponse<[Institution]> {
        let all = try await Institution.query(on: req.db).filter(\.$isActive == true).all()
        return StreamResponse(success: true, data: all)
    }

    struct LinkRequest: Content {
        let institutionId: UUID
        let balance: Double?
    }

    // POST /institutions/link
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
    func linkInstitution(req: Request) async throws -> StreamResponse<InstitutionDTO> {
        let user = try req.auth.require(User.self)
        let userId = try user.requireID()
        let input = try req.content.decode(LinkRequest.self)
        
        // Check if already linked
        let existing = try await LinkedAccount.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$institution.$id == input.institutionId)
            .first()
        
        if existing != nil {
            throw Abort(.badRequest, reason: "Institution already linked")
        }
        
        guard try await Institution.find(input.institutionId, on: req.db) != nil else {
            throw Abort(.notFound, reason: "Institution not found")
        }
        
        var initialBalance: Double = 0.0
        if let bal = input.balance {
            initialBalance = try InputValidator.validateAmount(bal, min: 0.0, max: 100_000_000.0, fieldName: "Initial balance")
        }
        
        let newLinked = LinkedAccount(
            userID: userId,
            institutionID: input.institutionId,
            accountNumber: "STREAM-\(Int.random(in: 1000...9999))-\(Int.random(in: 1000...9999))",
            balance: initialBalance,
            dailyLimit: 2000000,
            monthlyLimit: 10000000
        )
        
        try await newLinked.save(on: req.db)
        
        // Reload with institution for DTO
        guard let reloaded = try await LinkedAccount.query(on: req.db)
            .filter(\.$id == newLinked.id!)
            .with(\.$institution)
            .first() else {
            throw Abort(.internalServerError)
        }
        
        return StreamResponse(success: true, message: "Institution linked successfully", data: InstitutionDTO(linked: reloaded))
    }
    
    // POST /institutions/:id/freeze
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
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
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
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
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
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
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
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
