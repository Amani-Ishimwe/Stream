import Fluent
import Vapor

struct SeedData {
    static func seed(on db: Database) async throws {
        // 1. Seed Users
        var demoUser: User
        if let existing = try await User.query(on: db).first() {
            demoUser = existing
        } else {
            let passwordHash = try Bcrypt.hash("password123")
            demoUser = User(
                name: "Amani Ishimwe",
                email: "amani@example.com",
                phone: "+250 788 000 000",
                pin: "123456",
                passwordHash: passwordHash,
                balance: 0.0 // Balance is now aggregated from LinkedAccounts
            )
            try await demoUser.save(on: db)
        }
        
        // 2. Seed News
        let newsCount = try await NewsArticle.query(on: db).count()
        if newsCount == 0 {
             let news = [
                NewsArticle(title: "Rwandan Franc STABLE vs Dollar", summary: "BNR reports stable exchange rates for the third consecutive quarter.", source: "The New Times", imageUrl: "https://images.unsplash.com/photo-1580519542036-c47de6196ba5?w=400"),
                NewsArticle(title: "Mobile Money Tax Waived", summary: "Government announces tax waiver on mobile money transactions below 5000 RWF.", source: "Igihe", imageUrl: "https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?w=400"),
                NewsArticle(title: "Kigali IFC Grows", summary: "Kigali International Financial Centre attracts 50 new fintech startups.", source: "CNBC Africa", imageUrl: "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400")
            ]
            try await news.create(on: db)
        }
        
        // 3. Seed Institutions (STRICT RWANDA LIST)
        let institutionsCount = try await Institution.query(on: db).count()
        if institutionsCount == 0 {
            let institutions = [
                // Mobile Money
                Institution(name: "MTN MoMo", type: "MOBILE_MONEY", iconSymbol: "iphone.gen3", primaryColorHex: "#FFCC00"),
                Institution(name: "Airtel Money", type: "MOBILE_MONEY", iconSymbol: "antenna.radiowaves.left.and.right", primaryColorHex: "#FF0000"),
                
                // Banks
                Institution(name: "I&M Bank Rwanda Plc", type: "BANK", iconSymbol: "building.columns.fill", primaryColorHex: "#0055AA"),
                Institution(name: "Bank of Kigali Plc", type: "BANK", iconSymbol: "banknote.fill", primaryColorHex: "#0047AB"),
                Institution(name: "BPR Bank Rwanda Plc", type: "BANK", iconSymbol: "house.fill", primaryColorHex: "#FFA500"),
                Institution(name: "GT Bank Rwanda Plc", type: "BANK", iconSymbol: "square.grid.2x2.fill", primaryColorHex: "#E34A23"),
                Institution(name: "Ecobank Rwanda Plc", type: "BANK", iconSymbol: "globe", primaryColorHex: "#006B3D"),
                Institution(name: "Access Bank Rwanda Plc", type: "BANK", iconSymbol: "arrow.right.circle.fill", primaryColorHex: "#FF6600"),
                Institution(name: "Equity Bank Rwanda Plc", type: "BANK", iconSymbol: "star.fill", primaryColorHex: "#A52A2A"),
                Institution(name: "Bank of Africa Rwanda Plc", type: "BANK", iconSymbol: "map.fill", primaryColorHex: "#008000"),
                Institution(name: "NCBA Rwanda Plc", type: "BANK", iconSymbol: "chart.bar.fill", primaryColorHex: "#C0C0C0")
            ]
            try await institutions.create(on: db)
        }
        
        // 4. Seed Linked Accounts (Persistent Balances for Demo User)
        let linkedCount = try await LinkedAccount.query(on: db).count()
        if linkedCount == 0 {
            // Find specific institutions to link
            if let mtnInfo = try await Institution.query(on: db).filter(\.$name == "MTN MoMo").first(),
               let bkInfo = try await Institution.query(on: db).filter(\.$name == "Bank of Kigali Plc").first(),
               let equityInfo = try await Institution.query(on: db).filter(\.$name == "Equity Bank Rwanda Plc").first() {
                
                let linked = [
                    LinkedAccount(userID: demoUser.id!, institutionID: mtnInfo.id!, accountNumber: "078 812 3456", balance: 54000.0),
                    LinkedAccount(userID: demoUser.id!, institutionID: bkInfo.id!, accountNumber: "4004 5500 1234", balance: 1250000.0),
                    LinkedAccount(userID: demoUser.id!, institutionID: equityInfo.id!, accountNumber: "1002 3344 5566", balance: 45000.0)
                ]
                try await linked.create(on: db)
            }
        }
        
        print("✅ Database seeded successfully with Stream (Rwanda) data!")
    }
}
