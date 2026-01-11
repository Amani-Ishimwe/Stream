import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {

    // MARK: - App Flow
    @Published var showSplash: Bool = true
    @Published var showOnboarding: Bool = false

    // MARK: - Auth Flow
    @Published var isLoggedIn: Bool = false
    @Published var showAuthLanding: Bool = false
    @Published var showLogin: Bool = false
    @Published var showSignup: Bool = false
    @Published var showForgotPassword: Bool = false

    // MARK: - User Preferences
    @Published var selectedLanguage: String? = nil
    @Published var isDarkMode: Bool = true
    
    // MARK: - User Data
    @Published var currentUser: UserProfile?

    // MARK: - Services
    private let tokenManager = TokenManager.shared
    private let defaults = UserDefaults.standard

    init() {
        // Load onboarding status from UserDefaults (checks if the app is run for the first time)
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.showOnboarding = !hasCompletedOnboarding
        // If onboarding is done, we default to showing auth landing (until auth status is checked)
        self.showAuthLanding = hasCompletedOnboarding
        
        self.selectedLanguage = defaults.string(forKey: "selectedLanguage")
    }

    // MARK: - Startup
    func checkAuthenticationStatus() {
        isLoggedIn = tokenManager.getAccessToken() != nil
    }

    // MARK: - Onboarding
    func completeOnboarding() {
        showOnboarding = false
        showAuthLanding = true
        defaults.set(true, forKey: "hasCompletedOnboarding")
    }

    // MARK: - Navigation
    func navigateToLogin() {
        showAuthLanding = false
        showLogin = true
        showSignup = false
    }

    func navigateToSignup() {
        showAuthLanding = false
        showLogin = false
        showSignup = true
    }

    // MARK: - Auth Callbacks
    func loginSuccess() {
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.showLogin = false
            self.showSignup = false
        }
    }

    func logout() {
        tokenManager.clearTokens()
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.showAuthLanding = true
        }
    }

    // MARK: - Splash
    func completeSplash() {
        withAnimation {
            showSplash = false
        }
    }

    // MARK: - Language
    func chooseLanguage(_ language: String) {
        selectedLanguage = language
        defaults.set(language, forKey: "selectedLanguage")
    }
    
    // MARK: - User Profile
    func fetchCurrentUser() async {
        do {
            currentUser = try await APIService.shared.fetchCurrentUser()
        } catch {
            print("Failed to fetch current user: \(error)")
        }
    }
}
