import Vapor
import Fluent

struct TransactionResult: Sendable {
    let transaction: Transaction
    let updatedBalances: [BalanceUpdate]
}

final class TransactionService: Sendable {
    // Helper to calculate spend within a time range
    private func getSpentAmount(userID: UUID, sourceID: UUID, since: Date, on db: Database) async throws -> Double {
        let txs = try await Transaction.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$sourceInstitutionID == sourceID)
            .filter(\.$createdAt >= since)
            .filter(\.$status == "Completed")
            .all()
        return txs.reduce(0) { $0 + abs($1.amount) }
    }

    // Top-Up: Source (Linked) -> Dest (Linked)
    func performTopUp(user: User, sourceID: UUID, destinationID: UUID, amount: Double, on db: Database) async throws -> TransactionResult {
        guard amount >= 10 else { throw Abort(.badRequest, reason: "Minimum transaction amount is 10 RWF") }
        let userID = try user.requireID()
        
        guard let sourceAccount = try await LinkedAccount.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$institution.$id == sourceID)
            .first() else {
            throw Abort(.notFound, reason: "Source account not linked.")
        }
        
        guard !sourceAccount.isFrozen else {
            throw Abort(.forbidden, reason: "Source account is frozen. Please contact support.")
        }
        
        guard let destAccount = try await LinkedAccount.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$institution.$id == destinationID)
            .first() else {
            throw Abort(.notFound, reason: "Destination account not linked.")
        }

        // Limit Checks
        let today = Calendar.current.startOfDay(for: Date())
        let dailySpent = try await getSpentAmount(userID: userID, sourceID: sourceID, since: today, on: db)
        if dailySpent + amount > sourceAccount.dailyLimit {
            throw Abort(.forbidden, reason: "Daily limit exceeded. Remaining: \(Int(sourceAccount.dailyLimit - dailySpent)) RWF")
        }

        guard sourceAccount.balance >= amount else {
            throw Abort(.badRequest, reason: "Insufficient balance.")
        }
        
        return try await db.transaction { transactionDB in
            sourceAccount.balance -= amount
            try await sourceAccount.save(on: transactionDB)
            
            destAccount.balance += amount
            try await destAccount.save(on: transactionDB)
            
            let transaction = Transaction(
                type: "TOPUP",
                amount: amount,
                description: "Internal Infusion",
                counterparty: "Self",
                status: "Completed",
                userID: userID,
                sourceInstitutionID: sourceID,
                destinationInstitutionID: destinationID
            )
            try await transaction.save(on: transactionDB)
            
            return TransactionResult(
                transaction: transaction,
                updatedBalances: [
                    BalanceUpdate(institutionId: sourceID, newBalance: sourceAccount.balance),
                    BalanceUpdate(institutionId: destinationID, newBalance: destAccount.balance)
                ]
            )
        }
    }
    
    // Send Money: Source (Linked) -> External
    func performSend(user: User, sourceID: UUID, amount: Double, recipient: String, metadata: [String: String]? = nil, on db: Database) async throws -> TransactionResult {
        guard amount >= 10 else { throw Abort(.badRequest, reason: "Minimum transaction amount is 10 RWF") }
        let userID = try user.requireID()
        
        guard let sourceAccount = try await LinkedAccount.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$institution.$id == sourceID)
            .first() else {
            throw Abort(.notFound, reason: "Source account not found.")
        }

        guard !sourceAccount.isFrozen else {
            throw Abort(.forbidden, reason: "Account is frozen.")
        }

        // Daily Limit Check
        let today = Calendar.current.startOfDay(for: Date())
        let dailySpent = try await getSpentAmount(userID: userID, sourceID: sourceID, since: today, on: db)
        if dailySpent + amount > sourceAccount.dailyLimit {
            throw Abort(.forbidden, reason: "Daily limit of \(Int(sourceAccount.dailyLimit)) RWF exceeded.")
        }
        
        guard sourceAccount.balance >= amount else {
            throw Abort(.badRequest, reason: "Insufficient funds.")
        }
        
        return try await db.transaction { transactionDB in
            sourceAccount.balance -= amount
            try await sourceAccount.save(on: transactionDB)
            
            let transaction = Transaction(
                type: "SEND",
                amount: -amount,
                description: "Transfer to \(recipient)",
                counterparty: recipient,
                status: "Completed",
                userID: userID,
                sourceInstitutionID: sourceID,
                destinationInstitutionID: nil,
                metadata: metadata
            )
            try await transaction.save(on: transactionDB)
            
            return TransactionResult(
                transaction: transaction,
                updatedBalances: [
                    BalanceUpdate(institutionId: sourceID, newBalance: sourceAccount.balance)
                ]
            )
        }
    }
    
    // Request Money: External -> Dest (Linked)
    func performRequest(user: User, destinationID: UUID, amount: Double, payer: String, on db: Database) async throws -> TransactionResult {
        guard amount >= 10 else { throw Abort(.badRequest, reason: "Minimum request amount is 10 RWF") }
        let userID = try user.requireID()
        
        guard let destAccount = try await LinkedAccount.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$institution.$id == destinationID)
            .first() else {
            throw Abort(.notFound, reason: "Destination account not found.")
        }
        
        return try await db.transaction { transactionDB in
            destAccount.balance += amount
            try await destAccount.save(on: transactionDB)
            
            let transaction = Transaction(
                type: "RECEIVE",
                amount: amount,
                description: "Asset Request from \(payer)",
                counterparty: payer,
                status: "Completed",
                userID: userID,
                sourceInstitutionID: nil,
                destinationInstitutionID: destinationID
            )
            try await transaction.save(on: transactionDB)
            
            return TransactionResult(
                transaction: transaction,
                updatedBalances: [
                    BalanceUpdate(institutionId: destinationID, newBalance: destAccount.balance)
                ]
            )
        }
    }

    // Dispatcher for QR-originated transactions
    func performQRTransaction(user: User, payload: QRPayload, overrideSourceID: UUID? = nil, on db: Database) async throws -> TransactionResult {
        switch payload.type {
        case .send:
            let sourceId = overrideSourceID ?? payload.sourceId
            guard let sid = sourceId else { throw Abort(.badRequest, reason: "Source ID missing for SEND") }
            return try await performSend(
                user: user,
                sourceID: sid,
                amount: payload.amount,
                recipient: "QR Recipient",
                metadata: ["source": "QR_SCAN"],
                on: db
            )
        case .request:
            guard let destId = payload.destinationId else { throw Abort(.badRequest, reason: "Destination ID missing for REQUEST") }
            let sourceId = overrideSourceID ?? payload.sourceId
            
            // If scanning a REQUEST, we perform a transfer from the PAYER to the REQUESTER
            if let sid = sourceId {
                 return try await db.transaction { transactionDB in
                    let userID = try user.requireID()
                    
                    guard let destAccount = try await LinkedAccount.query(on: transactionDB)
                        .filter(\.$institution.$id == destId)
                        .first() else {
                        throw Abort(.notFound, reason: "Destination account not found.")
                    }

                    guard let sourceAccount = try await LinkedAccount.query(on: transactionDB)
                        .filter(\.$user.$id == userID)
                        .filter(\.$institution.$id == sid)
                        .first() else {
                        throw Abort(.notFound, reason: "Your source account not found.")
                    }
                    
                    guard sourceAccount.balance >= payload.amount else {
                        throw Abort(.badRequest, reason: "Insufficient balance.")
                    }
                    
                    sourceAccount.balance -= payload.amount
                    try await sourceAccount.save(on: transactionDB)
                    
                    destAccount.balance += payload.amount
                    try await destAccount.save(on: transactionDB)
                    
                    let transaction = Transaction(
                        type: "SEND",
                        amount: -payload.amount,
                        description: "QR Payment to \(destId)",
                        counterparty: "QR Recipient",
                        status: "Completed",
                        userID: userID,
                        sourceInstitutionID: sid,
                        destinationInstitutionID: destId
                    )
                    try await transaction.save(on: transactionDB)
                    
                    return TransactionResult(
                        transaction: transaction,
                        updatedBalances: [
                            BalanceUpdate(institutionId: sid, newBalance: sourceAccount.balance)
                        ]
                    )
                 }
            } else {
                return try await performRequest(
                    user: user,
                    destinationID: destId,
                    amount: payload.amount,
                    payer: "QR Payer",
                    on: db
                )
            }
        case .topup:
            guard let sourceId = payload.sourceId, let destId = payload.destinationId else {
                throw Abort(.badRequest, reason: "Source or Destination ID missing for TOPUP")
            }
            return try await performTopUp(
                user: user,
                sourceID: sourceId,
                destinationID: destId,
                amount: payload.amount,
                on: db
            )
        }
    }
}
