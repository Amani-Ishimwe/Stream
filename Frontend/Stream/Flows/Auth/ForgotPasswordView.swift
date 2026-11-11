import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    @StateObject private var viewModel = AuthViewModel()
    
    @State private var email = ""
    @State private var code = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var step = 1 // 1: Email, 2: Code & New Password, 3: Success
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        if step == 1 {
                            emailStep
                        } else if step == 2 {
                            resetStep
                        } else {
                            successStep
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            }
            Spacer()
            Text("RESET PASSWORD")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            Spacer()
            Rectangle().frame(width: 20, height: 1).opacity(0)
        }
        .padding()
    }
    
    private var emailStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: 8) {
                Image(systemName: "envelope.badge.shield.half.filled")
                    .font(.system(size: 54))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Text("Forgot Your Password?")
                    .font(DesignSystem.Typography.title2)
                    .bold()
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Text("Enter the email address registered with your account. We will send you a 6-digit code to reset your password.")
                    .font(DesignSystem.Typography.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("EMAIL ADDRESS")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                TextField("name@example.com", text: $email)
                    .textFieldStyle(StreamTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            if let error = viewModel.errorMessage {
                FriendlyErrorBanner(message: error)
            }
            
            Button(action: {
                Task {
                    let success = await viewModel.sendResetCode(emailToReset: email)
                    if success {
                        withAnimation { step = 2 }
                    }
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().tint(DesignSystem.Colors.background(scheme))
                    } else {
                        Text("Send Verification Code")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(DesignSystem.Colors.textPrimary(scheme))
                .foregroundColor(DesignSystem.Colors.background(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
            }
            .disabled(email.isEmpty || viewModel.isLoading)
        }
    }
    
    private var resetStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: 8) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 54))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Text("Enter Code & New Password")
                    .font(DesignSystem.Typography.title2)
                    .bold()
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Text("We sent a 6-digit code to \(email). Please enter it below along with your new password.")
                    .font(DesignSystem.Typography.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("6-DIGIT CODE")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                TextField("123456", text: $code)
                    .textFieldStyle(StreamTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("NEW PASSWORD")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                HStack {
                    if showNewPassword {
                        TextField("New password", text: $newPassword)
                    } else {
                        SecureField("New password", text: $newPassword)
                    }
                    Button(action: { showNewPassword.toggle() }) {
                        Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    }
                }
                .padding()
                .background(DesignSystem.Colors.surface(scheme))
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("CONFIRM NEW PASSWORD")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                HStack {
                    if showConfirmPassword {
                        TextField("Re-enter new password", text: $confirmPassword)
                    } else {
                        SecureField("Re-enter new password", text: $confirmPassword)
                    }
                    Button(action: { showConfirmPassword.toggle() }) {
                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    }
                }
                .padding()
                .background(DesignSystem.Colors.surface(scheme))
                .cornerRadius(12)
            }
            
            if let error = viewModel.errorMessage {
                FriendlyErrorBanner(message: error)
            }
            
            Button(action: {
                guard newPassword == confirmPassword else {
                    viewModel.errorMessage = "Passwords do not match. Please re-enter them."
                    return
                }
                guard newPassword.count >= 4 else {
                    viewModel.errorMessage = "Password should be at least 4 characters long."
                    return
                }
                Task {
                    let success = await viewModel.resetPassword(email: email, code: code, newPassword: newPassword)
                    if success {
                        withAnimation { step = 3 }
                    }
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().tint(DesignSystem.Colors.background(scheme))
                    } else {
                        Text("Reset Password")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(DesignSystem.Colors.textPrimary(scheme))
                .foregroundColor(DesignSystem.Colors.background(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
            }
            .disabled(code.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || viewModel.isLoading)
            
            Button(action: {
                Task {
                    let _ = await viewModel.sendResetCode(emailToReset: email)
                }
            }) {
                Text("Didn't receive a code? Resend")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
        }
    }
    
    private var successStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(DesignSystem.Colors.successGreen)
            
            Text("Password Reset Complete")
                .font(DesignSystem.Typography.title)
                .bold()
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            Text("Your password has been successfully updated. You can now log in to your account with your new password.")
                .font(DesignSystem.Typography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            Button("Sign In Now") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 16)
        }
        .padding(.vertical, 40)
    }
}
