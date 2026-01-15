import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var institutions: [Institution] = []
    @Published var recentTransactions: [Transaction] = []
    @Published var totalBalance: Double = 0
    @Published var lastTransactionChange: Double = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastSync: Date = Date()
    
    private let api = APIService.shared
    
    func refreshData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch Institutions
            let instResponse = try await api.fetchInstitutions()
            if instResponse.success, let data = instResponse.data {
                self.institutions = data
                self.totalBalance = data.reduce(0) { $0 + $1.balance }
            }
            
            // Fetch Recent Transactions
            let transResponse = try await api.fetchTransactions()
            if transResponse.success, let data = transResponse.data {
                self.recentTransactions = Array(data.prefix(5))
                self.lastTransactionChange = data.first?.amount ?? 0
            }
            
            self.lastSync = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
