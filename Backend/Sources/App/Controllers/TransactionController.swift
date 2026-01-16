import Fluent
import Vapor

struct TransactionController: RouteCollection {
    let transactionService = TransactionService()
    
    func boot(routes: RoutesBuilder) throws {
        let transactions = routes.grouped("transactions").grouped(SessionValidationMiddleware())
        transactions.get(use: index)
        transactions.post("send", use: sendMoney)
        transactions.post("topup", use: topUp)
        transactions.post("request", use: requestMoney)
    }

    // GET /transactions
    @Sendable
    func index(req: Request) async throws -> StreamResponse<[Transaction]> {
        let user = try req.auth.require(User.self)
        let transactions = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .sort(\.$createdAt, .descending)
            .all()
        return StreamResponse(success: true, data: transactions)
    }

    // DTOs
    struct SendMoneyRequest: Content {
        let sourceInstitutionId: UUID
        let amount: Double
        let recipient: String
        let metadata: [String: String]?
    }

    struct TopUpRequest: Content {
        let sourceInstitutionId: UUID
        let destinationInstitutionId: UUID
        let amount: Double
    }

    struct RequestMoneyRequest: Content {
        let destinationInstitutionId: UUID
        let amount: Double
        let payer: String
    }
    
    // POST /transactions/send
    @Sendable
    func sendMoney(req: Request) async throws -> StreamResponse<Transaction> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(SendMoneyRequest.self)
        let result = try await transactionService.performSend(
            user: user,
            sourceID: input.sourceInstitutionId,
            amount: input.amount,
            recipient: input.recipient,
            metadata: input.metadata,
            on: req.db
        )
        return StreamResponse(
            success: true,
            message: "Transfer successful",
            data: result.transaction,
            updatedBalances: result.updatedBalances,
            transactionId: result.transaction.id
        )
    }
    
    // POST /transactions/topup
    @Sendable
    func topUp(req: Request) async throws -> StreamResponse<Transaction> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(TopUpRequest.self)
        let result = try await transactionService.performTopUp(
            user: user,
            sourceID: input.sourceInstitutionId,
            destinationID: input.destinationInstitutionId,
            amount: input.amount,
            on: req.db
        )
        return StreamResponse(
            success: true,
            message: "Top-Up successful",
            data: result.transaction,
            updatedBalances: result.updatedBalances,
            transactionId: result.transaction.id
        )
    }
    
    // POST /transactions/request
    @Sendable
    func requestMoney(req: Request) async throws -> StreamResponse<Transaction> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(RequestMoneyRequest.self)
        let result = try await transactionService.performRequest(
            user: user,
            destinationID: input.destinationInstitutionId,
            amount: input.amount,
            payer: input.payer,
            on: req.db
        )
        return StreamResponse(
            success: true,
            message: "Request sent successfully",
            data: result.transaction,
            updatedBalances: result.updatedBalances,
            transactionId: result.transaction.id
        )
    }
}
