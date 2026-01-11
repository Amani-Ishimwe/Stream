import Fluent
import Vapor

struct WalletController: RouteCollection, Sendable {

    // MARK: - Routes
    func boot(routes: RoutesBuilder) throws {
        let wallet = routes.grouped("wallet")

        let protected = wallet.grouped(
            UserPayload.authenticator(),
            UserPayload.guardMiddleware()
        )

        protected.get("balance", use: getBalance)
        protected.get("transactions", use: getTransactions)
        protected.post("send", use: sendMoney)
        protected.post("topup", use: topUp)
        protected.post("withdraw", use: withdraw)
    }

    // MARK: - Helper (FIXED SCOPE)
    private func getUser(_ req: Request) async throws -> User {
        let payload = try req.auth.require(UserPayload.self)

        guard
            let userID = UUID(uuidString: payload.subject.value),
            let user = try await User.find(userID, on: req.db)
        else {
            throw Abort(.unauthorized, reason: "User not found")
        }

        return user
    }

    // MARK: - Balance
    @Sendable func getBalance(req: Request) async throws -> BalanceResponse {
        let user = try await getUser(req)
        return BalanceResponse(balance: user.balance)
    }

    // MARK: - Transactions
    @Sendable func getTransactions(req: Request) async throws -> [Transaction] {
        let user = try await getUser(req)

        return try await Transaction.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .sort(\.$createdAt, .descending)
            .all()
    }

    // MARK: - Send Money
    @Sendable func sendMoney(req: Request) async throws -> SendMoneyResponse {
        let sender = try await getUser(req)
        let input = try req.content.decode(SendMoneyRequest.self)

        guard input.amount > 0 else {
            throw Abort(.badRequest, reason: "Amount must be positive")
        }

        guard sender.balance >= input.amount else {
            throw Abort(.badRequest, reason: "Insufficient funds")
        }

        guard sender.email != input.recipientEmail else {
            throw Abort(.badRequest, reason: "Cannot send money to yourself")
        }

        // ⚠️ For production: compare hashed PINs
        guard sender.pin == input.pin else {
            throw Abort(.unauthorized, reason: "Invalid PIN")
        }

        try await req.db.transaction { db in
            guard let recipient = try await User.query(on: db)
                .filter(\.$email == input.recipientEmail)
                .first()
            else {
                throw Abort(.notFound, reason: "Recipient not found")
            }

            sender.balance -= input.amount
            recipient.balance += input.amount

            try await sender.save(on: db)
            try await recipient.save(on: db)

            try await Transaction(
                userID: sender.requireID(),
                type: "SEND",
                amount: -input.amount,
                description: input.note ?? "Transfer to \(recipient.name)",
                counterparty: recipient.name
            ).save(on: db)

            try await Transaction(
                userID: recipient.requireID(),
                type: "RECEIVE",
                amount: input.amount,
                description: input.note ?? "Transfer from \(sender.name)",
                counterparty: sender.name
            ).save(on: db)
        }

        return SendMoneyResponse(message: "Transfer successful")
    }

    // MARK: - Top Up
    @Sendable func topUp(req: Request) async throws -> BalanceResponse {
        let user = try await getUser(req)
        let input = try req.content.decode(TopUpRequest.self)

        guard input.amount > 0 else {
            throw Abort(.badRequest, reason: "Amount must be positive")
        }

        try await req.db.transaction { db in
            user.balance += input.amount
            try await user.save(on: db)

            try await Transaction(
                userID: user.requireID(),
                type: "TOPUP",
                amount: input.amount,
                description: "Top-up via \(input.method)",
                counterparty: input.method
            ).save(on: db)
        }

        return BalanceResponse(balance: user.balance)
    }

    // MARK: - Withdraw
    @Sendable func withdraw(req: Request) async throws -> BalanceResponse {
        let user = try await getUser(req)
        let input = try req.content.decode(WithdrawRequest.self)

        guard input.amount > 0 else {
            throw Abort(.badRequest, reason: "Amount must be positive")
        }

        guard user.balance >= input.amount else {
            throw Abort(.badRequest, reason: "Insufficient funds")
        }

        try await req.db.transaction { db in
            user.balance -= input.amount
            try await user.save(on: db)

            try await Transaction(
                userID: user.requireID(),
                type: "WITHDRAW",
                amount: -input.amount,
                description: "Withdrawal to bank",
                counterparty: "Bank Transfer"
            ).save(on: db)
        }

        return BalanceResponse(balance: user.balance)
    }
}

// MARK: - DTOs (SAME FILE – SAFE)

struct BalanceResponse: Content {
    let balance: Double
}

struct SendMoneyRequest: Content {
    let recipientEmail: String
    let amount: Double
    let note: String?
    let pin: String
}

struct SendMoneyResponse: Content {
    let message: String
}

struct TopUpRequest: Content {
    let amount: Double
    let method: String
}

struct WithdrawRequest: Content {
    let amount: Double
}
