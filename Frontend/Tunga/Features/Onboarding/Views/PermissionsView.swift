import SwiftUI

struct PermissionsView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) var colorScheme
    
    @State private var cameraEnabled = false
    @State private var notificationsEnabled = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("Permissions")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                
                Text("We need a few permissions to give you the best experience.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 20) {
                    PermissionRow(icon: "camera.fill", title: "Camera", description: "Required for scanning QR codes", isOn: $cameraEnabled)
                    PermissionRow(icon: "bell.fill", title: "Notifications", description: "Get alerts for payments and requests", isOn: $notificationsEnabled)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    path.append(OnboardingStep.success)
                }) {
                    Text("Continue")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadius)
                                .fill(DesignSystem.Colors.accent(colorScheme))
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct PermissionRow: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isOn ? DesignSystem.Colors.accent(colorScheme) : DesignSystem.Colors.primary(colorScheme).opacity(0.3))
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                Text(description)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(DesignSystem.Colors.accent(colorScheme))
        }
        .padding()
        .background(DesignSystem.Colors.surface(colorScheme))
        .cornerRadius(12)
    }
}
