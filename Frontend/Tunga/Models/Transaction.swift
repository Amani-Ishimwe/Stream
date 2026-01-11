import Foundation
import SwiftUI

enum TransactionType: String, Codable, Hashable {
    case sent
    case received
    case topup
    case withdraw
}

enum TransactionStatus: String, Codable, Hashable {
    case completed
    case pending
    case failed
}

struct Transaction: Identifiable, Codable, Hashable {
    let id: String // Changed to String to match "SWP-..." format
    let amount: Double
    let type: TransactionType
    let date: Date
    let counterparty: String
    let description: String
    let status: TransactionStatus
    
    // Computed helper for display
    var isPositive: Bool {
        return type == .received || type == .topup
    }
    
    var formattedAmount: String {
        let prefix = isPositive ? "+" : "-"
        return "\(prefix)$\(String(format: "%.2f", abs(amount)))"
    }
    
}

