import SwiftUI

struct ChangePinView: View {
    @State private var curPin = ""
    @State private var newPin = ""
    @State private var confirmPin = ""
    
    @Environment(\.dismiss) var dismiss
    @State private var showingSuccess = false
    
    var body: some View {
        Form {
            Section("Current PIN") {
                SecureField("Enter current 4-digit PIN", text: $curPin)
                    .keyboardType(.numberPad)
            }
            
            Section("New PIN") {
                SecureField("Enter new 4-digit PIN", text: $newPin)
                    .keyboardType(.numberPad)
                SecureField("Confirm new PIN", text: $confirmPin)
                    .keyboardType(.numberPad)
            }
            
            Section {
                Button(action: {
                    // Simulate API
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showingSuccess = true
                    }
                }) {
                    Text("Update PIN")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .listRowBackground(Color.blue)
                .foregroundColor(.white)
                .disabled(newPin.count != 4 || newPin != confirmPin)
                .opacity(newPin.count != 4 || newPin != confirmPin ? 0.6 : 1.0)
            }
        }
        .navigationTitle("Change PIN")
        .alert("PIN Updated", isPresented: $showingSuccess) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Your transaction PIN has been changed successfully.")
        }
    }
}
