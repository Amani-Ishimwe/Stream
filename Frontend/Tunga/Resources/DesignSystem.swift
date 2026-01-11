import SwiftUI

// MARK: - Design System
struct DesignSystem {
    // MARK: - Colors
    struct Colors {
        // Strict 3-Color Palette
        // Base Palette (internal use)
        static let deepBlue = Color(hex: "0A2239")
        static let softBeige = Color(hex: "E6DDD2")
        static let offWhite = Color(hex: "F3EFEA")
        
        // Semantic accessors for Theme Consistency
        static func background(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? deepBlue : offWhite
        }
        
        static func textPrimary(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? offWhite : deepBlue
        }
        
        static func textSecondary(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? offWhite.opacity(0.7) : deepBlue.opacity(0.7)
        }
        
        static func accent(_ scheme: ColorScheme) -> Color {
            softBeige // Always Soft Beige for UI actions/highlights
        }
        
        static func surface(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? deepBlue.opacity(0.5) : softBeige.opacity(0.3)
        }
        
        // Semantic aliases for consistency
        static func success(_ scheme: ColorScheme) -> Color { accent(scheme) }
        static func error(_ scheme: ColorScheme) -> Color { deepBlue.opacity(0.8) }
        static func primary(_ scheme: ColorScheme) -> Color { deepBlue } // Added as a function
        
        // Success/Error/Warning are now represented by Primary or Accent based on context
        // to maintain the strict 3-color requirement if needed, or we can use Icons.
        // For now, let's keep the logic simple to ensure NO other colors appear.
    }
    
    // MARK: - Typography
    // Using standard system fonts for maximum reliability and Dynamic Type support
    struct Typography {
        static let largeTitle: Font = .system(size: 34, weight: .bold)
        static let title: Font = .system(size: 28, weight: .semibold)
        static let title2: Font = .system(size: 22, weight: .semibold)
        static let headline: Font = .system(size: 20, weight: .semibold)
        static let body: Font = .system(size: 17, weight: .regular)
        static let callout: Font = .system(size: 16, weight: .medium)
        static let caption: Font = .system(size: 12, weight: .regular)
        
        // Special Balance Font
        static let balance: Font = .system(size: 40, weight: .bold).monospacedDigit()
        
        // Value prop text
        static let valueProp: Font = .system(size: 24, weight: .medium)
    }
    
    // MARK: - Layout & Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
        
        static let cornerRadius: CGFloat = 16
        static let minTouchTarget: CGFloat = 48
    }
}


// MARK: - View Modifiers
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadius)
                    .fill(isEnabled ? DesignSystem.Colors.deepBlue : Color.gray)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Extension to easily apply the style
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}
