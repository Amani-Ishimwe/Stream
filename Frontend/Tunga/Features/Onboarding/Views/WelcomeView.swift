import SwiftUI

struct WelcomeView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo Section
                VStack(spacing: 20) {
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 80))
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                    
                    Text("SwiftPay+")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                }
                .padding(.bottom, 40)
                
                // Text Section
                VStack(spacing: 16) {
                    Text("Fast, Secure Money Movement for Everyone.")
                        .font(DesignSystem.Typography.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Send, request, and manage money with total peace of mind.")
                        .font(DesignSystem.Typography.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Primary Button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    path.append(OnboardingStep.valueSlides)
                }) {
                    Text("Get Started")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(DesignSystem.Colors.accent(colorScheme))
                        .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .accessibilityLabel("Get Started")
                .accessibilityHint("Begins account setup")
            }
        }
        .navigationBarHidden(true)
    }
}
