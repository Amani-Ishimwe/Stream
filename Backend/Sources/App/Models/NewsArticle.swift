@preconcurrency import Fluent
import Vapor

final class NewsArticle: Model, Content, @unchecked Sendable {
    static let schema = "news_articles"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    @Field(key: "summary")
    var summary: String
    
    @Field(key: "source")
    var source: String
    
    @Field(key: "image_url")
    var imageUrl: String
    
    @Field(key: "published_at")
    var publishedAt: Date

    init() { }
    
    init(id: UUID? = nil, title: String, summary: String, source: String, imageUrl: String, publishedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.summary = summary
        self.source = source
        self.imageUrl = imageUrl
        self.publishedAt = publishedAt
    }
}
