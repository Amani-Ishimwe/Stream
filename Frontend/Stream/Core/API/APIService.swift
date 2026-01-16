import Foundation
import Combine

enum APIError: Error, LocalizedError {
    case invalidURL
    case httpError(Int)
    case decodingError
    case unauthorized
    case serverError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .httpError(let code): return "Server returned error: \(code)"
        case .decodingError: return "Failed to process data from server"
        case .unauthorized: return "Session expired. Please login again."
        case .serverError(let reason): return reason
        case .unknown(let error): return error.localizedDescription
        }
    }
}

struct StreamResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T?
    let updatedBalances: [BalanceUpdate]?
    let transactionId: UUID?
}

struct BalanceUpdate: Decodable {
    let institutionId: UUID
    let newBalance: Double
}

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "http://10.12.73.61:8080"
    
    // Auth Session (managed by AppState, but APIService needs it for headers)
    private var token: String? {
        UserDefaults.standard.string(forKey: "stream_auth_token")
    }
    
    private func request<T: Decodable>(_ path: String, method: String = "GET", body: Encodable? = nil, authToken: String? = nil) async throws -> StreamResponse<T> {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use provided token or fall back to UserDefaults
        if let token = authToken ?? self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(NSError(domain: "Network", code: 0))
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Handle non-200 responses that might still have JSON error body
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorResponse = try? decoder.decode(StreamResponse<EmptyResponse>.self, from: data) {
                throw APIError.serverError(errorResponse.message ?? "Unknown server error")
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(StreamResponse<T>.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError
        }
    }
    
    // MARK: - Auth
    
    func login(data: LoginRequest) async throws -> StreamResponse<LoginResponse> {
        return try await request("/auth/login", method: "POST", body: data)
    }
    
    func signup(data: SignupRequest) async throws -> StreamResponse<SignupResponse> {
        return try await request("/auth/signup", method: "POST", body: data)
    }
    
    // MARK: - User
    
    func fetchProfile(token: String? = nil) async throws -> StreamResponse<UserProfile> {
        return try await request("/user/profile", authToken: token)
    }
    
    func updateProfile(name: String, phone: String, avatarUrl: String?) async throws -> StreamResponse<EmptyResponse> {
        let body = UpdateProfileDTO(name: name, phone: phone, avatarUrl: avatarUrl)
        return try await request("/user/profile", method: "PUT", body: body)
    }
    
    func changePin(oldPin: String, newPin: String) async throws -> StreamResponse<EmptyResponse> {
        let body = ChangePinDTO(oldPin: oldPin, newPin: newPin)
        return try await request("/user/pin", method: "POST", body: body)
    }
    
    func terminateSessions() async throws -> StreamResponse<EmptyResponse> {
        return try await request("/user/terminate-sessions", method: "POST")
    }
    
    // MARK: - Institutions
    
    func fetchInstitutions() async throws -> StreamResponse<[Institution]> {
        return try await request("/institutions")
    }
    
    func fetchAvailableInstitutions() async throws -> StreamResponse<[Institution]> {
        return try await request("/institutions/available")
    }
    
    func linkInstitution(id: UUID, balance: Double = 0) async throws -> StreamResponse<Institution> {
        let dto = LinkInstitutionDTO(institutionId: id, balance: balance)
        return try await request("/institutions/link", method: "POST", body: dto)
    }
    
    func fetchInstitutionTransactions(id: UUID) async throws -> StreamResponse<[Transaction]> {
        return try await request("/institutions/\(id.uuidString)/transactions")
    }
    
    func toggleFreeze(id: UUID) async throws -> StreamResponse<Institution> {
        return try await request("/institutions/\(id.uuidString)/freeze", method: "POST")
    }
    
    func updateLimits(id: UUID, daily: Double, monthly: Double) async throws -> StreamResponse<Institution> {
        let dto = UpdateLimitsDTO(dailyLimit: daily, monthlyLimit: monthly)
        return try await request("/institutions/\(id.uuidString)/limits", method: "POST", body: dto)
    }
    
    // MARK: - Transactions
    
    func fetchTransactions() async throws -> StreamResponse<[Transaction]> {
        return try await request("/transactions")
    }
    
    func sendMoney(sourceId: UUID, recipient: String, amount: Double, metadata: [String: String]? = nil) async throws -> StreamResponse<Transaction> {
        let dto = SendMoneyDTO(sourceInstitutionId: sourceId, amount: amount, recipient: recipient, metadata: metadata)
        return try await request("/transactions/send", method: "POST", body: dto)
    }
    
    func topUp(sourceId: UUID, destinationId: UUID, amount: Double) async throws -> StreamResponse<Transaction> {
        let dto = TopUpDTO(sourceInstitutionId: sourceId, destinationInstitutionId: destinationId, amount: amount)
        return try await request("/transactions/topup", method: "POST", body: dto)
    }
    
    func requestMoney(destinationId: UUID, amount: Double, payer: String) async throws -> StreamResponse<Transaction> {
        let dto = RequestMoneyDTO(destinationInstitutionId: destinationId, amount: amount, payer: payer)
        return try await request("/transactions/request", method: "POST", body: dto)
    }
}

struct EmptyResponse: Decodable {}
