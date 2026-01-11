import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Adaptive background
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 60)
                    
                    // Logo Section
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.accent(colorScheme))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "wallet.pass.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                    }
                    
                    Text("SwiftPay+")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    
                    // Form Card
                    VStack(spacing: 20) {
                        TextField("Email", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(DesignSystem.Colors.surface(colorScheme))
                            .cornerRadius(12)
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(DesignSystem.Colors.surface(colorScheme))
                            .cornerRadius(12)
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            appState.showForgotPassword = true
                        }) {
                            Text("Forgot Password?")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                        }
                        .padding(.top, 5)
                        
                        Button(action: {
                            Task {
                                if await viewModel.login() {
                                    appState.isLoggedIn = true
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(DesignSystem.Colors.primary(colorScheme))
                            } else {
                                Text("Log In")
                                    .font(DesignSystem.Typography.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(DesignSystem.Colors.accent(colorScheme))
                                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Face ID Button
                        Button(action: {
                            appState.isLoggedIn = true
                        }) {
                            HStack {
                                Image(systemName: "faceid")
                                Text("Log in with Face ID")
                                    .font(DesignSystem.Typography.caption)
                            }
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            .padding(.top, 10)
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(DesignSystem.Colors.accent(colorScheme), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    Button(action: {
                        appState.navigateToSignup()
                    }) {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .font(DesignSystem.Typography.body)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
    }
}
