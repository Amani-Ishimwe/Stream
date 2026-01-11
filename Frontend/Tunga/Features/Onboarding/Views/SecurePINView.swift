import SwiftUI

struct SecurePINView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) private var colorScheme
    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var isConfirming = false
    @State private var statusMessage = "Create a 4-digit PIN"

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()

            VStack {
                // Header with Back Button
                HStack {
                    Button(action: {
                        path.removeLast()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.textPrimary(colorScheme).opacity(0.1))
                            )
                    }
                    .padding(.leading, DesignSystem.Spacing.medium)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()

                // Title
                Text(isConfirming ? "Confirm PIN" : "Create PIN")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))

                // Status
                Text(statusMessage)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    .padding(.bottom, 20)

                // PIN Dots
                HStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { index in
                        if index < (isConfirming ? confirmPin.count : pin.count) {
                            Circle()
                                .fill(DesignSystem.Colors.accent(colorScheme))
                                .frame(width: 16, height: 16)
                                .transition(.scale)
                        } else {
                            Circle()
                                .stroke(DesignSystem.Colors.textSecondary(colorScheme).opacity(0.3), lineWidth: 1)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .padding(.bottom, 40)
                .animation(.spring(), value: isConfirming ? confirmPin : pin)

                // Numeric Keypad
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 25) {
                    ForEach(1...9, id: \.self) { number in
                        SecureKeypadButton(number: "\(number)", colorScheme: colorScheme) {
                            addDigit("\(number)")
                        }
                    }

                    // Empty placeholder
                    SecureKeypadButton(number: "", colorScheme: colorScheme) { }
                        .opacity(0)
                        .disabled(true)

                    // Zero
                    SecureKeypadButton(number: "0", colorScheme: colorScheme) {
                        addDigit("0")
                    }

                    // Delete button
                    Button(action: deleteDigit) {
                        Image(systemName: "delete.left.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                            .frame(width: 80, height: 80)
                            .background(DesignSystem.Colors.textPrimary(colorScheme).opacity(0.1))
                            .clipShape(Circle())
                            .accessibilityLabel("Delete digit")
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - PIN Logic

    private func addDigit(_ digit: String) {
        let current = isConfirming ? confirmPin : pin
        guard current.count < 4 else { return }

        if isConfirming {
            confirmPin += digit
            triggerHaptic(.tap)
            if confirmPin.count == 4 { validateAndFinish() }
        } else {
            pin += digit
            triggerHaptic(.tap)
            if pin.count == 4 {
                // Success feedback
                triggerHaptic(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isConfirming = true
                    statusMessage = "Re-enter your PIN"
                }
            }
        }
    }

    private func deleteDigit() {
        triggerHaptic(.tap)
        if isConfirming {
            if !confirmPin.isEmpty { confirmPin.removeLast() }
        } else {
            if !pin.isEmpty { pin.removeLast() }
        }
    }

    private func validateAndFinish() {
        if pin == confirmPin {
            statusMessage = "Success!"
            triggerHaptic(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                path.append(OnboardingStep.biometrics) // Proceed to next step
            }
        } else {
            statusMessage = "PINs do not match. Try again."
            triggerHaptic(.error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isConfirming = false
                pin = ""
                confirmPin = ""
                statusMessage = "Create a 4-digit PIN"
            }
        }
    }

    enum HapticType {
        case success
        case error
        case tap
    }

    private func triggerHaptic(_ type: HapticType) {
        switch type {
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .tap:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

// MARK: - Keypad Button

private struct SecureKeypadButton: View {
    let number: String
    let colorScheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                .frame(width: 80, height: 80)
                .background(DesignSystem.Colors.surface(colorScheme))
                .clipShape(Circle())
                .accessibilityLabel(number)
        }
    }
}
