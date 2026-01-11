import SwiftUI

struct FontManager {
    struct Jost {
        static let regular = "Jost-Regular"
        static let medium = "Jost-Medium"
        static let semiBold = "Jost-SemiBold"
        static let bold = "Jost-Bold"
        static let light = "Jost-Light"
        // Add other weights as needed depending on the files added by the user
    }
}

extension Font {
    static func jost(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .light:
            return .custom(FontManager.Jost.light, size: size)
        case .regular:
            return .custom(FontManager.Jost.regular, size: size)
        case .medium:
            return .custom(FontManager.Jost.medium, size: size)
        case .semibold:
            return .custom(FontManager.Jost.semiBold, size: size)
        case .bold:
            return .custom(FontManager.Jost.bold, size: size)
        default:
            return .custom(FontManager.Jost.regular, size: size)
        }
    }
}
