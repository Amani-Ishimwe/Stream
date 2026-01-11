import SwiftUI

struct AuthLandingView: View {
    @Binding var showAuthLanding: Bool
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()
                
                // Hero Image
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                    .padding()
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.accent(colorScheme).opacity(0.1))
                            .frame(width: 160, height: 160)
                    )
                
                VStack(spacing: 16) {
                    Text("Welcome to SwiftPay+")
                        .font(DesignSystem.Typography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    
                    Text("The safest way to manage your payments.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: 16) {
                    Button(action: {
                        // Navigate to Login
                        appState.navigateToLogin()
                    }) {
                        Text("Log In")
                            .font(DesignSystem.Typography.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.accent(colorScheme))
                            .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                            .cornerRadius(14)
                    }
                    
                    Button(action: {
                        // Navigate to Signup
                        appState.navigateToSignup()
                    }) {
                        Text("Create Account")
                            .font(DesignSystem.Typography.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.primary(colorScheme))
                            .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(DesignSystem.Colors.accent(colorScheme).opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
