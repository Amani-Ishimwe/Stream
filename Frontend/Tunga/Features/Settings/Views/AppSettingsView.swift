import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedLanguage: String = "English"
    
    let languages = ["English", "Spanish", "French"]
    
    var body: some View {
        List {
            Section("Appearance") {
                Toggle(isOn: $appState.isDarkMode) {
                    Label("Dark Mode", systemImage: "moon.fill")
                }
            }
            
            Section("Preferences") {
                HStack {
                    Label("Language", systemImage: "globe")
                    Spacer()
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Toggle(isOn: .constant(true)) {
                    Label("Haptic Feedback", systemImage: "iphone.gen3")
                }
            }
            
            Section("Account Actions") {
                NavigationLink(destination: Text("Export Data View")) {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle("App Settings")
    }
}
