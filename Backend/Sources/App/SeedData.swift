import Fluent
import Vapor

struct SeedData {
    static func seed(on db: Database) async throws {
        // 1. Seed Users
        let count = try await User.query(on: db).count()
        guard count == 0 else { return }
        
        let passwordHash = try Bcrypt.hash("password123")
        let demoUser = User(
            name: "Amani Ishimwe",
            email: "amani@example.com",
            phone: "+256 700 000 000",
            pin: "123456",
            passwordHash: passwordHash,
            balance: 4850.50
        )
        try await demoUser.save(on: db)
        
        // 2. Seed News (More diverse articles)
        let news = [
            NewsArticle(title: "Global Markets Rally on Tech Earnings", summary: "Tech stocks see a significant boost after quarterly reports exceed expectations. Major indices reach new highs.", source: "Finance Daily", imageUrl: "https://images.unsplash.com/photo-1611974715853-288ee8766a51?w=400"),
            NewsArticle(title: "Digital Wallets Adoption Surges Globally", summary: "Mobile payment adoption has reached an all-time high this year, with over 2 billion active users worldwide.", source: "Tech Crunch", imageUrl: "https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400"),
            NewsArticle(title: "New Crypto Regulations Announced", summary: "Central banks discuss unified framework for digital assets. New guidelines expected to boost institutional adoption.", source: "CoinDesk", imageUrl: "https://images.unsplash.com/photo-1621761191319-c6fb62004040?w=400"),
            NewsArticle(title: "AI Transforms Financial Services", summary: "Machine learning algorithms are revolutionizing fraud detection and personalized banking experiences.", source: "FinTech Weekly", imageUrl: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400"),
            NewsArticle(title: "Sustainable Investing Reaches Record Levels", summary: "ESG funds attract unprecedented capital as investors prioritize environmental and social impact.", source: "Bloomberg", imageUrl: "https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=400"),
            NewsArticle(title: "Central Banks Consider Digital Currencies", summary: "Multiple countries pilot central bank digital currencies (CBDCs) to modernize payment systems.", source: "Reuters", imageUrl: "https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=400")
        ]
        try await news.create(on: db)
        
        // 3. Seed Transactions (More varied and realistic)
        let transactions = [
            Transaction(userID: demoUser.id!, type: "RECEIVE", amount: 2500.0, description: "Monthly Salary", counterparty: "Tunga Inc", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "SEND", amount: -45.50, description: "Lunch with team", counterparty: "KFC Restaurant", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "TOPUP", amount: 1000.0, description: "Top-up via Bank Account", counterparty: "Chase Bank", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "SEND", amount: -120.00, description: "Electricity bill", counterparty: "Umeme Ltd", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "RECEIVE", amount: 350.0, description: "Freelance project payment", counterparty: "Tech Solutions", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "SEND", amount: -25.00, description: "Netflix subscription", counterparty: "Netflix", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "TOPUP", amount: 500.0, description: "Top-up via Credit Card", counterparty: "Visa ****1234", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "SEND", amount: -80.00, description: "Grocery shopping", counterparty: "Carrefour", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "RECEIVE", amount: 150.0, description: "Refund from store", counterparty: "Amazon", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "SEND", amount: -200.0, description: "Rent contribution", counterparty: "Jane Smith", status: "Pending"),
            Transaction(userID: demoUser.id!, type: "SEND", amount: -15.00, description: "Coffee and snacks", counterparty: "Starbucks", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "TOPUP", amount: 750.0, description: "Top-up via Mobile Money", counterparty: "MTN Mobile Money", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "SEND", amount: -60.00, description: "Internet bill", counterparty: "Starlink", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "RECEIVE", amount: 420.0, description: "Birthday gift", counterparty: "Family", status: "Completed"),
            Transaction(userID: demoUser.id!, type: "SEND", amount: -35.00, description: "Taxi fare", counterparty: "Uber", status: "Completed")
        ]
        try await transactions.create(on: db)
        
        print("✅ Database seeded successfully with rich presentation data!")
    }
}
