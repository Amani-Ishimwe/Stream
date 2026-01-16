import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRScannerUtils {
    static func detectQRCode(from image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let context = CIContext()
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        
        let features = qrDetector?.features(in: ciImage)
        
        if let qrFeature = features?.first as? CIQRCodeFeature {
            return qrFeature.messageString
        }
        
        return nil
    }
}
