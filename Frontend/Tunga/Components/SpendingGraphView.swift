import SwiftUI

struct SpendingGraphView: View {
    @Environment(\.colorScheme) var colorScheme
    let data: [Double] = [50, 80, 40, 100, 70, 90, 60]
    let days: [String] = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Spending")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(data.indices, id: \.self) { index in
                    VStack {
                        Spacer()

                        RoundedRectangle(cornerRadius: 6)
                            .fill(DesignSystem.Colors.accent(colorScheme))
                            .frame(height: CGFloat(data[index]))

                        Text(days[index])
                            .font(.caption2)
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    }
                }
            }
            .frame(height: 120)
            .padding()
            .background(DesignSystem.Colors.surface(colorScheme).opacity(colorScheme == .dark ? 0.1 : 1.0))
            .cornerRadius(16)
        }
    }
}
