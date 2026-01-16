@preconcurrency import Fluent
import Vapor

final class Transaction: Model, Content, @unchecked Sendable {
    static let schema = "transactions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "type")
    var type: String // SEND, RECEIVE, TOPUP, WITHDRAW

    @Field(key: "amount")
    var amount: Double
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "counterparty")
    var counterparty: String?
    
    @Field(key: "status")
    var status: String

    @OptionalField(key: "source_institution_id")
    var sourceInstitutionID: UUID?

    @OptionalField(key: "destination_institution_id")
    var destinationInstitutionID: UUID?

    @Field(key: "failure_reason")
    var failureReason: String?

    @OptionalField(key: "metadata")
    var metadata: [String: String]?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, type: String, amount: Double, description: String? = nil, counterparty: String? = nil, status: String = "Completed", userID: UUID, sourceInstitutionID: UUID? = nil, destinationInstitutionID: UUID? = nil, failureReason: String? = nil, metadata: [String: String]? = nil) {
        self.id = id
        self.type = type
        self.amount = amount
        self.description = description
        self.counterparty = counterparty
        self.status = status
        self.$user.id = userID
        self.sourceInstitutionID = sourceInstitutionID
        self.destinationInstitutionID = destinationInstitutionID
        self.failureReason = failureReason
        self.metadata = metadata
    }
}
