import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
                
                List {
                    Section {
                        HStack(spacing: 15) {
                            Circle()
                                .fill(DesignSystem.Colors.accent(colorScheme))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(appState.currentUser?.name.prefix(2).uppercased() ?? "JD")
                                        .font(DesignSystem.Typography.headline)
                                        .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                )

                            VStack(alignment: .leading) {
                                Text(appState.currentUser?.name ?? "John Doe")
                                    .font(DesignSystem.Typography.title2)
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                Text(appState.currentUser?.email ?? "john@example.com")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            }
                        }
                        .padding(.vertical, 10)
                        .listRowBackground(DesignSystem.Colors.surface(colorScheme))
                    }
                    .task {
                        await appState.fetchCurrentUser()
                    }

                    // Account
                    Section(header: Text("Account").foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))) {
                        NavigationLink(destination: EditProfileView()) {
                            Label("Edit Profile", systemImage: "person.crop.circle")
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .listRowBackground(DesignSystem.Colors.surface(colorScheme))

                        NavigationLink(destination: SecuritySettingsView()) {
                            Label("Security", systemImage: "lock.shield")
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .listRowBackground(DesignSystem.Colors.surface(colorScheme))

                        NavigationLink(destination: BankAccountsView()) {
                            Label("Bank Accounts", systemImage: "building.columns")
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .listRowBackground(DesignSystem.Colors.surface(colorScheme))
                    }

                    // App
                    Section(header: Text("App").foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))) {
                        NavigationLink(destination: NotificationsView()) {
                            Label("Notifications", systemImage: "bell")
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .listRowBackground(DesignSystem.Colors.surface(colorScheme))

                        NavigationLink(destination: AppSettingsView()) {
                            Label("Settings", systemImage: "gear")
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .listRowBackground(DesignSystem.Colors.surface(colorScheme))

                        NavigationLink(destination: AboutView()) {
                            Label("About", systemImage: "info.circle")
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .listRowBackground(DesignSystem.Colors.surface(colorScheme))

                        NavigationLink(destination: LegalView()) {
                            Label("Legal & Privacy", systemImage: "doc.text")
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .listRowBackground(DesignSystem.Colors.surface(colorScheme))
                    }

                    // Logout
                    Section {
                        Button(role: .destructive) {
                            appState.logout()
                        } label: {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(DesignSystem.Colors.error(colorScheme))
                        }
                        .listRowBackground(DesignSystem.Colors.surface(colorScheme))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitle("My Profile", displayMode: .large)
        }
    }
}

