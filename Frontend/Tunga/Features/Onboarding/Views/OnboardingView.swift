import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var path: NavigationPath
    @EnvironmentObject var appState: AppState
    
    init(showOnboarding: Binding<Bool>, initialStep: OnboardingStep? = nil) {
        self._showOnboarding = showOnboarding
        var navPath = NavigationPath()
        if let step = initialStep {
            navPath.append(step)
        }
        self._path = State(initialValue: navPath)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(path: $path)
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .valueSlides:
                        ValueSlidesView(path: $path)
                    case .createAccount:
                         AccountCreationView(path: $path, showOnboarding: $showOnboarding)
                    case .verifyIdentity: // Assuming AccountCreation or Login leads here
                        OTPVerificationView(path: $path)
                    case .createPin:
                        SecurePINView(path: $path)
                    case .biometrics:
                         BiometricsView(path: $path)
                    case .connectBank:
                        BankConnectionView(path: $path)
                    case .permissions:
                        PermissionsView(path: $path)
                    case .success:
                        SuccessActionView(showOnboarding: $showOnboarding)
                    }
                }
        }
    }
}
