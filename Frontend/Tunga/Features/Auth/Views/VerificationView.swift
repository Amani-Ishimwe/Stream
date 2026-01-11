import SwiftUI
import Combine

struct VerificationView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var otpCode: String = ""
    @State private var timerActive: Bool = true
    @State private var timeRemaining: Int = 60
    let type: String // e.g., "Email" or "Phone"

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Image(systemName: "envelope.badge.shield.half.fill")
                    .font(.system(size: 80))
                    .foregroundColor(DesignSystem.Colors.accent(colorScheme))

                Text("Verify Your \(type)")
                    .font(DesignSystem.Typography.title).bold()
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                
                Text("Enter the 6-digit code sent to your registered \(type.lowercased()).")
                    .multilineTextAlignment(.center)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                
                // OTP Input Field (Mocked 6 digit input)
                TextField("------", text: $otpCode)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(width: 180)
                    .padding(.vertical)
                    .background(DesignSystem.Colors.surface(colorScheme))
                    .cornerRadius(16)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    .onChange(of: otpCode) { oldValue, newValue in
                        if newValue.count > 6 {
                            otpCode = String(newValue.prefix(6))
                        }
                    }

                Button(action: { /* ViewModel verify call */ }) {
                    Text("Verify Account")
                        .font(DesignSystem.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(otpCode.count == 6 ? DesignSystem.Colors.accent(colorScheme) : DesignSystem.Colors.accent(colorScheme).opacity(0.3))
                        .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .disabled(otpCode.count != 6)
                
                // Resend Timer
                HStack {
                    Text("Didn't receive the code?")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    if timerActive {
                        Text("Resend in \(timeRemaining)s")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            .onReceive(timer) { _ in
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                } else {
                                    timerActive = false
                                }
                            }
                    } else {
                        Button("Resend Code") {
                            timeRemaining = 60
                            timerActive = true
                            // ViewModel resend code call
                        }
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
    }
}
