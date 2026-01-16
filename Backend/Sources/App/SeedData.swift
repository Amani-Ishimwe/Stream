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
                balance: 0.0,
                avatarUrl: "https://api.dicebear.com/7.x/avataaars/svg?seed=Amani"
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
        
        // 4. Seed Linked Accounts (Link ALL institutions to Demo User)
        let linkedCount = try await LinkedAccount.query(on: db).count()
        if linkedCount == 0 {
            let institutions = try await Institution.query(on: db).all()
            for (index, inst) in institutions.enumerated() {
                // Generate a semi-random balanced for realism
                let balances: [Double] = [1250000, 54000, 45000, 890000, 15000, 320000, 12000, 450000, 25000, 78000, 210000]
                let balance = (index < balances.count) ? balances[index] : Double.random(in: 10000...500000)
                
                let accountNumber = "STREAM-\(Int.random(in: 1000...9999))-\(Int.random(in: 1000...9999))"
                let linked = LinkedAccount(
                    userID: demoUser.id!,
                    institutionID: inst.id!,
                    accountNumber: accountNumber,
                    balance: balance,
                    dailyLimit: 2000000,
                    monthlyLimit: 10000000
                )
                try await linked.save(on: db)
            }
        }
        
        // 5. Seed Initial Transactions
        let txCount = try await Transaction.query(on: db).count()
        if txCount < 5 {
            if let mtnLine = try await LinkedAccount.query(on: db).with(\.$institution).first(),
               let bkLine = try await LinkedAccount.query(on: db).filter(\.$accountNumber == "4004 5500 1234").first() {
                 let txs = [
                    Transaction(type: "RECEIVE", amount: 250000, description: "Monthly Salary", counterparty: "Tunga Inc", status: "Completed", userID: demoUser.id!, destinationInstitutionID: bkLine.$institution.id),
                    Transaction(type: "SEND", amount: -5000, description: "Internet Bundle", counterparty: "MTN Rwanda", status: "Completed", userID: demoUser.id!, sourceInstitutionID: mtnLine.$institution.id),
                    Transaction(type: "SEND", amount: -12500, description: "Groceries", counterparty: "Simba Supermarket", status: "Completed", userID: demoUser.id!, sourceInstitutionID: bkLine.$institution.id),
                    Transaction(type: "TOPUP", amount: 40000, description: "Wallet Top up", counterparty: "Self", status: "Completed", userID: demoUser.id!, sourceInstitutionID: mtnLine.$institution.id),
                    Transaction(type: "SEND", amount: -2100, description: "Coffee", counterparty: "Question Coffee", status: "Completed", userID: demoUser.id!, sourceInstitutionID: mtnLine.$institution.id),
                    Transaction(type: "RECEIVE", amount: 15000, description: "Refund", counterparty: "Jumia Rwanda", status: "Completed", userID: demoUser.id!, destinationInstitutionID: mtnLine.$institution.id)
                ]
                try await txs.create(on: db)
            }
        }
        
        print("✅ Database seeded successfully with Stream (Rwanda) data!")
    }
}
