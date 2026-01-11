import SwiftUI

struct AccountCreationView: View {
    @Binding var path: NavigationPath
    @Binding var showOnboarding: Bool
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isEmailValid = false
    @State private var isPasswordVisible = false
    @State private var focusedField: Field?
    @State private var isLoading = false
    
    enum Field {
        case fullName, email, password
    }
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil } // Dismiss keyboard
            
            VStack(spacing: DesignSystem.Spacing.large) {
                // Header with Back Button
                HStack {
                    Button(action: {
                        if path.isEmpty {
                            appState.showSignup = false
                            appState.showAuthLanding = true
                        } else {
                            path.removeLast()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.textPrimary(colorScheme).opacity(0.1))
                            )
                    }
                    .padding(.leading, DesignSystem.Spacing.medium)
                    
                    Spacer()
                }
                .overlay(
                    Text("Create Account")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                )
                .padding(.top, 20)
                
                VStack(spacing: DesignSystem.Spacing.large) {
                    VStack(spacing: DesignSystem.Spacing.large) {
                        // Full Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Full Name", text: $fullName)
                                .textContentType(.name)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(DesignSystem.Colors.surface(colorScheme))
                                )
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .onTapGesture { focusedField = .fullName }
                        
                        // Email Input
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                TextField("Email", text: $email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .onChange(of: email) { _ in validateEmail() }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(DesignSystem.Colors.surface(colorScheme))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(email.isEmpty ? Color.clear : (isEmailValid ? DesignSystem.Colors.accent(colorScheme) : DesignSystem.Colors.primary(colorScheme).opacity(0.3)), lineWidth: 1)
                                    )
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                
                                if !email.isEmpty {
                                    Image(systemName: isEmailValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                                }
                            }
                        }
                        .onTapGesture { focusedField = .email }
                        
                        // Password Input
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if isPasswordVisible {
                                    TextField("Password", text: $password)
                                        .textContentType(.newPassword)
                                        .padding()
                                } else {
                                    SecureField("Password", text: $password)
                                        .textContentType(.newPassword)
                                        .padding()
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.Colors.surface(colorScheme))
                            )
                            .overlay(
                                HStack {
                                    Spacer()
                                    Button(action: { isPasswordVisible.toggle() }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                                            .padding()
                                    }
                                }
                            )
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        }
                        .onTapGesture { focusedField = .password }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    
                    Spacer()
                    
                    Button(action: {
                        isLoading = true
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isLoading = false
                            // Store name in appState for the avatar
                            if appState.currentUser == nil {
                                appState.currentUser = UserProfile(id: UUID().uuidString, name: fullName, email: email, balance: 0)
                            } else {
                                appState.currentUser?.name = fullName
                            }
                            path.append(OnboardingStep.createPin)
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView().tint(DesignSystem.Colors.primary(colorScheme))
                            } else {
                                Text("Sign Up")
                            }
                        }
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isFormValid ? DesignSystem.Colors.accent(colorScheme) : DesignSystem.Colors.accent(colorScheme).opacity(0.3))
                                .shadow(color: DesignSystem.Colors.primary(colorScheme).opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xLarge)
                    .padding(.bottom, DesignSystem.Spacing.xLarge)
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Helpers
    private func validateEmail() {
        // Simple regex or check
        isEmailValid = email.contains("@") && email.contains(".")
    }
    
    private var isFormValid: Bool {
        !fullName.isEmpty && isEmailValid && password.count >= 8
    }
    
    private func passwordStrengthColor(_ index: Int) -> Color {
        let length = password.count
        if length < 5 { return index == 0 ? .red : .gray.opacity(0.3) }
        if length < 8 { return index < 2 ? .orange : .gray.opacity(0.3) }
        if length < 10 { return index < 3 ? .yellow : .gray.opacity(0.3) }
        return .green
    }
    
    private func passwordStrengthText() -> String {
        let length = password.count
        if length < 5 { return "Weak" }
        if length < 8 { return "Fair" }
        if length < 10 { return "Good" }
        return "Strong"
    }
}

