import SwiftUI

enum Tab: String, CaseIterable {
    case home
    case transactions
    case cards
    case requests
    case more
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .transactions: return "chart.bar.doc.horizontal"
        case .cards: return "creditcard"
        case .requests: return "arrow.left.arrow.right"
        case .more: return "gearshape"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .transactions: return "Activity"
        case .cards: return "Cards"
        case .requests: return "Requests"
        case .more: return "More"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(
                                    selectedTab == tab
                                    ? DesignSystem.Colors.accent(colorScheme).opacity(0.15)
                                    : Color.clear
                                )
                                .frame(width: 44, height: 44)

                            Image(systemName: selectedTab == tab ? "\(tab.icon).fill" : tab.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(
                                    selectedTab == tab
                                    ? DesignSystem.Colors.accent(colorScheme)
                                    : DesignSystem.Colors.textSecondary(colorScheme)
                                )
                        }

                        Text(tab.title)
                            .font(.caption2)
                            .foregroundColor(
                                selectedTab == tab
                                ? DesignSystem.Colors.accent(colorScheme)
                                : DesignSystem.Colors.textSecondary(colorScheme)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            DesignSystem.Colors.surface(colorScheme)
                .overlay(
                    Divider().opacity(0.1),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

