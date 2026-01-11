import Foundation

/// Tiny wrapper around `UserDefaults` for demo purposes.
/// Replace with Keychain-backed storage when wiring real authentication.
final class TokenManager {
    static let shared = TokenManager()
    private let keyAccessToken = "accessToken"
    private let defaults = UserDefaults.standard
    
    private init() {}

    func save(accessToken: String) {
        defaults.set(accessToken, forKey: keyAccessToken)
    }

    func getAccessToken() -> String? {
        defaults.string(forKey: keyAccessToken)
    }
    
    func clearTokens() {
        defaults.removeObject(forKey: keyAccessToken)
    }
}
