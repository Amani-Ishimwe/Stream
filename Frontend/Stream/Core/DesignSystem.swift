import SwiftUI

// MARK: - Design System
struct DesignSystem {
    // MARK: - Colors
    struct Colors {
        // Strict 2-Color Palette (Absolute Rule)
        static let deepBlue = Color(hex: "0A2239")
        static let softBeige = Color(hex: "E6DDD2")
        
        // Semantic accessors for Theme Consistency
        static func background(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? deepBlue : softBeige
        }
        
        static func surface(_ scheme: ColorScheme) -> Color {
            // High clarity surface
            scheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03)
        }
        
        static func shadow(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? Color.black.opacity(0.5) : deepBlue.opacity(0.1)
        }
        
        static func textPrimary(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? softBeige : deepBlue
        }
        
        static func textSecondary(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? softBeige.opacity(0.6) : deepBlue.opacity(0.6)
        }
        
        static func accent(_ scheme: ColorScheme) -> Color {
            // Accents are the opposite color to the background
            scheme == .dark ? softBeige : deepBlue
        }
        
        // Friendly, gentle error and success colors
        static let errorRed = Color(red: 0.90, green: 0.28, blue: 0.28)
        static let errorBg = Color(red: 0.95, green: 0.30, blue: 0.30).opacity(0.12)
        static let successGreen = Color(red: 0.18, green: 0.72, blue: 0.45)
        static let successBg = Color(red: 0.20, green: 0.75, blue: 0.45).opacity(0.12)
        
        static func success(_ scheme: ColorScheme) -> Color { successGreen }
        static func error(_ scheme: ColorScheme) -> Color { errorRed }
    }
    
    // MARK: - Typography (High Density)
    struct Typography {
        static let largeTitle: Font = .system(size: 32, weight: .bold)
        static let title: Font = .system(size: 24, weight: .bold)
        static let title2: Font = .system(size: 20, weight: .semibold)
        static let headline: Font = .system(size: 17, weight: .semibold)
        static let subheadline: Font = .system(size: 15, weight: .medium)
        static let body: Font = .system(size: 15, weight: .regular)
        static let callout: Font = .system(size: 14, weight: .medium)
        static let footnote: Font = .system(size: 13, weight: .regular)
        static let caption: Font = .system(size: 11, weight: .medium).uppercaseSmallCaps()
        
        // High Density balance font
        static let balance: Font = .system(size: 42, weight: .bold, design: .monospaced)
        static let balanceSmall: Font = .system(size: 24, weight: .bold, design: .monospaced)
    }
    
    // MARK: - Layout & Spacing (Fintech Standard)
    struct Spacing {
        static let tny: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 32
        
        static let cornerRadiusCard: CGFloat = 12
        static let cornerRadiusButton: CGFloat = 8
        static let minTouchTarget: CGFloat = 44
    }
}

// MARK: - View Modifiers
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var scheme
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.headline)
            .foregroundColor(DesignSystem.Colors.background(scheme))
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadiusButton)
                    .fill(isEnabled ? DesignSystem.Colors.textPrimary(scheme) : DesignSystem.Colors.textSecondary(scheme).opacity(0.3))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

// MARK: - Friendly Feedback Banners
struct FriendlyErrorBanner: View {
    let message: String
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(DesignSystem.Colors.errorRed)
                .font(.system(size: 16, weight: .semibold))
            
            Text(message)
                .font(DesignSystem.Typography.footnote)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DesignSystem.Colors.errorBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(DesignSystem.Colors.errorRed.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct FriendlySuccessBanner: View {
    let message: String
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(DesignSystem.Colors.successGreen)
                .font(.system(size: 16, weight: .semibold))
            
            Text(message)
                .font(DesignSystem.Typography.footnote)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DesignSystem.Colors.successBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(DesignSystem.Colors.successGreen.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
