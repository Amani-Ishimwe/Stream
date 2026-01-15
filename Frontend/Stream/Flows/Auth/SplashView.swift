import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var scheme
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.lg) {
                Image(systemName: "waveform.path.ecg.graph")
                    .font(.system(size: 80))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                VStack(spacing: 4) {
                    Text("STREAM")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                        .tracking(12)
                    
                    Text("PREMIUM ASSET MANAGEMENT")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        .tracking(2)
                }
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                appState.checkAuth()
            }
        }
    }
}
