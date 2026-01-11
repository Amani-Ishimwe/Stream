import SwiftUI

struct TopUpView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var amount = ""
    @State private var selectedBank: BankConnection?
    @State private var step = TopUpStep.bank
    @State private var showSuccess = false
    
    enum TopUpStep {
        case bank
        case amount
        case confirm
    }
    
    let banks = DemoDataManager.shared.bankConnections
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
                
                if showSuccess {
                    SuccessView(message: "$\(amount) successfully added to your wallet from \(selectedBank?.bankName ?? "Bank")") {
                        dismiss()
                    }
                } else {
                    VStack(spacing: 24) {
                        switch step {
                        case .bank:
                            bankSelectionView
                        case .amount:
                            amountInputView
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
                    
                    if step != .bank {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { backStep() }) {
                                Image(systemName: "chevron.left")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var stepTitle: String {
        switch step {
        case .bank: return "Select Source"
        case .amount: return "Add Funds"
        case .confirm: return "Confirm"
        }
    }
    
    func backStep() {
        withAnimation {
            if step == .confirm { step = .amount }
            else if step == .amount { step = .bank }
        }
    }
    
    // MARK: - Views
    
    var bankSelectionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Saved Methods")
                    .font(DesignSystem.Typography.headline)
                    .padding(.horizontal)
                
                ForEach(banks) { bank in
                    Button(action: {
                        selectedBank = bank
                        withAnimation { step = .amount }
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
                
                Button(action: { /* Link Bank */ }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Connect New Bank")
                    }
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignSystem.Colors.accent(colorScheme))
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    var amountInputView: some View {
        VStack(spacing: 32) {
            // Summary
            HStack {
                Image(systemName: selectedBank?.logo ?? "building.columns")
                Text("From \(selectedBank?.bankName ?? "Bank")")
                    .font(DesignSystem.Typography.callout)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(DesignSystem.Colors.surface(colorScheme))
            .cornerRadius(20)
            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
            
            Spacer()
            
            // Large Input
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
                    withAnimation { step = .confirm }
                }
            }) {
                Text("Review Top-Up")
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
    
    var confirmationView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Check the details")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                
                Text("$\(amount)")
                    .font(.system(size: 48, weight: .bold))
                
                Divider().padding(.horizontal, 40)
                
                HStack {
                    Text("Source")
                    Spacer()
                    Text(selectedBank?.bankName ?? "Bank")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 40)
            }
            .padding(.vertical, 32)
            .background(DesignSystem.Colors.surface(colorScheme))
            .cornerRadius(24)
            .padding(.horizontal)
            
            Spacer()
            
            SlideToAction(title: "Slide to Confirm") {
                // Mock process
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showSuccess = true
                }
            }
            .padding()
        }
    }
}

