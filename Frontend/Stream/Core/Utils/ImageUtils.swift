import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRScannerUtils {
    static func detectQRCode(from image: UIImage) -> String? {
        print("DEBUG: detectQRCode started for image \(image.size)")
        guard let ciImage = CIImage(image: image) else { 
            print("DEBUG: Failed to create CIImage")
            return nil 
        }
        
        let context = CIContext()
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        
        let features = qrDetector?.features(in: ciImage)
        print("DEBUG: Found \(features?.count ?? 0) features")
        
        if let qrFeature = features?.first as? CIQRCodeFeature {
            print("DEBUG: Successfully extracted QR string: \(qrFeature.messageString ?? "nil")")
            return qrFeature.messageString
        }
        
        print("DEBUG: No QR feature found in image")
        return nil
    }
}
