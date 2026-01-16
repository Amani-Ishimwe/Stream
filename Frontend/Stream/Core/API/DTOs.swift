import Foundation

// MARK: - Auth DTOs
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
}

struct SignupRequest: Encodable {
    let name: String
    let email: String
    let phone: String
    let password: String
    let pin: String
}

struct SignupResponse: Decodable {
    let message: String
}

struct LinkInstitutionDTO: Encodable {
    let institutionId: UUID
    let balance: Double
}

// MARK: - Transaction DTOs
struct SendMoneyDTO: Encodable {
    let sourceInstitutionId: UUID
    let amount: Double
    let recipient: String
    let metadata: [String: String]?
}

struct TopUpDTO: Encodable {
    let sourceInstitutionId: UUID
    let destinationInstitutionId: UUID
    let amount: Double
}

struct RequestMoneyDTO: Encodable {
    let destinationInstitutionId: UUID
    let amount: Double
    let payer: String
}

// MARK: - User DTOs
struct UpdateProfileDTO: Encodable {
    let name: String
    let phone: String
    let avatarUrl: String?
}

struct UpdateLimitsDTO: Encodable {
    let dailyLimit: Double
    let monthlyLimit: Double
}

struct ChangePinDTO: Encodable {
    let oldPin: String
    let newPin: String
}
