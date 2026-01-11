import Foundation
import Combine

@MainActor
class SignupViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var phone = ""
    @Published var pin = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func signup() async -> Bool {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            errorMessage = "Please fill all fields"
            return false
        }
        
        isLoading = true
        
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
