import Vapor
import Fluent

struct InstitutionService {
    func getLinkedInstitutions(for user: User, on db: Database) async throws -> [Institution] {
        // In a real app, we'd query a linkage table.
        // For MVP/Mock purposes, we assume the user has linked specific ones or return all active ones for now
        // to simplify the "Aggregated Dashboard" demonstration.
        // Or we can just return all seeded institutions as "available to link" or "linked".
        // Let's return all for now to populate the UI.
        return try await Institution.query(on: db).filter(\.$isActive == true).all()
    }

    func getBalances(for user: User, on db: Database) async throws -> [UUID: Double] {
        // Mock balance generation based on Institution ID
        let institutions = try await Institution.query(on: db).all()
        var balances: [UUID: Double] = [:]
        
        for inst in institutions {
            if let id = inst.id {
                // Fixed mock balances for consistency or random for fun?
                // Concept note says "Persistent", so maybe deteremistic based on User ID + Inst ID?
                // Let's give them some money to start.
                let seed = (user.id?.uuidString.hash ?? 0) + (inst.name.hash)
                let balance = Double(abs(seed) % 100000)
                balances[id] = balance
            }
        }
        return balances
    }
}
