import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var scheme
    @State private var isFaceIDEnabled = true
    @State private var isPushEnabled = true
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        profileSection
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("PREFERENCES")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                            
                            VStack(spacing: 1) {
                                SettingToggleRow(icon: "faceid", title: "BIOMETRIC AUTH", isOn: $isFaceIDEnabled)
                                SettingToggleRow(icon: "bell.badge", title: "PUSH NOTIFICATIONS", isOn: $isPushEnabled)
                                SettingActionRow(icon: "paintbrush", title: "APPEARANCE") {
                                    // Theme toggle logic (automatic via system but could be manual)
                                }
                            }
                            .background(DesignSystem.Colors.surface(scheme))
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                        }
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text("SECURITY & ACCOUNT")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                            
                            VStack(spacing: 1) {
                                SettingActionRow(icon: "lock.shield", title: "CHANGE PIN") { }
                                SettingActionRow(icon: "doc.text", title: "TERMS OF SERVICE") { }
                                SettingActionRow(icon: "questionmark.circle", title: "HELP & SUPPORT") { }
                            }
                            .background(DesignSystem.Colors.surface(scheme))
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                        }
                        
                        Button(action: { appState.logout() }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("TERMINATE SESSION")
                                    .bold()
                            }
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(DesignSystem.Colors.surface(scheme))
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                    .padding(.vertical, DesignSystem.Spacing.lg)
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("PREFERENCES")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
    
    private var profileSection: some View {
        HStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(appState.currentUser?.name.uppercased() ?? "USER NAME")
                    .font(DesignSystem.Typography.headline)
                Text(appState.currentUser?.email ?? "email@example.com")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            Spacer()
            
            Button("EDIT") { }
                .font(DesignSystem.Typography.caption)
                .bold()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(DesignSystem.Colors.surface(scheme))
                .cornerRadius(12)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
}

struct SettingActionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    .frame(width: 32)
                
                Text(title)
                    .font(DesignSystem.Typography.footnote)
                    .bold()
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}

struct SettingToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .frame(width: 32)
            
            Text(title)
                .font(DesignSystem.Typography.footnote)
                .bold()
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.textPrimary(scheme)))
        }
        .padding()
    }
}
