import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var phone = ""
    @Published var pin = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var signupSuccess = false
    
    private let api = APIService.shared
    
    func login(appState: AppState) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await api.login(data: LoginRequest(email: email, password: password))
            if response.success, let token = response.data?.token {
                // Fetch profile to get user details
                let profileResponse = try await api.fetchProfile(token: token)
                if let user = profileResponse.data {
                    appState.login(user: user, token: token)
                } else {
                    errorMessage = "Failed to load user profile"
                }
            } else {
                errorMessage = response.message ?? "Login failed"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signup(appState: AppState) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await api.signup(data: SignupRequest(
                name: name,
                email: email,
                phone: phone,
                password: password,
                pin: pin
            ))
            
            if response.success {
                self.signupSuccess = true
            } else {
                errorMessage = response.message ?? "Signup failed"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
