import SwiftUI

struct MoreView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @State private var showWithdraw = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 12) {
                            Circle()
                                .fill(DesignSystem.Colors.accent(colorScheme))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(appState.currentUser?.name.prefix(1) ?? "A")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                )
                            
                            VStack {
                                Text(appState.currentUser?.name ?? "Alex Rivera")
                                    .font(DesignSystem.Typography.title2)
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                Text(appState.currentUser?.email ?? "alex.rivera@example.com")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            }
                        }
                        .padding(.vertical)
                        
                        // Settings Groups
                        VStack(spacing: 20) {
                            settingGroup(title: "Finance") {
                                settingRow(icon: "building.columns.fill", color: DesignSystem.Colors.accent(colorScheme), title: "Linked Banks") { /* Bank List */ }
                                settingRow(icon: "arrow.up.right.circle.fill", color: DesignSystem.Colors.accent(colorScheme), title: "Withdraw Funds") { showWithdraw = true }
                                settingRow(icon: "chart.bar.fill", color: DesignSystem.Colors.accent(colorScheme), title: "Spending Limits") { /* Limits */ }
                            }
                            
                            settingGroup(title: "Account & Security") {
                                settingRow(icon: "person.fill", color: DesignSystem.Colors.accent(colorScheme), title: "Personal Details") { /* Profile */ }
                                NavigationLink(destination: SecurityCenterView()) {
                                    rowContent(icon: "lock.shield.fill", color: DesignSystem.Colors.accent(colorScheme), title: "Security Center")
                                }
                                .buttonStyle(.plain)
                            }
                            
                            settingGroup(title: "Preferences") {
                                HStack {
                                    rowContent(icon: "moon.fill", color: DesignSystem.Colors.accent(colorScheme), title: "Dark Mode")
                                    Toggle("", isOn: $appState.isDarkMode)
                                        .labelsHidden()
                                        .tint(DesignSystem.Colors.accent(colorScheme))
                                }
                                .padding()
                                .background(DesignSystem.Colors.surface(colorScheme))
                                .cornerRadius(16)
                                
                                settingRow(icon: "bell.badge.fill", color: DesignSystem.Colors.accent(colorScheme), title: "Notifications") { /* Notif */ }
                            }
                            
                            Button(action: { appState.logout() }) {
                                Text("Log Out")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(DesignSystem.Colors.accent(colorScheme))
                                    .cornerRadius(16)
                            }
                            .padding(.top, 20)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showWithdraw) {
                WithdrawView()
            }
        }
    }
    
    // MARK: - Helpers
    
    func settingGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(DesignSystem.Typography.caption)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                .padding(.leading, 8)
            
            VStack(spacing: 1) {
                content()
            }
            .background(DesignSystem.Colors.surface(colorScheme))
            .cornerRadius(20)
        }
    }
    
    func settingRow(icon: String, color: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            rowContent(icon: icon, color: color, title: title)
        }
        .buttonStyle(.plain)
    }
    
    func rowContent(icon: String, color: Color, title: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            Text(title)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
        }
        .padding()
    }
}

// MARK: - Security Center View
struct SecurityCenterView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var biometricsEnabled = true
    @State private var twoFactorEnabled = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 1) {
                    Group {
                        Text("Authentication")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.top)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Face ID / Touch ID")
                                Spacer()
                                Toggle("", isOn: $biometricsEnabled)
                                    .labelsHidden()
                                    .tint(DesignSystem.Colors.accent(colorScheme))
                            }
                            .padding()
                            
                            Divider().padding(.leading)
                            
                            NavigationLink(destination: Text("PIN Update")) {
                                HStack {
                                    Text("Change Secure PIN")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                                }
                                .padding()
                            }
                            .buttonStyle(.plain)
                        }
                        .background(DesignSystem.Colors.surface(colorScheme))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    Group {
                        Text("Account Protection")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.top)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Two-Factor Authentication")
                                Spacer()
                                Toggle("", isOn: $twoFactorEnabled)
                                    .labelsHidden()
                                    .tint(DesignSystem.Colors.accent(colorScheme))
                            }
                            .padding()
                            
                            Divider().padding(.leading)
                            
                            NavigationLink(destination: Text("Sessions List")) {
                                HStack {
                                    Text("Active Sessions")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                                }
                                .padding()
                            }
                            .buttonStyle(.plain)
                        }
                        .background(DesignSystem.Colors.surface(colorScheme))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    Group {
                        Text("Data & Privacy")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.top)
                        
                        VStack(spacing: 0) {
                            NavigationLink(destination: Text("Privacy Controls")) {
                                HStack {
                                    Text("Privacy Settings")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                                }
                                .padding()
                            }
                            .buttonStyle(.plain)
                            
                            Divider().padding(.leading)
                            
                            NavigationLink(destination: Text("Account Deletion")) {
                                HStack {
                                    Text("Delete Account")
                                        .foregroundColor(DesignSystem.Colors.error(colorScheme))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                                }
                                .padding()
                            }
                            .buttonStyle(.plain)
                        }
                        .background(DesignSystem.Colors.surface(colorScheme))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
            }
        }
        .navigationTitle("Security Center")
    }
}

