import Foundation
import Vapor

public enum InputValidator {
    // RFC 5322 simplified standard email regex
    private static let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    
    // Optional + prefix, followed by 8 to 15 digits
    private static let phoneRegex = #"^\+?[0-9]{8,15}$"#
    
    // Exactly 4 digits
    private static let pinRegex = #"^[0-9]{4}$"#
    
    // Exactly 6 digits
    private static let codeRegex = #"^[0-9]{6}$"#
    
    public static func validateEmail(_ email: String) throws -> String {
        let clean = sanitizeText(email).lowercased()
        guard !clean.isEmpty else {
            throw Abort(.badRequest, reason: "Email address cannot be empty.")
        }
        guard clean.count <= 100 else {
            throw Abort(.badRequest, reason: "Email address is too long (maximum 100 characters).")
        }
        guard clean.range(of: emailRegex, options: .regularExpression) != nil else {
            throw Abort(.badRequest, reason: "Please enter a valid email address (e.g. name@example.com).")
        }
        return clean
    }
    
    public static func validatePhone(_ phone: String) throws -> String {
        let clean = sanitizeText(phone).replacingOccurrences(of: " ", with: "")
        guard !clean.isEmpty else {
            throw Abort(.badRequest, reason: "Phone number cannot be empty.")
        }
        guard clean.range(of: phoneRegex, options: .regularExpression) != nil else {
            throw Abort(.badRequest, reason: "Please enter a valid phone number (8 to 15 digits).")
        }
        return clean
    }
    
    public static func validateName(_ name: String, fieldName: String = "Name") throws -> String {
        let clean = sanitizeText(name)
        guard clean.count >= 2 else {
            throw Abort(.badRequest, reason: "\(fieldName) must be at least 2 characters.")
        }
        guard clean.count <= 80 else {
            throw Abort(.badRequest, reason: "\(fieldName) cannot exceed 80 characters.")
        }
        return clean
    }
    
    public static func validatePassword(_ password: String, fieldName: String = "Password") throws {
        guard password.count >= 6 else {
            throw Abort(.badRequest, reason: "\(fieldName) must be at least 6 characters long.")
        }
        guard password.count <= 128 else {
            throw Abort(.badRequest, reason: "\(fieldName) cannot exceed 128 characters.")
        }
    }
    
    public static func validatePin(_ pin: String, fieldName: String = "PIN") throws -> String {
        let clean = sanitizeText(pin)
        guard clean.range(of: pinRegex, options: .regularExpression) != nil else {
            throw Abort(.badRequest, reason: "\(fieldName) must be exactly 4 digits.")
        }
        return clean
    }
    
    public static func validateCode(_ code: String) throws -> String {
        let clean = sanitizeText(code)
        guard clean.range(of: codeRegex, options: .regularExpression) != nil else {
            throw Abort(.badRequest, reason: "Verification code must be exactly 6 digits.")
        }
        return clean
    }
    
    public static func validateAmount(_ amount: Double, min: Double = 10.0, max: Double = 50_000_000.0, fieldName: String = "Amount") throws -> Double {
        guard amount.isFinite && !amount.isNaN else {
            throw Abort(.badRequest, reason: "\(fieldName) is not a valid number.")
        }
        guard amount >= min else {
            throw Abort(.badRequest, reason: "\(fieldName) must be at least \(Int(min)) RWF.")
        }
        guard amount <= max else {
            throw Abort(.badRequest, reason: "\(fieldName) cannot exceed \(Int(max)) RWF.")
        }
        // Round to 2 decimal places to avoid floating point manipulation
        return (amount * 100).rounded() / 100
    }
    
    public static func validateLimits(daily: Double, monthly: Double) throws -> (daily: Double, monthly: Double) {
        guard daily.isFinite && !daily.isNaN && daily >= 0 else {
            throw Abort(.badRequest, reason: "Daily spending limit must be a positive number.")
        }
        guard monthly.isFinite && !monthly.isNaN && monthly >= 0 else {
            throw Abort(.badRequest, reason: "Monthly volume limit must be a positive number.")
        }
        guard daily <= 100_000_000 else {
            throw Abort(.badRequest, reason: "Daily limit cannot exceed 100,000,000 RWF.")
        }
        guard monthly <= 500_000_000 else {
            throw Abort(.badRequest, reason: "Monthly limit cannot exceed 500,000,000 RWF.")
        }
        guard monthly >= daily else {
            throw Abort(.badRequest, reason: "Monthly limit must be greater than or equal to daily limit.")
        }
        return (daily: (daily * 100).rounded() / 100, monthly: (monthly * 100).rounded() / 100)
    }
    
    public static func validateUrl(_ urlStr: String?) throws -> String? {
        guard let raw = urlStr else { return nil }
        let str = sanitizeText(raw)
        guard !str.isEmpty else { return nil }
        guard str.count <= 2048 else {
            throw Abort(.badRequest, reason: "URL is too long (maximum 2048 characters).")
        }
        guard let url = URL(string: str), let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
            throw Abort(.badRequest, reason: "Avatar URL must be a valid http or https web address.")
        }
        return str
    }
    
    public static func sanitizeText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "\0", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

