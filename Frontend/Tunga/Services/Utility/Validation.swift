import Foundation
import Combine

struct Validation {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func isPinValid(_ pin: String) -> Bool {
        // PIN must be 6 digits and contain only numbers
        let pinRegex = "^[0-9]{6}$"
        let pinPredicate = NSPredicate(format: "SELF MATCHES %@", pinRegex)
        return pinPredicate.evaluate(with: pin)
    }
    
    static func isPasswordStrong(_ password: String) -> Bool {
        // Must be at least 8 characters, contain one uppercase, one lowercase, and one number.
        let minLength = password.count >= 8
        let hasUpperCase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowerCase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        return minLength && hasUpperCase && hasLowerCase && hasNumber
    }
    
    static func isAmountValid(_ amount: Double) -> Bool {
        return amount > 0.01
    }
}
