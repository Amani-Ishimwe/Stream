import SwiftUI

struct PINChangeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    
    @State private var oldPin: String = ""
    @State private var newPin: String = ""
    @State private var confirmPin: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                VStack(spacing: DesignSystem.Spacing.xl) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        SecureInputField(label: "CURRENT PIN", text: $oldPin)
                        SecureInputField(label: "NEW 6-DIGIT PIN", text: $newPin)
                        SecureInputField(label: "CONFIRM NEW PIN", text: $confirmPin)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                            .padding()
                            .background(DesignSystem.Colors.surface(scheme))
                            .cornerRadius(8)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                    
                    Text("Your PIN protects your funds. Ensure it is unique and difficult to guess.")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, DesignSystem.Spacing.xl)
                
                Spacer()
                
                Button(action: savePin) {
                    if isLoading {
                        ProgressView().tint(DesignSystem.Colors.background(scheme))
                    } else {
                        Text("UPDATE SECURITY PIN")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: isFormValid))
                .padding()
                .disabled(!isFormValid)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var header: some View {
        HStack {
            Button("CANCEL") { presentationMode.wrappedValue.dismiss() }
                .font(DesignSystem.Typography.caption).bold()
            Spacer()
            Text("SECURITY PIN")
                .font(DesignSystem.Typography.headline)
            Spacer()
            Rectangle().fill(Color.clear).frame(width: 50)
        }
        .padding()
        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
    }
    
    private var isFormValid: Bool {
        oldPin.count >= 4 && newPin.count == 6 && newPin == confirmPin
    }
    
    func savePin() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.changePin(oldPin: oldPin, newPin: newPin)
                if response.success {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = response.message ?? "Failed to update PIN"
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct SecureInputField: View {
    let label: String
    @Binding var text: String
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            SecureField("", text: $text)
                .font(DesignSystem.Typography.body)
                .padding()
                .background(DesignSystem.Colors.surface(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                .keyboardType(.numberPad)
        }
    }
}
