import SwiftUI
import Combine

@MainActor
class TransactionViewModel: ObservableObject {
    // Flow State
    @Published var recipient = ""
    @Published var amount: Double = 0
    @Published var selectedSource: Institution?
    @Published var selectedDestination: Institution?
    @Published var payer = ""
    @Published var metadata: [String: String] = [:]
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var transactionId: UUID?
    @Published var qrPayload: QRPayload?
    
    private let api = APIService.shared
    
    func sendMoney() async -> Bool {
        guard let source = selectedSource else { return false }
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await api.sendMoney(sourceId: source.id, recipient: recipient, amount: amount, metadata: metadata)
            if response.success {
                self.successMessage = response.message
                self.transactionId = response.transactionId
                return true
            } else {
                errorMessage = response.message ?? "Transaction failed"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        return false
    }
    
    func topUp() async -> Bool {
        guard let source = selectedSource, let dest = selectedDestination else { return false }
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await api.topUp(sourceId: source.id, destinationId: dest.id, amount: amount)
            if response.success {
                self.successMessage = response.message
                self.transactionId = response.transactionId
                return true
            } else {
                errorMessage = response.message ?? "Top-up failed"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        return false
    }
    
    func requestMoney() async -> Bool {
        guard let dest = selectedDestination else { return false }
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await api.requestMoney(destinationId: dest.id, amount: amount, payer: payer)
            if response.success {
                self.successMessage = response.message
                self.transactionId = response.transactionId
                return true
            } else {
                errorMessage = response.message ?? "Request failed"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        return false
    }
    
    func generateQR(type: QRPayload.PayloadType, forRequest: Bool = false) async {
        guard amount > 0 else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // If it's a request, we need a destination (where the money goes)
            let destId = selectedDestination?.id
            let response = try await api.generateQR(type: type, amount: amount, destinationId: destId)
            
            if response.success {
                self.qrPayload = response.data
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
