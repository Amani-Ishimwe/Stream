import SwiftUI

struct StreamRootView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else if !appState.isAuthenticated {
                AuthFlowView()
            } else {
                MainContainerView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

// Placeholder views for now
struct AuthFlowView: View {
    var body: some View {
        LoginView()
    }
}
