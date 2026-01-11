import SwiftUI

struct EditProfileView: View {
    @State private var name: String = "John Doe"
    @State private var email: String = "john.doe@swiftpay.com"
    @State private var phone: String = "+1 (555) 123-4567"
    @State private var address: String = "123 Swift Lane, CA"
    @State private var showPhotoPicker: Bool = false
    
    var body: some View {
        Form {
            Section("Profile Photo") {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(Text("JD").bold().font(.title))
                        .onTapGesture { showPhotoPicker = true }
                    Spacer()
                }
            }
            
            Section("Personal Information") {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Address", text: $address)
            }
        }
        .navigationTitle("Edit Profile")
        .alert("Change Photo", isPresented: $showPhotoPicker) {
            Button("Choose from Library") { }
            Button("Take Photo") { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This feature is currently simulated.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if #available(iOS 16.0, *) {
                    Button("Save") {
                        // ViewModel: Call /user/update endpoint
                    }
                    .bold()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}
