import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = AuthViewModel()
    @State private var isSignup = false
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xl * 2) {
                Spacer()
                
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Image(systemName: "waveform.path.ecg.graph")
                        .font(.system(size: 72))
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("STREAM")
                            .font(DesignSystem.Typography.title)
                            .tracking(8)
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                        
                        Text("PREMIUM MOBILE BANKING")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    }
                }
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("EMAIL")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        TextField("", text: $viewModel.email)
                            .textFieldStyle(StreamTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PASSWORD")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        SecureField("", text: $viewModel.password)
                            .textFieldStyle(StreamTextFieldStyle())
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error.uppercased())
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity)
                            .background(DesignSystem.Colors.surface(scheme))
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    Button(action: {
                        Task {
                            await viewModel.login(appState: appState)
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.background(scheme)))
                            } else {
                                Text("AUTHORIZE ACCESS")
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
                    
                    Button(action: { isSignup = true }) {
                        Text("CREATE NEW ACCOUNT")
                            .font(DesignSystem.Typography.footnote)
                            .bold()
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    }
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $isSignup) {
            SignupView()
        }
    }
}

struct StreamTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var scheme
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            .font(DesignSystem.Typography.callout)
    }
}
