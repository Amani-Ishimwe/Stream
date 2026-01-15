import SwiftUI
import Foundation
import Combine

class AppState: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    
    // Auth Session
    var token: String? {
        UserDefaults.standard.string(forKey: "stream_auth_token")
    }
    
    init() {
        checkAuth()
    }
    
    func checkAuth() {
        if let token = token {
            // Ideally verify token here or let SplashView handle it
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
    
    func login(user: UserProfile, token: String) {
        UserDefaults.standard.set(token, forKey: "stream_auth_token")
        self.currentUser = user
        self.isAuthenticated = true
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "stream_auth_token")
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
