import SwiftUI
import LocalAuthentication

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
                                SettingToggleRow(
                                    icon: (appState.colorSchemeOverride ?? (scheme == .dark ? .dark : .light)) == .dark ? "moon.fill" : "sun.max.fill",
                                    title: "DARK THEME",
                                    isOn: Binding(
                                        get: { (appState.colorSchemeOverride ?? (scheme == .dark ? .dark : .light)) == .dark },
                                        set: { isDark in
                                            withAnimation(.spring()) {
                                                appState.colorSchemeOverride = isDark ? .dark : .light
                                            }
                                        }
                                    )
                                )
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
                                NavigationLink(destination: ProfileEditView()) {
                                    SettingRowContent(icon: "person.text.rectangle", title: "EDIT PROFILE")
                                }
                                NavigationLink(destination: PINChangeView()) {
                                    SettingRowContent(icon: "lock.shield", title: "CHANGE SECURITY PIN")
                                }
                                
                                Button(action: terminateSessions) {
                                    SettingRowContent(icon: "arrow.right.circle", title: "TERMINATE ALL SESSIONS")
                                }
                            }
                            .background(DesignSystem.Colors.surface(scheme))
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                        }
                        
                        Button(action: { appState.logout() }) {
                            Text("LOGOUT")
                                .font(DesignSystem.Typography.caption)
                                .bold()
                                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                                .frame(maxWidth: .infinity)
                                .padding()
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
    
    func terminateSessions() {
        Task {
            do {
                let response = try await APIService.shared.terminateSessions()
                if response.success {
                    appState.logout()
                }
            } catch {
                print("Failed: \(error)")
            }
        }
    }
    
    func authenticateBiometrics() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "ENABLING SECURE ACCESS") { success, _ in
                DispatchQueue.main.async {
                    self.isFaceIDEnabled = success
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
            AsyncImage(url: URL(string: appState.currentUser?.avatarUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                default:
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(appState.currentUser?.name.uppercased() ?? "USER NAME")
                    .font(DesignSystem.Typography.headline)
                if let email = appState.currentUser?.email, !email.isEmpty {
                    Text(email)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                }
            }
            Spacer()
            
            NavigationLink(destination: ProfileEditView()) {
                Text("EDIT")
                    .font(DesignSystem.Typography.caption).bold()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DesignSystem.Colors.background(scheme))
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .onAppear {
            if appState.currentUser == nil {
                Task {
                    if let user = try? await APIService.shared.fetchProfile().data {
                        appState.currentUser = user
                    }
                }
            }
        }
    }
}

struct SettingRowContent: View {
    let icon: String
    let title: String
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
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
        }
        .padding()
        .contentShape(Rectangle())
    }
}

struct SettingActionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            SettingRowContent(icon: icon, title: title)
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
