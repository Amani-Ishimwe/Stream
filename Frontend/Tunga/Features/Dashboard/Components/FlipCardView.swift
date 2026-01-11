import SwiftUI

struct FlipCardView: View {
    let cardNumber: String
    let expiry: String
    let holder: String
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isRevealed = false
    @State private var isFrozen = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Card Visual
                RoundedRectangle(cornerRadius: 16)
                    .fill(DesignSystem.Colors.primary(colorScheme))
                    .overlay(
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "wave.3.right")
                                    .foregroundColor(DesignSystem.Colors.accent(colorScheme).opacity(0.5))
                                Spacer()
                                Text("SwiftPay+")
                                    .font(DesignSystem.Typography.headline)
                                    .italic()
                                    .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                            }
                            
                            Spacer()
                            
                            HStack {
                                Text(isRevealed ? cardNumber : "•••• •••• •••• " + cardNumber.suffix(4))
                                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                                    .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                                
                                Spacer()
                                
                                Button(action: { isRevealed.toggle() }) {
                                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                                        .foregroundColor(DesignSystem.Colors.accent(colorScheme).opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Card Holder")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary(.dark))
                                    Text(holder.uppercased())
                                        .font(.headline)
                                        .foregroundColor(DesignSystem.Colors.background(colorScheme))
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Expires")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary(.dark))
                                    Text(isRevealed ? expiry : "**/**")
                                        .font(.body)
                                        .foregroundColor(DesignSystem.Colors.background(colorScheme))
                                }
                            }
                        }
                        .padding(24)
                    )
                    .overlay(
                        // Freeze Overlay
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(isFrozen ? 0.3 : 0))
                            .overlay(
                                isFrozen ? Image(systemName: "lock.fill").font(.largeTitle).foregroundColor(DesignSystem.Colors.accent(colorScheme)) : nil
                            )
                    )
                
            }
            .frame(height: 200)
            .shadow(color: DesignSystem.Colors.primary(colorScheme).opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Card Controls
            HStack(spacing: 20) {
                Button(action: { 
                    withAnimation { isFrozen.toggle() }
                }) {
                    Label(isFrozen ? "Unfreeze Card" : "Freeze Card", systemImage: isFrozen ? "lock.open.fill" : "lock.fill")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                }
                
                Button(action: { /* View Details */ }) {
                    Label("View Details", systemImage: "info.circle")
                         .font(DesignSystem.Typography.caption)
                         .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                }
            }
        }
    }
}
