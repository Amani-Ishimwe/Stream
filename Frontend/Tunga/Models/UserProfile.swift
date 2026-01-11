import Foundation

struct UserProfile: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var phone: String?
    var balance: Double
    var currency: String
    var avatar: String? // SF Symbol name or URL
    
    // Init for Demo/Mocking
    init(id: String, name: String, email: String, phone: String? = nil, balance: Double, currency: String = "USD", avatar: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.balance = balance
        self.currency = currency
        self.avatar = avatar
    }
}
