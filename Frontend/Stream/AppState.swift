import SwiftUI
import Foundation
import Combine

extension Notification.Name {
    static let userSessionExpired = Notification.Name("StreamUserSessionExpired")
}

class AppState: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var colorSchemeOverride: ColorScheme? = nil {
        didSet {
            if let scheme = colorSchemeOverride {
                UserDefaults.standard.set(scheme == .dark ? "dark" : "light", forKey: "stream_theme")
            } else {
                UserDefaults.standard.removeObject(forKey: "stream_theme")
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // Auth Session
    var token: String? {
        UserDefaults.standard.string(forKey: "stream_auth_token")
    }
    
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "stream_theme") {
            self._colorSchemeOverride = Published(initialValue: savedTheme == "dark" ? .dark : .light)
        }
        
        NotificationCenter.default.publisher(for: .userSessionExpired)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.logout()
            }
            .store(in: &cancellables)
        
        checkAuth()
    }
    
    func checkAuth() {
        guard let _ = token else {
            self.isAuthenticated = false
            self.currentUser = nil
            return
        }
        
        Task { @MainActor in
            do {
                let response = try await APIService.shared.fetchProfile()
                if let profile = response.data {
                    self.currentUser = profile
                    self.isAuthenticated = true
                } else {
                    self.logout()
                }
            } catch {
                print("Session verification failed on launch: \(error)")
                self.logout()
            }
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
