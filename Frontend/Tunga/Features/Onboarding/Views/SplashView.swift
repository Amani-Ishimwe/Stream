import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "creditcard.and.123")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                
                Text("SwiftPay+")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                
                Text("Secure, seamless payments at your fingertips")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .scaleEffect(appState.showSplash ? 1.0 : 0.95)
            .opacity(appState.showSplash ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.8), value: appState.showSplash)
        }
    }
}

