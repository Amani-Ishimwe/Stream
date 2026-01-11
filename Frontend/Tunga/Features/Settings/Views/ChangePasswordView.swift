import SwiftUI

struct ChangePasswordView: View {
    @State private var curPass = ""
    @State private var newPass = ""
    @State private var confirmPass = ""
    
    @Environment(\.dismiss) var dismiss
    @State private var showingSuccess = false
    
    var body: some View {
        Form {
            Section("Current Password") {
                SecureField("Enter current password", text: $curPass)
            }
            
            Section("New Password") {
                SecureField("Enter new password", text: $newPass)
                SecureField("Confirm new password", text: $confirmPass)
            }
            
            Section {
                Button(action: {
                    // Simulate API
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showingSuccess = true
                    }
                }) {
                    Text("Update Password")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .listRowBackground(Color.blue)
                .foregroundColor(.white)
                .disabled(newPass.isEmpty || newPass != confirmPass)
                .opacity(newPass.isEmpty || newPass != confirmPass ? 0.6 : 1.0)
            }
        }
        .navigationTitle("Change Password")
        .alert("Password Updated", isPresented: $showingSuccess) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Your password has been changed successfully.")
        }
    }
}
