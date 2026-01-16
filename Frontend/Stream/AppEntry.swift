import SwiftUI

@main
struct StreamApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            StreamRootView()
                .environmentObject(appState)
                .preferredColorScheme(appState.colorSchemeOverride)
        }
    }
}
