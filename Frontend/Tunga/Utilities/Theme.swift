import SwiftUI

struct Theme {
    // MARK: - Gradients (Simplified to Solid/Subtle for Professional Look)
    static func primaryGradient(_ scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [DesignSystem.Colors.primary(scheme), DesignSystem.Colors.primary(scheme).opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static func darkGradient(_ scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [DesignSystem.Colors.primary(scheme), DesignSystem.Colors.primary(scheme)]), 
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static func cardGradient(_ scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Fonts
    // Simulating "Jost" with system rounded/design if actual font file isn't available
    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .jost(size, weight: weight)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
