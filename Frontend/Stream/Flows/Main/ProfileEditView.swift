import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var avatarUrl: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        avatarSection
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            InputField(label: "FULL NAME", text: $name)
                            InputField(label: "PHONE NUMBER", text: $phone)
                            InputField(label: "AVATAR URL", text: $avatarUrl)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        if let error = errorMessage {
                            FriendlyErrorBanner(message: error)
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                }
                
                Button(action: saveProfile) {
                    if isLoading {
                        ProgressView().tint(DesignSystem.Colors.background(scheme))
                    } else {
                        Text("SAVE CHANGES")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let user = appState.currentUser {
                name = user.name
                phone = user.phone ?? ""
                avatarUrl = user.avatarUrl ?? ""
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button("CANCEL") { presentationMode.wrappedValue.dismiss() }
                .font(DesignSystem.Typography.caption).bold()
            Spacer()
            Text("EDIT PROFILE")
                .font(DesignSystem.Typography.headline)
            Spacer()
            Button(action: saveProfile) {
                Text("DONE")
                    .font(DesignSystem.Typography.caption).bold()
            }
        }
        .padding()
        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
    }
    
    private var avatarSection: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: avatarUrl)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                default:
                    Circle()
                        .fill(DesignSystem.Colors.surface(scheme))
                        .frame(width: 100, height: 100)
                        .overlay(Image(systemName: "person.fill").font(.largeTitle))
                }
            }
            .overlay(Circle().stroke(DesignSystem.Colors.textPrimary(scheme), lineWidth: 1))
            
            Text("CHANGE PHOTO")
                .font(DesignSystem.Typography.caption).bold()
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
        }
    }
    
    func saveProfile() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.updateProfile(name: name, phone: phone, avatarUrl: avatarUrl)
                if response.success {
                    // Update local app state
                    appState.currentUser?.name = name
                    appState.currentUser?.phone = phone
                    appState.currentUser?.avatarUrl = avatarUrl
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = response.message ?? "Failed to update profile"
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct InputField: View {
    let label: String
    @Binding var text: String
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            TextField("", text: $text)
                .font(DesignSystem.Typography.body)
                .padding()
                .background(DesignSystem.Colors.surface(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
        }
    }
}
