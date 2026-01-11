import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                // Profile Header
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(DesignSystem.Colors.accent(colorScheme))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(appState.currentUser?.name.prefix(1) ?? "A")
                                    .font(.title)
                                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                            )
                        
                        VStack(alignment: .leading) {
                            Text(appState.currentUser?.name ?? "Amani Ishimwe")
                                .font(DesignSystem.Typography.headline)
                            Text("Verified")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.success(colorScheme))
                                .padding(.vertical, 2)
                                .padding(.horizontal, 6)
                                .background(DesignSystem.Colors.success(colorScheme).opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Account")) {
                    NavigationLink(destination: BankAccountsView()) {
                        Label("Bank Accounts", systemImage: "building.columns.fill")
                    }
                    NavigationLink(destination: MoreView()) { // MoreView contains Security
                        Label("Security Center", systemImage: "lock.shield.fill")
                    }
                }
                
                Section(header: Text("App")) {
                    Toggle("Notifications", isOn: .constant(true)) // Mock
                }
                
                Section {
                    Button(action: {
                        appState.logout()
                    }) {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(DesignSystem.Colors.error(colorScheme))
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
