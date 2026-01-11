import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func login() async -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulate network delay or call API
            try await Task.sleep(nanoseconds: 1_000_000_000)
            // Call API
            // For now return true
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
