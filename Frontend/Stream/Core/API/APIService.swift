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
        case .invalidURL: 
            return "Unable to connect. Please check your internet connection."
        case .httpError(let code): 
            if code == 400 { return "We could not process this request. Please check the details and try again." }
            if code == 401 { return "Please sign in again to continue." }
            if code == 404 { return "The requested information could not be found." }
            if code == 409 { return "This account already exists. Please try signing in." }
            if code >= 500 { return "Our server encountered a problem. Please try again shortly." }
            return "Something went wrong (code \(code)). Please try again."
        case .decodingError: 
            return "Could not understand response from server. Please try again."
        case .unauthorized: 
            return "Your session expired. Please sign in again."
        case .serverError(let reason): 
            return Self.friendlyMessage(for: reason)
        case .unknown: 
            return "Unable to connect to the server. Please check your internet connection and try again."
        }
    }
    
    static func friendlyMessage(for reason: String) -> String {
        let lower = reason.lowercased()
        if lower.contains("invalid or expired qr") {
            return "This QR code is expired or invalid. Please ask for a new QR code."
        }
        if lower.contains("invalid transaction pin") || lower.contains("pin") {
            return "Incorrect transaction PIN. Please try again."
        }
        if lower.contains("insufficient") {
            return "You don't have enough balance to complete this transaction."
        }
        if lower.contains("invalid email or password") || lower.contains("unauthorized") {
            return "Incorrect email or password. Please try again or tap Forgot Password."
        }
        if lower.contains("email already exists") {
            return "An account with this email already exists. Please sign in instead."
        }
        if lower.contains("verification code is incorrect") || lower.contains("code is invalid") {
            return "The reset code is incorrect or expired. Please check your email or request a new one."
        }
        if lower.contains("not found") {
            return "The selected account or details could not be found."
        }
        return reason
    }
}

struct VaporErrorResponse: Decodable {
    let error: Bool?
    let reason: String?
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
    
    private let baseURL = "https://stream-backend-21x2.onrender.com"
    
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
        
        print("DEBUG: [APIService] Sending \(method) request to \(url.absoluteString)")
        let (data, response) = try await URLSession.shared.data(for: request)
        print("DEBUG: [APIService] Received response for \(path)")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(NSError(domain: "Network", code: 0))
        }
        
        if httpResponse.statusCode == 401 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .userSessionExpired, object: nil)
            }
            throw APIError.unauthorized
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Handle non-200 responses that might still have JSON error body
        if !(200...299).contains(httpResponse.statusCode) {
            // First check Vapor error response format: {"error": true, "reason": "..."}
            if let vaporError = try? decoder.decode(VaporErrorResponse.self, from: data),
               let reason = vaporError.reason, !reason.isEmpty {
                if reason.localizedCaseInsensitiveContains("session") || reason.localizedCaseInsensitiveContains("unauthorized") {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .userSessionExpired, object: nil)
                    }
                }
                throw APIError.serverError(reason)
            }
            // Next check StreamResponse wrapper format: {"message": "..."}
            if let errorResponse = try? decoder.decode(StreamResponse<EmptyResponse>.self, from: data),
               let message = errorResponse.message, !message.isEmpty {
                throw APIError.serverError(message)
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
    
    func forgotPassword(email: String) async throws -> StreamResponse<EmptyResponse> {
        let dto = ForgotPasswordDTO(email: email)
        return try await request("/auth/forgot-password", method: "POST", body: dto)
    }
    
    func resetPassword(email: String, code: String, newPassword: String) async throws -> StreamResponse<EmptyResponse> {
        let dto = ResetPasswordDTO(email: email, code: code, newPassword: newPassword)
        return try await request("/auth/reset-password", method: "POST", body: dto)
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
    
    func fetchInstitutionDetail(id: UUID) async throws -> StreamResponse<Institution> {
        return try await request("/institutions/\(id.uuidString)")
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

    // MARK: - QR
    func generateQR(type: QRPayload.PayloadType, amount: Double, sourceId: UUID? = nil, destinationId: UUID? = nil) async throws -> StreamResponse<QRPayload> {
        let dto = QRGenerateDTO(type: type, amount: amount, sourceInstitutionId: sourceId, destinationInstitutionId: destinationId)
        return try await request("/transactions/qr/generate", method: "POST", body: dto)
    }

    func executeQR(payload: QRPayload, pin: String? = nil, sourceId: UUID? = nil) async throws -> StreamResponse<Transaction> {
        struct QRExecuteDTO: Encodable {
            let payload: QRPayload
            let pin: String?
            let sourceInstitutionId: UUID?
        }
        let dto = QRExecuteDTO(payload: payload, pin: pin, sourceInstitutionId: sourceId)
        return try await request("/transactions/qr/execute", method: "POST", body: dto)
    }
}

struct EmptyResponse: Decodable {}
