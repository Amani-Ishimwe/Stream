import SwiftUI

struct RequestsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedFilter = 0
    let filters = ["All", "Pending", "Received", "Sent"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Segment (Custom)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<filters.count, id: \.self) { index in
                                Button(action: {
                                    withAnimation { selectedFilter = index }
                                }) {
                                    Text(filters[index])
                                        .font(DesignSystem.Typography.callout)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(selectedFilter == index ? DesignSystem.Colors.accent(colorScheme) : DesignSystem.Colors.surface(colorScheme))
                                        .foregroundColor(selectedFilter == index ? DesignSystem.Colors.primary(colorScheme) : DesignSystem.Colors.textSecondary(colorScheme))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // List
                    ScrollView {
                        VStack(spacing: 16) {
                            // Using real Demo Data logic if available, or just keeping the rows styled
                            ForEach(DemoDataManager.shared.pendingRequests) { request in
                                RequestRow(name: request.requester, amount: request.amount, note: request.note, status: "Pending", isIncoming: true)
                            }
                            
                            RequestRow(name: "John D.", amount: 120.0, note: "Dinner Last Night", status: "Sent", isIncoming: false)
                            RequestRow(name: "Netflix Split", amount: 15.0, note: "Monthly Subscription", status: "Paid", isIncoming: true)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Requests")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RequestRow: View {
    @Environment(\.colorScheme) var colorScheme
    let name: String
    let amount: Double
    let note: String
    let status: String
    let isIncoming: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(DesignSystem.Colors.accent(colorScheme).opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(name.prefix(1))
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                Text(note)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", amount))")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                
                Text(status)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(DesignSystem.Colors.surface(colorScheme))
        .cornerRadius(20)
    }
    
    var statusColor: Color {
        switch status {
        case "Pending": return DesignSystem.Colors.accent(colorScheme).opacity(0.7)
        case "Paid": return DesignSystem.Colors.accent(colorScheme)
        case "Sent": return DesignSystem.Colors.textSecondary(colorScheme)
        default: return DesignSystem.Colors.textSecondary(colorScheme)
        }
    }
}

