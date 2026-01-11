import SwiftUI

struct CardsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showOrderPhysical = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Digital Card (Reused Component)
                        FlipCardView(
                            cardNumber: "**** **** **** 1234",
                            expiry: "12/28",
                            holder: "AMANI ISHIMWE"
                        )
                        .frame(height: 220)
                        .padding(.horizontal)
                        
                        // Card Actions
                        VStack(spacing: 16) {
                            Text("Manage Card")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 20) {
                                CardActionButton(icon: "lock.fill", title: "Lock Card", color: DesignSystem.Colors.accent(colorScheme)) {
                                    // Lock Action
                                }
                                CardActionButton(icon: "text.justify", title: "View PIN", color: DesignSystem.Colors.accent(colorScheme)) {
                                    // View PIN Logic
                                }
                                CardActionButton(icon: "arrow.counterclockwise", title: "Replace", color: DesignSystem.Colors.accent(colorScheme)) {
                                    // Replace Logic
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider().padding()
                        
                        // Physical Card Section
                        VStack(alignment: .leading, spacing: 16) {
                             Text("Physical Card")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(DesignSystem.Colors.primary(colorScheme)) // Changed to use colorScheme
                                    .frame(height: 140)
                                    .overlay(
                                        HStack(spacing: 20) {
                                            Image(systemName: "creditcard.and.123")
                                                .font(.system(size: 40))
                                                .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Metal Card")
                                                    .font(DesignSystem.Typography.headline)
                                                    .foregroundColor(DesignSystem.Colors.background(colorScheme)) // Changed to use colorScheme
                                                Text("Premium matte finish metal")
                                                    .font(DesignSystem.Typography.caption)
                                                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme)) // Changed to use colorScheme
                                            }
                                            Spacer()
                                            Button(action: { showOrderPhysical = true }) {
                                                Text("Order Now")
                                                    .font(DesignSystem.Typography.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(DesignSystem.Colors.accent(colorScheme))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(DesignSystem.Colors.accent(colorScheme).opacity(0.1), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("My Cards")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CardActionButton: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.title3)
                    )
                Text(title)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(DesignSystem.Colors.surface(colorScheme))
            .cornerRadius(20)
        }
    }
}

