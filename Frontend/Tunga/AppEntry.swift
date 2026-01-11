import SwiftUI

@main
struct SwiftPayPlusApp: App {
    // ObservableObject to hold global app state (authentication, theme, etc.)
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            // Root View decides which screen to show
            Group {
                if appState.showSplash {
                    SplashView()
                } else if appState.selectedLanguage == nil {
                    LanguageSelectionView()
                } else if appState.showOnboarding {
                    OnboardingView(showOnboarding: $appState.showOnboarding)
                } else if appState.isLoggedIn {
                    MainTabView() // TabView containing Dashboard, History, QRScan
                } else if appState.showAuthLanding {
                    AuthLandingView(showAuthLanding: $appState.showAuthLanding)
                } else if appState.showLogin {
                    LoginView()
                } else if appState.showSignup {
                    OnboardingView(showOnboarding: .constant(false), initialStep: .createAccount)
                } else {
                    // Fallback to AuthLanding if nothing else matches
                    AuthLandingView(showAuthLanding: $appState.showAuthLanding)
                }
            }
            .sheet(isPresented: $appState.showForgotPassword) {
                ForgotPasswordView()
            }
            // Inject AppState into the environment so all views can access it
            .environmentObject(appState)
            .preferredColorScheme(appState.isDarkMode ? .dark : .light)
            .onAppear {
                // Check local storage for existing tokens to determine isLoggedIn status
                appState.checkAuthenticationStatus()
                // Auto dismiss splash after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    appState.completeSplash()
                }
            }
        }
    }
}

// Helper view for the authenticated state
struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch selectedTab {
                case .home:
                    DashboardView()
                case .transactions:
                    TransactionsView()
                case .cards:
                    CardsView()
                case .requests:
                    RequestsView()
                case .more:
                    MoreView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
