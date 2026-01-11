import SwiftUI

struct QuickActionButton: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let label: String
    let color: Color // This color is passed in but not used in the original version, I'll use it for the icon circle background for better visual differentiation
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.accent(colorScheme).opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                }
                
                Text(label)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    .fontWeight(.medium)
            }
        }
    }
}
