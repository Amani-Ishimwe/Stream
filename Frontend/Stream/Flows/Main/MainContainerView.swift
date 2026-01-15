import SwiftUI

enum StreamTab: String, CaseIterable {
    case home = "house.fill"
    case activity = "list.bullet.rectangle.fill"
    case send = "paperplane.fill"
    case cards = "creditcard.fill"
    case settings = "person.fill"
    
    var title: String {
        switch self {
        case .home: return "HOUSE"
        case .activity: return "LEDGER"
        case .send: return "FLOW"
        case .cards: return "VAULT"
        case .settings: return "CONFIG"
        }
    }
}

struct MainContainerView: View {
    @State private var selectedTab: StreamTab = .home
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case .home:
                        DashboardView()
                    case .activity:
                        ActivityView()
                    case .send:
                        SendMoneyFlow()
                    case .cards:
                        CardsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer(minLength: 80) // Tab bar height
            }
            
            StreamTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct StreamTabBar: View {
    @Binding var selectedTab: StreamTab
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(StreamTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.rawValue)
                            .font(.system(size: 18, weight: .bold))
                        
                        Text(tab.title)
                            .font(.system(size: 8, weight: .black))
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == tab ? 
                                     DesignSystem.Colors.textPrimary(scheme) : 
                                     DesignSystem.Colors.textSecondary(scheme).opacity(0.4))
                }
            }
        }
        .padding(.vertical, 16)
        .background(DesignSystem.Colors.surface(scheme))
        .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
