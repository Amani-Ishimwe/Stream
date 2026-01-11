import Foundation
import Combine

@MainActor
class SendMoneyViewModel: ObservableObject {
    @Published var recipientEmail = ""
    @Published var amount: Double = 0.0
    @Published var note = ""
    @Published var pin = ""
    
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    init(recipientEmail: String = "") {
        self.recipientEmail = recipientEmail
    }
    
    func sendMoney() async -> Bool {
        guard amount > 0, !recipientEmail.isEmpty, pin.count >= 4 else {
            alertMessage = "Please fill all fields correctly."
            showAlert = true
            return false
        }
        
        isLoading = true
        
        do {
            // Call API
            try await APIService.shared.sendMoney(recipientEmail: recipientEmail, amount: amount, note: note, pin: pin)
            
            alertMessage = "Transfer Successful!"
            showAlert = true
            isLoading = false
            return true
            
        } catch {
            alertMessage = "Failed: \((error as? APIError)?.localizedDescription ?? error.localizedDescription)"
            showAlert = true
            isLoading = false
            return false
        }
    }
}
