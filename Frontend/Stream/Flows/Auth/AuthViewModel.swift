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
    @Published var resetSuccessMessage: String?
    @Published var resetCodeSent = false
    @Published var resetComplete = false
    
    private let api = APIService.shared
    
    func login(appState: AppState) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let response = try await api.login(data: LoginRequest(email: cleanEmail, password: password))
            if response.success, let token = response.data?.token {
                // Fetch profile to get user details
                let profileResponse = try await api.fetchProfile(token: token)
                if let user = profileResponse.data {
                    appState.login(user: user, token: token)
                } else {
                    errorMessage = "Could not load user profile. Please try again."
                }
            } else {
                errorMessage = response.message ?? "Incorrect email or password. Please try again."
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
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let response = try await api.signup(data: SignupRequest(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: cleanEmail,
                phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password,
                pin: pin
            ))
            
            if response.success {
                self.signupSuccess = true
            } else {
                errorMessage = response.message ?? "Could not create account. Please try again."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func sendResetCode(emailToReset: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        resetSuccessMessage = nil
        
        do {
            let cleanEmail = emailToReset.trimmingCharacters(in: .whitespacesAndNewlines)
            let response = try await api.forgotPassword(email: cleanEmail)
            resetSuccessMessage = response.message ?? "A 6-digit code has been sent to your email."
            resetCodeSent = true
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func resetPassword(email: String, code: String, newPassword: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        resetSuccessMessage = nil
        
        do {
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
            let response = try await api.resetPassword(email: cleanEmail, code: cleanCode, newPassword: newPassword)
            resetSuccessMessage = response.message ?? "Your password has been reset successfully."
            resetComplete = true
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
