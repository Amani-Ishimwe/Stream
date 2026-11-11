import SwiftUI

struct SignupView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = AuthViewModel()
    @State private var showPassword = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    
                    VStack(spacing: 4) {
                        Text("CREATE ACCOUNT")
                            .font(DesignSystem.Typography.title)
                            .tracking(4)
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                        
                        Text("Enter your details to get started")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 30)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            sectionHeader(title: "PERSONAL DETAILS")
                            
                            VStack(spacing: 12) {
                                customField(title: "FULL NAME", placeholder: "Your full name", text: $viewModel.name)
                                customField(title: "EMAIL ADDRESS", placeholder: "name@example.com", text: $viewModel.email, keyboard: .emailAddress)
                                customField(title: "PHONE NUMBER", placeholder: "Phone number", text: $viewModel.phone, keyboard: .phonePad)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            sectionHeader(title: "SECURITY")
                            
                            VStack(spacing: 12) {
                                customPasswordField(title: "PASSWORD", text: $viewModel.password)
                                customField(title: "4-DIGIT PIN", placeholder: "Choose a 4-digit PIN", text: $viewModel.pin, keyboard: .numberPad)
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
                
                // Footer
                VStack(spacing: DesignSystem.Spacing.md) {
                    if let error = viewModel.errorMessage {
                        FriendlyErrorBanner(message: error)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.signup(appState: appState)
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.background(scheme)))
                            } else {
                                Text("Create Account")
                                    .bold()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(DesignSystem.Colors.textPrimary(scheme))
                        .foregroundColor(DesignSystem.Colors.background(scheme))
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .disabled(viewModel.isLoading)
                    
                    Button(action: { dismiss() }) {
                        Text("ALREADY HAVE AN ACCOUNT? SIGN IN")
                            .font(DesignSystem.Typography.footnote)
                            .bold()
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onChange(of: viewModel.signupSuccess) { _, success in
            if success {
                dismiss()
            }
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(DesignSystem.Typography.caption)
            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
    }
    
    private func customField(title: String, placeholder: String = "", text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            TextField(placeholder, text: text)
                .textFieldStyle(StreamTextFieldStyle())
                .keyboardType(keyboard)
        }
    }
    
    private func customPasswordField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            HStack {
                if showPassword {
                    TextField("Enter password", text: text)
                } else {
                    SecureField("Enter password", text: text)
                }
                
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        .padding(.trailing, 4)
                }
            }
            .padding()
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            .font(DesignSystem.Typography.callout)
        }
    }
}
