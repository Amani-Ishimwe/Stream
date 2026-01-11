import Foundation

struct MockBankAccount: Identifiable {
    let id = UUID()
    let bankName: String
    let accountNumber: String
    let icon: String // system name
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date
    let isSeen: Bool
}

struct MockData {
    static let bankAccounts: [MockBankAccount] = [
        MockBankAccount(bankName: "Chase Bank", accountNumber: "**** 8899", icon: "building.columns.fill"),
        MockBankAccount(bankName: "Wells Fargo", accountNumber: "**** 1234", icon: "building.columns")
    ]
    
    static let notifications: [NotificationItem] = [
        NotificationItem(title: "Payment Received", message: "You received $50 from John", date: Date(), isSeen: false),
        NotificationItem(title: "Security Alert", message: "New login detected on iPhone", date: Date().addingTimeInterval(-86400), isSeen: true)
    ]
    
    static let languages: [String] = ["English", "Français", "Kinyarwanda", "Swahili"]
}
