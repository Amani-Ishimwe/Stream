import Foundation

struct Institution: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: String
    let iconSymbol: String
    let primaryColorHex: String
    let balance: Double
    let accountNumber: String?
    let lastSynced: Date?
    let isFrozen: Bool
    let dailyLimit: Double
    let monthlyLimit: Double
}

struct Transaction: Codable, Identifiable {
    let id: UUID
    let type: String
    let amount: Double
    let description: String?
    let counterparty: String?
    let status: String
    let createdAt: Date
    let sourceInstitutionID: UUID?
    let destinationInstitutionID: UUID?
    let failureReason: String?
    let metadata: [String: String]?
    
    var formattedAmount: String {
        let prefix = amount >= 0 ? "+" : ""
        return "\(prefix)\(Int(amount)) RWF"
    }
}

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var balance: Double
    var avatarUrl: String?
}

// MARK: - Legacy Stubs (to be removed once project is fully cleaned)
struct NotificationItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let message: String
}

struct PaymentRequest: Codable, Identifiable {
    let id: UUID
}

struct BankConnection: Codable, Identifiable {
    let id: UUID
}

struct Contact: Codable, Identifiable {
    let id: UUID
}
