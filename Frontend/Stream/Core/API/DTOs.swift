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

// MARK: - Transaction DTOs
struct SendMoneyDTO: Encodable {
    let sourceInstitutionID: UUID
    let amount: Double
    let recipient: String
}

struct TopUpDTO: Encodable {
    let sourceInstitutionID: UUID
    let destinationInstitutionID: UUID
    let amount: Double
}

struct RequestMoneyDTO: Encodable {
    let destinationInstitutionID: UUID
    let amount: Double
    let payer: String
}
