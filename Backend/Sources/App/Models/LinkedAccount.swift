import Fluent
import Vapor

final class LinkedAccount: Model, Content {
    static let schema = "linked_accounts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "institution_id")
    var institution: Institution
    
    @Field(key: "account_number")
    var accountNumber: String
    
    @Field(key: "balance")
    var balance: Double
    
    @Field(key: "last_synced")
    var lastSynced: Date
    
    @Field(key: "is_frozen")
    var isFrozen: Bool

    
    init() { }
    
    init(id: UUID? = nil, userID: UUID, institutionID: UUID, accountNumber: String, balance: Double) {
        self.id = id
        self.$user.id = userID
        self.$institution.id = institutionID
        self.accountNumber = accountNumber
        self.balance = balance
        self.lastSynced = Date()
        self.isFrozen = false
    }
}
