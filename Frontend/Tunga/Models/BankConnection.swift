import Foundation

struct BankConnection: Identifiable, Codable, Hashable {
    let id: String
    let bankName: String
    let accountNumber: String // Masked, e.g., "**** 1234"
    let logo: String // SF Symbol or color hint
    let type: BankType
}

enum BankType: String, Codable {
    case checking
    case savings
    case credit
}
