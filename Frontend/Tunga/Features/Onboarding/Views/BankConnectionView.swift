import SwiftUI

struct BankConnectionView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) var colorScheme
    
    let banks = ["Chase", "Bank of America", "Wells Fargo", "Citi", "US Bank"]
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Connect Your Bank")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    .padding(.top, 40)
                
                Text("Link your bank account for easy top-ups and withdrawals.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(banks, id: \.self) { bank in
                            VStack {
                                Circle()
                                    .fill(DesignSystem.Colors.accent(colorScheme))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(String(bank.prefix(1)))
                                            .font(.title)
                                            .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                    )
                                
                                Text(bank)
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                            }
                            .frame(width: 100, height: 120)
                            .background(DesignSystem.Colors.surface(colorScheme))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                Button(action: {
                    path.append(OnboardingStep.permissions)
                }) {
                    Text("Skip for now")
                         .font(DesignSystem.Typography.body)
                         .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                }
                .padding(.bottom, 40)
            }
        }
    }
}
