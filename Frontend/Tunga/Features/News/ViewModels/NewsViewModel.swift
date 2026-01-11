import Foundation
import Combine

struct NewsArticle: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let summary: String
    let source: String
    let imageURL: String?
    let url: String
    let date: Date
}

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    
    func loadNews() async {
        isLoading = true
        // Mock
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        self.articles = [
            NewsArticle(id: UUID(), title: "Market hits all time high", summary: "Stocks are soaring today...", source: "Bloomberg", imageURL: "chart.line.uptrend.xyaxis", url: "https://bloomberg.com", date: Date()),
            NewsArticle(id: UUID(), title: "Crypto regulation updates", summary: "New laws proposed for...", source: "CoinDesk", imageURL: "bitcoinsign.circle", url: "https://coindesk.com", date: Date().addingTimeInterval(-3600))
        ]
        isLoading = false
    }
}
