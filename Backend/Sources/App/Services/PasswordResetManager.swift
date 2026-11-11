import Foundation

public actor PasswordResetManager {
    public static let shared = PasswordResetManager()
    
    private struct ResetEntry {
        let code: String
        let expiresAt: Date
    }
    
    private var store: [String: ResetEntry] = [:]
    
    private init() {}
    
    public func createResetCode(for email: String) -> String {
        let key = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let code = String(format: "%06d", Int.random(in: 100000...999999))
        let entry = ResetEntry(code: code, expiresAt: Date().addingTimeInterval(900)) // 15 minutes
        store[key] = entry
        return code
    }
    
    public func verifyResetCode(code: String, for email: String) -> Bool {
        let key = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let entry = store[key] else { return false }
        if entry.expiresAt < Date() {
            store.removeValue(forKey: key)
            return false
        }
        return entry.code == code.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func clearCode(for email: String) {
        let key = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        store.removeValue(forKey: key)
    }
}

