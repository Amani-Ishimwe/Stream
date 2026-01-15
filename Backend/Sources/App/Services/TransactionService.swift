import Vapor
import Fluent

struct TransactionResult {
    let transaction: Transaction
    let updatedBalances: [BalanceUpdate]
}

struct TransactionService {
    
    // Top-Up: Source (Linked) -> Dest (Linked)
    func performTopUp(user: User, sourceID: UUID, destinationID: UUID, amount: Double, on db: Database) async throws -> TransactionResult {
        guard amount > 0 else { throw Abort(.badRequest, reason: "Amount must be positive") }
        
        let userID = try user.requireID()
        
        guard let sourceAccount = try await LinkedAccount.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$institution.$id == sourceID)
            .first() else {
            throw Abort(.notFound, reason: "Source account not linked.")
        }
        
        guard let destAccount = try await LinkedAccount.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$institution.$id == destinationID)
            .first() else {
            throw Abort(.notFound, reason: "Destination account not linked.")
        }
        
        // 2. Validate Balance
        guard sourceAccount.balance >= amount else {
            throw Abort(.badRequest, reason: "Insufficient balance in source account.")
        }
        
        // 3. Perform Atomically
        return try await db.transaction { transactionDB in
            // Deduct
            sourceAccount.balance -= amount
            try await sourceAccount.save(on: transactionDB)
            
            // Credit
            destAccount.balance += amount
            try await destAccount.save(on: transactionDB)
            
            // Record
            let transaction = Transaction(
                userID: userID,
                type: "TOPUP",
                amount: amount,
                description: "Top-Up between accounts",
                counterparty: "Self",
                status: "Completed",
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
    func performSend(user: User, sourceID: UUID, amount: Double, recipient: String, on db: Database) async throws -> TransactionResult {
        guard amount > 0 else { throw Abort(.badRequest, reason: "Amount must be positive") }
        
        let userID = try user.requireID()
        
        // 1. Fetch Source Account
        guard let sourceAccount = try await LinkedAccount.query(on: db)
            .filter(\.$user.$id == userID)
            .filter(\.$institution.$id == sourceID)
            .first() else {
            throw Abort(.notFound, reason: "Source account not found.")
        }
        
        // 2. Validate Balance
        guard sourceAccount.balance >= amount else {
            throw Abort(.badRequest, reason: "Insufficient balance.")
        }
        
        // 3. Execute
        return try await db.transaction { transactionDB in
            sourceAccount.balance -= amount
            try await sourceAccount.save(on: transactionDB)
            
            let transaction = Transaction(
                userID: userID,
                type: "SEND",
                amount: -amount,
                description: "Transfer to \(recipient)",
                counterparty: recipient,
                status: "Completed",
                sourceInstitutionID: sourceID,
                destinationInstitutionID: nil
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
        guard amount > 0 else { throw Abort(.badRequest, reason: "Amount must be positive") }
        
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
                userID: userID,
                type: "RECEIVE",
                amount: amount,
                description: "Payment from \(payer)",
                counterparty: payer,
                status: "Completed",
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
}
