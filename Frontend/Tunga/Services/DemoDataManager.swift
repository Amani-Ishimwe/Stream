import Foundation

class DemoDataManager {
    static let shared = DemoDataManager()
    
    let userProfile = UserProfile(
        id: "user_001",
        name: "Alex Rivera",
        email: "alex.rivera@example.com",
        phone: "+1 (555) 123-4567",
        balance: 2450.75,
        currency: "USD",
        avatar: "person.crop.circle"
    )
    
    let transactions: [Transaction] = [
        Transaction(id: "SWP-8X4K2", amount: 150.00, type: .received, date: Date.from(year: 2026, month: 1, day: 6), counterparty: "Emma Chen", description: "Birthday gift 🎉", status: .completed),
        Transaction(id: "SWP-7M9P1", amount: 45.50, type: .sent, date: Date.from(year: 2026, month: 1, day: 5), counterparty: "Liam Patel", description: "Lunch split", status: .completed),
        Transaction(id: "SWP-6N2Q8", amount: 500.00, type: .received, date: Date.from(year: 2026, month: 1, day: 3), counterparty: "Freelance Project", description: "Invoice #1024 paid", status: .completed),
        Transaction(id: "SWP-5J7R3", amount: 120.00, type: .sent, date: Date.from(year: 2026, month: 1, day: 2), counterparty: "Uber", description: "Ride to airport", status: .completed),
        Transaction(id: "SWP-4H6T9", amount: 28.99, type: .sent, date: Date.from(year: 2026, month: 1, day: 1), counterparty: "Starbucks", description: "Morning coffee", status: .completed),
        Transaction(id: "SWP-3F5V2", amount: 200.00, type: .received, date: Date.from(year: 2025, month: 12, day: 31), counterparty: "Mom", description: "Happy New Year!", status: .completed),
        Transaction(id: "SWP-2D4U7", amount: 85.00, type: .sent, date: Date.from(year: 2025, month: 12, day: 30), counterparty: "Amazon", description: "Holiday returns credit", status: .completed), // Note: "Holiday returns credit" usually implies refund (+), but spec says "Sent to Amazon" (which is weird for a return, but maybe paying for return shipping? Or maybe user meant "Refund from". Spec says "Sent to Amazon". I will follow spec: Sent. Wait, "Holiday returns credit" implies incoming. I'll stick to Sent -> Amazon as per "Sent to Amazon" text, maybe description is ironic or paying back a credit. Actually, "Sent to Amazon - Holiday returns credit" sounds like a refund *from* Amazon. But the line says "-$85.00 - Sent to Amazon". I will implement as SENT to match the negative sign and direction.
        Transaction(id: "SWP-1B3W5", amount: 350.00, type: .sent, date: Date.from(year: 2025, month: 12, day: 28), counterparty: "Rent", description: "January rent", status: .completed)
    ]
    
    let pendingRequests: [PaymentRequest] = [
        PaymentRequest(id: "req_001", amount: 75.00, requester: "Jordan Lee", note: "Concert tickets", type: .incoming),
        PaymentRequest(id: "req_002", amount: 60.00, requester: "Sophia Kim", note: "Group dinner share", type: .outgoing)
    ]
    
    let bankConnections: [BankConnection] = [
        BankConnection(id: "bank_001", bankName: "Chase Bank", accountNumber: "**** 8821", logo: "building.columns.fill", type: .checking),
        BankConnection(id: "bank_002", bankName: "Goldman Sachs", accountNumber: "**** 4402", logo: "building.2.fill", type: .savings)
    ]
    
    let contacts: [Contact] = [
        Contact(name: "Emma Chen", avatar: "person.crop.circle.fill"),
        Contact(name: "Liam Patel", avatar: "person.fill"),
        Contact(name: "Jordan Lee", avatar: "person.circle"),
        Contact(name: "Sophia Kim", avatar: "person.circle.fill"),
        Contact(name: "Mom", avatar: "heart.fill")
    ]
}

// Helpers for models if not already defined
extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}
