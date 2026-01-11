import SwiftUI
import LocalAuthentication

struct BiometricsView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "faceid")
                    .font(.system(size: 80))
                    .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                    .padding()
                    .background(
                        Circle().fill(
                            DesignSystem.Colors.accent(colorScheme).opacity(0.1)
                        ).frame(width: 160, height: 160)
                    )
                
                Text("Enable Face ID")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                
                Text("Unlock instantly and securely — your face/fingerprint never leaves your device.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    // Mock enabling biometrics
                    path.append(OnboardingStep.success)
                }) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Enable Biometrics")
                    }
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(DesignSystem.Colors.accent(colorScheme))
                    )
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    path.append(OnboardingStep.success)
                }) {
                    Text("Skip for now")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}
