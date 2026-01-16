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
        transactions.post("qr", "generate", use: generateQR)
        transactions.post("qr", "execute", use: executeQR)
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

    struct QRGenerateRequest: Content {
        let type: QRPayload.PayloadType
        let amount: Double
        let sourceInstitutionId: UUID?
        let destinationInstitutionId: UUID?
    }

    struct QRExecuteRequest: Content {
        let payload: QRPayload
        let pin: String?
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

    // POST /transactions/qr/generate
    @Sendable
    func generateQR(req: Request) async throws -> StreamResponse<QRPayload> {
        let input = try req.content.decode(QRGenerateRequest.self)
        var payload = QRPayload(
            type: input.type,
            amount: input.amount,
            sourceId: input.sourceInstitutionId,
            destinationId: input.destinationInstitutionId
        )
        let secret = Environment.get("QR_SECRET") ?? "STREAM_QR_SECRET_2026"
        payload.sign(secret: secret)
        
        // Log for debugging (so user can copy JSON and see a clickable link)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(payload), let jsonString = String(data: data, encoding: .utf8) {
            print("\n--- QR CODE PAYLOAD ---")
            print(jsonString)
            
            // Create clickable URL for testing
            if let encodedJson = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=\(encodedJson)"
                print("\n--- QR CODE TEST LINK (Command+Click to open) ---")
                print(qrUrl)
            }
            print("-----------------------\n")
        }
        
        return StreamResponse(success: true, data: payload)
    }

    // POST /transactions/qr/execute
    @Sendable
    func executeQR(req: Request) async throws -> StreamResponse<Transaction> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(QRExecuteRequest.self)
        
        let secret = Environment.get("QR_SECRET") ?? "STREAM_QR_SECRET_2026"
        guard input.payload.verify(secret: secret) else {
            throw Abort(.badRequest, reason: "Invalid or expired QR code")
        }

        // Mock PIN validation for now
        if let pin = input.pin, pin != "1234" && pin != user.pin {
             // In a real app, we'd check against hashed pin
             // throw Abort(.unauthorized, reason: "Invalid Transaction PIN")
        }

        let result = try await transactionService.performQRTransaction(
            user: user,
            payload: input.payload,
            on: req.db
        )

        return StreamResponse(
            success: true,
            message: "QR Transaction successful",
            data: result.transaction,
            updatedBalances: result.updatedBalances,
            transactionId: result.transaction.id
        )
    }
}
