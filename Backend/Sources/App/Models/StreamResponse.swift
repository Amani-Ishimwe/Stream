import Vapor

struct StreamResponse<T: Content>: Content {
    let success: Bool
    let message: String
    let data: T?
    let updatedBalances: [BalanceUpdate]?
    let transactionId: UUID?
    
    init(success: Bool = true, message: String = "", data: T? = nil, updatedBalances: [BalanceUpdate]? = nil, transactionId: UUID? = nil) {
        self.success = success
        self.message = message
        self.data = data
        self.updatedBalances = updatedBalances
        self.transactionId = transactionId
    }
}

struct BalanceUpdate: Content {
    let institutionId: UUID
    let newBalance: Double
}

struct EmptyResponse: Content {}
