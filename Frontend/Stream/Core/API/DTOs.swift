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

// MARK: - QR DTOs
struct QRPayload: Codable, Identifiable {
    var id: String { signature ?? UUID().uuidString }
    
    enum PayloadType: String, Codable {
        case send = "SEND"
        case request = "REQUEST"
        case topup = "TOPUP"
    }

    let type: PayloadType
    let amount: Double
    let sourceId: UUID?
    let destinationId: UUID?
    let transactionId: UUID?
    let expiresAt: Date
    let signature: String?
}

struct QRGenerateDTO: Encodable {
    let type: QRPayload.PayloadType
    let amount: Double
    let sourceInstitutionId: UUID?
    let destinationInstitutionId: UUID?
}

struct QRExecuteDTO: Encodable {
    let payload: QRPayload
    let pin: String?
}
