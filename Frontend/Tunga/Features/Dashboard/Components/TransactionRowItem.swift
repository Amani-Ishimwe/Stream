import SwiftUI

struct TransactionRowItem: View {
    let transaction: Transaction
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.surface(colorScheme))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(DesignSystem.Colors.accent(colorScheme).opacity(0.3), lineWidth: 1)
                    )
                
                if transaction.isPositive {
                    Image(systemName: "arrow.down.left") // Incoming
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                } else {
                    Image(systemName: "arrow.up.right") // Outgoing
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                }
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.counterparty) // counterparty is non-optional now in new model logic or assumed valid
                    .font(DesignSystem.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Transaction with \(transaction.counterparty), on \(transaction.date.formatted(date: .abbreviated, time: .omitted))")
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(transaction.isPositive ? DesignSystem.Colors.accent(colorScheme) : DesignSystem.Colors.textPrimary(colorScheme))
                .accessibilityLabel("Amount \(transaction.formattedAmount)")
        }
        .padding()
        .background(DesignSystem.Colors.background(colorScheme)) // Use background color or card color
        .cornerRadius(16)
        // .shadow removed for cleaner list look or kept subtle
    }
}
