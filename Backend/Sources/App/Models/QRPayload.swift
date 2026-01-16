import Vapor
import Foundation
import Crypto

public struct QRPayload: Content, Sendable {
    public enum PayloadType: String, Content, Sendable {
        case send = "SEND"
        case request = "REQUEST"
        case topup = "TOPUP"
    }

    public let type: PayloadType
    public let amount: Double
    public let sourceId: UUID?
    public let destinationId: UUID?
    public let transactionId: UUID?
    public let expiresAt: Date
    public var signature: String?

    public init(type: PayloadType, amount: Double, sourceId: UUID? = nil, destinationId: UUID? = nil, transactionId: UUID? = nil, expiresAt: Date = Date().addingTimeInterval(300)) {
        self.type = type
        self.amount = amount
        self.sourceId = sourceId
        self.destinationId = destinationId
        self.transactionId = transactionId
        self.expiresAt = expiresAt
    }

    // Signing logic using a secret key
    public mutating func sign(secret: String) {
        let timestamp = Int(expiresAt.timeIntervalSince1970)
        let amountStr = String(format: "%.2f", amount)
        let dataToSign = "\(type.rawValue):\(amountStr):\(sourceId?.uuidString ?? ""):\(destinationId?.uuidString ?? ""):\(transactionId?.uuidString ?? ""):\(timestamp)"
        let key = SymmetricKey(data: Data(secret.utf8))
        let signatureData = HMAC<SHA256>.authenticationCode(for: Data(dataToSign.utf8), using: key)
        self.signature = Data(signatureData).base64EncodedString()
    }

    public func verify(secret: String) -> Bool {
        guard let signature = self.signature else { 
            print("QR VERIFY: No signature in payload")
            return false 
        }
        
        let now = Date()
        if expiresAt <= now {
            print("QR VERIFY: Expired. Expires: \(expiresAt), Now: \(now)")
            return false
        }
        
        let timestamp = Int(expiresAt.timeIntervalSince1970)
        let amountStr = String(format: "%.2f", amount)
        let dataToSign = "\(type.rawValue):\(amountStr):\(sourceId?.uuidString ?? ""):\(destinationId?.uuidString ?? ""):\(transactionId?.uuidString ?? ""):\(timestamp)"
        let key = SymmetricKey(data: Data(secret.utf8))
        let expectedSignatureData = HMAC<SHA256>.authenticationCode(for: Data(dataToSign.utf8), using: key)
        let expectedSignature = Data(expectedSignatureData).base64EncodedString()
        
        let isValid = signature == expectedSignature
        if !isValid {
            print("QR VERIFY: Signature Mismatch!")
            print(" - DataToSign: [\(dataToSign)]")
            print(" - Received Signature: [\(signature)]")
            print(" - Expected Signature: [\(expectedSignature)]")
        }
        
        return isValid
    }
}
