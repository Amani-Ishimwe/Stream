import Fluent
import Vapor

struct NewsController: RouteCollection, Sendable {
    func boot(routes: RoutesBuilder) throws {
        let news = routes.grouped("news")
        news.get(use: getNews)
    }

    @available(macOS 10.15, iOS 13.0, *)
    @Sendable func getNews(req: Request) async throws -> StreamResponse<[NewsArticle]> {
        let articles = try await NewsArticle.query(on: req.db)
            .sort(\.$publishedAt, .descending)
            .all()
            
        if articles.isEmpty {
            // Seed permissions
            let seed = [
                NewsArticle(title: "Market Uplift", summary: "Crypto rises.", source: "Bloomberg", imageUrl: "chart.line.uptrend.xyaxis"),
                NewsArticle(title: "Rates Cut", summary: "Fed cuts rates.", source: "Reuters", imageUrl: "percent"),
                NewsArticle(title: "Tech Rally", summary: "AI stocks boom.", source: "TechCrunch", imageUrl: "desktopcomputer")
            ]
            for article in seed {
                try await article.save(on: req.db)
            }
            return StreamResponse(success: true, data: seed)
        }
        
        return StreamResponse(success: true, data: articles)
    }
}
