import SwiftUI

struct OTPVerificationView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) var colorScheme
    @State private var otpText: String = ""
    @State private var isVerifying = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.large) {
                Text("Verify Identity")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    .padding(.top, 40)
                
                Text("Enter the code sent to your email")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                
                // Custom OTP Field
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DesignSystem.Colors.surface(colorScheme))
                                .frame(width: 45, height: 55)
                            
                            if otpText.count > index {
                                let charIndex = otpText.index(otpText.startIndex, offsetBy: index)
                                Text(String(otpText[charIndex]))
                                    .font(DesignSystem.Typography.title)
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                            }
                        }
                    }
                }
                .overlay(
                    TextField("", text: $otpText)
                        .focused($isFocused)
                        .keyboardType(.numberPad)
                        .opacity(0.01) // Invisible but captures input
                        .onChange(of: otpText) { newValue in
                            if newValue.count > 6 {
                                otpText = String(newValue.prefix(6))
                            }
                            if newValue.count == 6 {
                                verifyOTP()
                            }
                        }
                )
                .padding()
                
                if isVerifying {
                    HStack {
                        ProgressView()
                            .tint(DesignSystem.Colors.accent(colorScheme))
                        Text("Securing your wallet...")
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            .font(DesignSystem.Typography.caption)
                    }
                    .transition(.opacity)
                }
                
                Spacer()
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    func verifyOTP() {
        withAnimation {
            isVerifying = true
        }
        
        // Mock verification delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isVerifying = false
            path.append(OnboardingStep.createPin)
        }
    }
}
