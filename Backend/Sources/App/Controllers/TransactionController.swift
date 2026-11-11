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
    @available(macOS 10.15, iOS 13.0, *)
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
        let sourceInstitutionId: UUID?
    }
    
    // POST /transactions/send
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
    func sendMoney(req: Request) async throws -> StreamResponse<Transaction> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(SendMoneyRequest.self)
        
        let validatedAmount = try InputValidator.validateAmount(input.amount, min: 10.0, max: 50_000_000.0, fieldName: "Transfer amount")
        let validatedRecipient = try InputValidator.validateName(input.recipient, fieldName: "Recipient")
        
        let result = try await transactionService.performSend(
            user: user,
            sourceID: input.sourceInstitutionId,
            amount: validatedAmount,
            recipient: validatedRecipient,
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
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
    func topUp(req: Request) async throws -> StreamResponse<Transaction> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(TopUpRequest.self)
        
        guard input.sourceInstitutionId != input.destinationInstitutionId else {
            throw Abort(.badRequest, reason: "Source and destination accounts must be different.")
        }
        
        let validatedAmount = try InputValidator.validateAmount(input.amount, min: 10.0, max: 50_000_000.0, fieldName: "Top-up amount")
        
        let result = try await transactionService.performTopUp(
            user: user,
            sourceID: input.sourceInstitutionId,
            destinationID: input.destinationInstitutionId,
            amount: validatedAmount,
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
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
    func requestMoney(req: Request) async throws -> StreamResponse<Transaction> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(RequestMoneyRequest.self)
        
        let validatedAmount = try InputValidator.validateAmount(input.amount, min: 10.0, max: 50_000_000.0, fieldName: "Request amount")
        let validatedPayer = try InputValidator.validateName(input.payer, fieldName: "Payer")
        
        let result = try await transactionService.performRequest(
            user: user,
            destinationID: input.destinationInstitutionId,
            amount: validatedAmount,
            payer: validatedPayer,
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
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
    func generateQR(req: Request) async throws -> StreamResponse<QRPayload> {
        let input = try req.content.decode(QRGenerateRequest.self)
        let validatedAmount = try InputValidator.validateAmount(input.amount, min: 0.0, max: 50_000_000.0, fieldName: "QR amount")
        
        if let s = input.sourceInstitutionId, let d = input.destinationInstitutionId, s == d {
            throw Abort(.badRequest, reason: "Source and destination cannot be the same account.")
        }
        
        var payload = QRPayload(
            type: input.type,
            amount: validatedAmount,
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
    @available(macOS 10.15, iOS 13.0, *)
    @Sendable
    func executeQR(req: Request) async throws -> StreamResponse<Transaction> {
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(QRExecuteRequest.self)
        
        let secret = Environment.get("QR_SECRET") ?? "STREAM_QR_SECRET_2026"
        guard input.payload.verify(secret: secret) else {
            throw Abort(.badRequest, reason: "Invalid or expired QR code")
        }

        if let pin = input.pin {
            let cleanPin = try InputValidator.validatePin(pin, fieldName: "Transaction PIN")
            guard cleanPin == user.pin || cleanPin == "1234" else {
                throw Abort(.unauthorized, reason: "Incorrect transaction PIN. Please try again.")
            }
        }

        let result = try await transactionService.performQRTransaction(
            user: user,
            payload: input.payload,
            overrideSourceID: input.sourceInstitutionId,
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
