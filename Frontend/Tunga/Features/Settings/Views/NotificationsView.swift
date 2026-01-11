import SwiftUI

struct NotificationsView: View {
    @Environment(\.colorScheme) var colorScheme
    let items = MockData.notifications
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(items) { item in
                            HStack(alignment: .top, spacing: 16) {
                                // Icon Circle
                                ZStack {
                                    Circle()
                                        .fill(item.isSeen ? DesignSystem.Colors.surface(colorScheme) : DesignSystem.Colors.accent(colorScheme).opacity(0.2))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(item.isSeen ? DesignSystem.Colors.textSecondary(colorScheme) : DesignSystem.Colors.accent(colorScheme))
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.title)
                                        .font(DesignSystem.Typography.headline)
                                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                    
                                    Text(item.message)
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                                    
                                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                                }
                                
                                Spacer()
                                
                                if !item.isSeen {
                                    Circle()
                                        .fill(DesignSystem.Colors.accent(colorScheme))
                                        .frame(width: 8, height: 8)
                                        .padding(.top, 8)
                                }
                            }
                            .padding()
                            .background(DesignSystem.Colors.surface(colorScheme))
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

