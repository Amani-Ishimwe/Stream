import SwiftUI

struct SecuritySettingsView: View {
    @State private var biometricsEnabled = true
    
    var body: some View {
        List {
            Section(header: Text("Authentication")) {
                NavigationLink("Change PIN", destination: Text("Change PIN Flow"))
                Toggle("Enable Biometrics", isOn: $biometricsEnabled)
            }
            
            Section(header: Text("Device Management")) {
                NavigationLink("Active Sessions", destination: Text("Session List"))
                Button("Logout all devices") {
                    // Action
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Security Center")
    }
}
