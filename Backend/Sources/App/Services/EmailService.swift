import Vapor
import Foundation

public struct EmailService: Sendable {
    public static let shared = EmailService()
    
    public func sendEmail(to recipient: String, subject: String, body: String, isHtml: Bool = false) {
        Task.detached(priority: .background) {
            do {
                try await self.performSend(to: recipient, subject: subject, body: body, isHtml: isHtml)
            } catch {
                print("ERROR: [EmailService] Failed to send email to \(recipient): \(error)")
            }
        }
    }
    
    public func performSend(to recipient: String, subject: String, body: String, isHtml: Bool = false) async throws {
        let host = Environment.get("MAIL_HOST") ?? "smtp.gmail.com"
        guard let username = Environment.get("SMTP_USERNAME"), !username.isEmpty,
              let password = Environment.get("SMTP_PASSWORD"), !password.isEmpty else {
            print("WARNING: [EmailService] SMTP credentials not set in environment. Skipping email.")
            return
        }
        
        let cleanedHost = host.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedUser = username.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPass = password.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let contentType = isHtml ? "text/html; charset=UTF-8" : "text/plain; charset=UTF-8"
        let emailContent = """
        From: Stream Banking <\(cleanedUser)>
        To: <\(recipient)>
        Subject: \(subject)
        MIME-Version: 1.0
        Content-Type: \(contentType)

        \(body)
        """
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
        process.arguments = [
            "--url", "smtps://\(cleanedHost):465",
            "--ssl-reqd",
            "--user", "\(cleanedUser):\(cleanedPass)",
            "--mail-from", cleanedUser,
            "--mail-rcpt", recipient,
            "--silent",
            "--show-error",
            "--upload-file", "-"
        ]
        
        let inputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardInput = inputPipe
        process.standardError = errorPipe
        
        try process.run()
        
        if let data = emailContent.data(using: .utf8) {
            inputPipe.fileHandleForWriting.write(data)
        }
        inputPipe.fileHandleForWriting.closeFile()
        
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            print("DEBUG: [EmailService] Successfully sent '\(subject)' to \(recipient)")
        } else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMsg = String(data: errorData, encoding: .utf8) ?? "Unknown curl error"
            print("ERROR: [EmailService] curl exited with status \(process.terminationStatus): \(errorMsg)")
        }
    }
    
    public func sendPasswordResetEmail(to recipient: String, code: String, name: String) {
        let subject = "Your Stream Password Reset Code: \(code)"
        let body = """
        Hello \(name),

        We received a request to reset your Stream Mobile Banking password.

        Your 6-digit password reset code is:
        -------------------------
        \(code)
        -------------------------

        This code is valid for 15 minutes. If you did not make this request, please ignore this email.

        Best regards,
        The Stream Banking Team
        """
        sendEmail(to: recipient, subject: subject, body: body)
    }
    
    public func sendWelcomeEmail(to recipient: String, name: String) {
        let subject = "Welcome to Stream Banking!"
        let body = """
        Hello \(name),

        Welcome to Stream Mobile Banking! Your account has been created successfully.

        You can now sign in to your account, manage your cards, send and receive money, and enjoy fast, secure transactions.

        Best regards,
        The Stream Banking Team
        """
        sendEmail(to: recipient, subject: subject, body: body)
    }
}

