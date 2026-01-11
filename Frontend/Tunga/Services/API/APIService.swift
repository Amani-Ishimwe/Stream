import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case httpError(Int)
    case decodingError
    case unauthorized
    case unknown(Error)
    
    var errorDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .httpError(let code): return "Server returned error: \(code)"
        case .decodingError: return "Failed to decode response"
        case .unauthorized: return "Session expired. Please login again."
        case .unknown(let error): return error.localizedDescription
        }
    }
}

class APIService: ObservableObject {
    static let shared = APIService()
    
    // Switch to localhost for Simulator (127.0.0.1)
    private let baseURL = "http://127.0.0.1:8080"
    
    @Published var isAuthenticated = false
    private var token: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { 
            if let val = newValue {
                UserDefaults.standard.set(val, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
    }
    
    init() {
        self.isAuthenticated = token != nil
    }
    
    func logout() {
        self.token = nil
        self.isAuthenticated = false
    }
    
    // MARK: - Networking
    
    private func request<T: Decodable>(_ path: String, method: String = "GET", body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(NSError(domain: "Network", code: 0))
        }
        
        if httpResponse.statusCode == 401 {
            DispatchQueue.main.async { self.logout() }
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error message if available
            if let errorMsg = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                print("API Error: \(errorMsg.reason)")
                throw APIError.unknown(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg.reason]))
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Fluent often sends snake_case
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError
        }
    }
    
    // MARK: - Auth
    
    func signup(data: SignupRequest) async throws {
        let _: SignupResponse = try await request("/auth/signup", method: "POST", body: data)
    }
    
    func login(data: LoginRequest) async throws {
        let response: LoginResponse = try await request("/auth/login", method: "POST", body: data)
        DispatchQueue.main.async {
            self.token = response.token
            self.isAuthenticated = true
        }
    }
    
    func forgotPassword(email: String) async throws -> String {
        let body = ForgotPasswordRequest(email: email)
        let response: ForgotPasswordResponse = try await request("/auth/forgot-password", method: "POST", body: body)
        return response.message
    }
    
    // MARK: - Wallet
    
    func fetchBalance() async throws -> Double {
        let response: BalanceResponse = try await request("/wallet/balance")
        return response.balance
    }
    
    func fetchTransactions() async throws -> [Transaction] {
        return try await request("/wallet/transactions")
    }
    
    func sendMoney(recipientEmail: String, amount: Double, note: String?, pin: String) async throws {
        let body = SendMoneyRequest(recipientEmail: recipientEmail, amount: amount, note: note, pin: pin)
        let _: SendMoneyResponse = try await request("/wallet/send", method: "POST", body: body)
    }
    
    func topUp(amount: Double, method: String) async throws -> Double {
        let body = TopUpRequest(amount: amount, method: method)
        let response: BalanceResponse = try await request("/wallet/topup", method: "POST", body: body)
        return response.balance
    }
    
    func fetchCurrentUser() async throws -> UserProfile {
        return try await request("/user/profile")
    }
    
    func updateProfile(name: String, phone: String) async throws {
        let body = UpdateProfileRequest(name: name, phone: phone)
        let _: MessageResponse = try await request("/user/profile", method: "PUT", body: body)
    }
}

// MARK: - DTOs (Mirroring Backend)

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

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
}

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct ForgotPasswordResponse: Decodable {
    let message: String
}

struct ErrorResponse: Decodable {
    let error: Bool
    let reason: String
}

struct BalanceResponse: Decodable {
    let balance: Double
}

struct SendMoneyRequest: Encodable {
    let recipientEmail: String
    let amount: Double
    let note: String?
    let pin: String
}

struct SendMoneyResponse: Decodable {
    let message: String
}

struct TopUpRequest: Encodable {
    let amount: Double
    let method: String
}



struct UpdateProfileRequest: Encodable {
    let name: String
    let phone: String
}

struct MessageResponse: Decodable {
    let message: String
}


