import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var message: String?
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private let api = APIService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Forgot Password")
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        
                        Text("Enter your email address and we'll send you a link to reset your password.")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(DesignSystem.Colors.surface(colorScheme))
                            .cornerRadius(12)
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        
                        if let message = message {
                            Text(message)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(message.contains("Error") ? DesignSystem.Colors.error(colorScheme) : DesignSystem.Colors.success(colorScheme))
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: {
                            Task {
                                await sendResetLink()
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .tint(DesignSystem.Colors.primary(colorScheme))
                            } else {
                                Text("Send Reset Link")
                                    .font(DesignSystem.Typography.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(DesignSystem.Colors.accent(colorScheme))
                                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                    .cornerRadius(16)
                            }
                        }
                        .disabled(email.isEmpty || isLoading)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                }
            }
        }
    }
    
    @MainActor
    func sendResetLink() async {
        isLoading = true
        message = nil
        
        do {
            message = try await api.forgotPassword(email: email)
        } catch {
            message = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
