import Fluent

struct CreateEnhancementFields: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let userUpdate = database.schema("users")
            .field("avatar_url", .string)
            .field("token_version", .int, .custom("DEFAULT 1"))
            .update()
            
        let linkedAccountUpdate = database.schema("linked_accounts")
            .field("daily_limit", .double, .custom("DEFAULT 1000000"))
            .field("monthly_limit", .double, .custom("DEFAULT 5000000"))
            .update()
            
        let transactionUpdate = database.schema("transactions")
            .field("failure_reason", .string)
            .field("metadata", .json)
            .update()
            
        return userUpdate.and(linkedAccountUpdate).and(transactionUpdate).transform(to: ())
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        let userRevert = database.schema("users")
            .deleteField("avatar_url")
            .deleteField("token_version")
            .update()
            
        let linkedAccountRevert = database.schema("linked_accounts")
            .deleteField("daily_limit")
            .deleteField("monthly_limit")
            .update()
            
        let transactionRevert = database.schema("transactions")
            .deleteField("failure_reason")
            .deleteField("metadata")
            .update()
            
        return userRevert.and(linkedAccountRevert).and(transactionRevert).transform(to: ())
    }
}
