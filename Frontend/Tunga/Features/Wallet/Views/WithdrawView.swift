import SwiftUI

struct WithdrawView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var amount = ""
    @State private var selectedBank: BankConnection?
    @State private var step = WithdrawStep.amount
    @State private var showSuccess = false
    
    enum WithdrawStep {
        case amount
        case bank
        case confirm
    }
    
    let banks = DemoDataManager.shared.bankConnections
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
                
                if showSuccess {
                    SuccessView(message: "$\(amount) is on its way to your \(selectedBank?.bankName ?? "Bank") account. Expected arrival: 1-3 business days.") {
                        dismiss()
                    }
                } else {
                    VStack(spacing: 24) {
                        switch step {
                        case .amount:
                            amountInputView
                        case .bank:
                            bankSelectionView
                        case .confirm:
                            confirmationView
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showSuccess {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                        }
                    }
                    
                    if step != .amount {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { backStep() }) {
                                Image(systemName: "chevron.left")
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                            }
                        }
                    }
                }
            }
        }
    }
    
    var stepTitle: String {
        switch step {
        case .amount: return "Withdraw Funds"
        case .bank: return "Select Destination"
        case .confirm: return "Confirm"
        }
    }
    
    func backStep() {
        withAnimation {
            if step == .confirm { step = .bank }
            else if step == .bank { step = .amount }
        }
    }
    
    // MARK: - Views
    
    var amountInputView: some View {
        VStack(spacing: 32) {
            VStack {
                Text("Available Balance")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                Text("$2,450.75")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.accent(colorScheme))
            }
            .padding(.top, 20)
            
            Spacer()
            
            HStack {
                Text("$").font(.system(size: 60, weight: .bold))
                TextField("0", text: $amount)
                    .font(.system(size: 60, weight: .bold))
                    .keyboardType(.decimalPad)
                    .fixedSize()
            }
            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
            
            Spacer()
            
            Button(action: {
                if !amount.isEmpty {
                    withAnimation { step = .bank }
                }
            }) {
                Text("Continue")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(DesignSystem.Colors.accent(colorScheme))
                    .cornerRadius(16)
            }
            .padding()
        }
    }
    
    var bankSelectionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Withdraw to")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    .padding(.horizontal)
                
                ForEach(banks) { bank in
                    Button(action: {
                        selectedBank = bank
                        withAnimation { step = .confirm }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: bank.logo)
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(DesignSystem.Colors.accent(colorScheme).opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                            
                            VStack(alignment: .leading) {
                                Text(bank.bankName)
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                Text(bank.accountNumber)
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                        }
                        .padding()
                        .background(DesignSystem.Colors.surface(colorScheme))
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    var confirmationView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Withdrawal Summary")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                
                Text("$\(amount)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                
                Divider().padding(.horizontal, 40)
                
                HStack {
                    Text("Destination")
                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    Spacer()
                    Text(selectedBank?.bankName ?? "Bank")
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                }
                .padding(.horizontal, 40)
                
                HStack {
                    Text("Fee")
                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    Spacer()
                    Text("Free")
                        .foregroundColor(DesignSystem.Colors.success(colorScheme))
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 40)
            }
            .padding(.vertical, 32)
            .background(DesignSystem.Colors.surface(colorScheme))
            .cornerRadius(24)
            .padding(.horizontal)
            
            Spacer()
            
            SlideToAction(title: "Slide to Withdraw") {
                // Mock process
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showSuccess = true
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }
            .padding()
        }
    }
}
