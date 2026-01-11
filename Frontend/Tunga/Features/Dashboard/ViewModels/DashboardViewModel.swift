import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    
    private let demoData = DemoDataManager.shared
    
    @MainActor
    func loadDashboardData() async {
        isLoading = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        
        self.balance = demoData.userProfile.balance
        self.transactions = demoData.transactions
        
        isLoading = false
    }
}
