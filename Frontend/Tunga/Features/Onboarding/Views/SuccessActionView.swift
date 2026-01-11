import SwiftUI

struct SuccessActionView: View {
    @Binding var showOnboarding: Bool
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    // Simple confetti simulation manually
    @State private var confettiY: CGFloat = -100
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
            
            // Confetti (Mock)
            ForEach(0..<20) { index in
                Circle()
                    .fill([DesignSystem.Colors.accent(colorScheme), DesignSystem.Colors.textPrimary(colorScheme)].randomElement()!)
                    .frame(width: 8, height: 8)
                    .offset(x: CGFloat.random(in: -150...150), y: confettiY + CGFloat.random(in: 0...200))
                    .opacity(confettiY > 100 ? 1 : 0) // Appear logic simplified
            }
            
            VStack {
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(DesignSystem.Colors.success(colorScheme))
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("Welcome!")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    .padding(.top, 20)
                    .opacity(opacity)
                
                Text("Your SwiftPay+ wallet is ready.")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    .padding(.top, 8)
                    .opacity(opacity)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                confettiY = 800
            }
            
            // Delay before entering the app
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                appState.completeOnboarding()
            }
        }
        .navigationBarHidden(true)
    }
}
