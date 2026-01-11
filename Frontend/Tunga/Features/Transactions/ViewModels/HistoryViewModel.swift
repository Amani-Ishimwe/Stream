import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var filtered: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    
    private let api = APIService.shared
    
    func fetchTransactions() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Using DemoDataManager for consistency with Dashboard in demo mode
            // transactions = DemoDataManager.shared.transactions
            
            // Or keep APIService call if user prefers, but fix the sorting
            let results = try await api.fetchTransactions()
            transactions = results.sorted { $0.date > $1.date }
            filtered = transactions
        } catch {
            errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            // Fallback to demo data if API fails (optional, but good for demo)
            transactions = DemoDataManager.shared.transactions
            filtered = transactions
        }
    }

    func applySearch() {
        guard !searchText.isEmpty else {
            filtered = transactions
            return
        }
        let term = searchText.lowercased()
        filtered = transactions.filter {
            $0.description.lowercased().contains(term) ||
            $0.counterparty.lowercased().contains(term) ||
            $0.type.rawValue.lowercased().contains(term)
        }
    }
}

