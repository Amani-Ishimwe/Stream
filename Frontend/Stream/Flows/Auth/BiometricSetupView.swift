import SwiftUI

struct BiometricSetupView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xl * 2) {
                Spacer()
                
                Image(systemName: "faceid")
                    .font(.system(size: 72))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("BIOMETRIC ACCESS")
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    
                    Text("ENFORCE BIOMETRIC PROTOCOLS FOR ENHANCED ASSET SECURITY AND RAPID AUTHORIZATION.")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    Button(action: {
                        appState.hasCompletedOnboarding = true
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("ENABLE PROTOCOL")
                            .font(DesignSystem.Typography.callout)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.textPrimary(scheme))
                            .foregroundColor(DesignSystem.Colors.background(scheme))
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                    }
                    
                    Button(action: {
                        appState.hasCompletedOnboarding = true
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("DEFER SECURE SETUP")
                            .font(DesignSystem.Typography.footnote)
                            .bold()
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, 40)
            }
        }
    }
}
