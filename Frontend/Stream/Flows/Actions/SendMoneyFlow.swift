import SwiftUI

struct SendMoneyFlow: View {
    @StateObject private var viewModel = TransactionViewModel()
    @State private var step: Int = 1
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                flowHeader
                
                ProgressStepBar(currentStep: step, totalSteps: 4)
                    .padding(.vertical, DesignSystem.Spacing.md)
                
                ZStack {
                    Group {
                        switch step {
                        case 1:
                            RecipientStep(recipient: $viewModel.recipient, onNext: { withAnimation { step = 2 } })
                        case 2:
                            SourceSelectionStep(selectedSource: $viewModel.selectedSource, onNext: { withAnimation { step = 3 } })
                        case 3:
                            AmountStep(amount: $viewModel.amount, onNext: { withAnimation { step = 4 } })
                        case 4:
                            ConfirmStep(viewModel: viewModel)
                        default:
                            EmptyView()
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                          removal: .move(edge: .leading).combined(with: .opacity)))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private var flowHeader: some View {
        HStack {
            Button(action: {
                if step > 1 { withAnimation { step -= 1 } }
                else { presentationMode.wrappedValue.dismiss() }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            }
            Spacer()
            Text("SEND FUNDS")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            Spacer()
            Button("CLOSE") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(DesignSystem.Typography.caption)
            .bold()
            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
        }
        .padding()
    }
}

struct ProgressStepBar: View {
    let currentStep: Int
    let totalSteps: Int
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? DesignSystem.Colors.textPrimary(scheme) : DesignSystem.Colors.textPrimary(scheme).opacity(0.1))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
}

// MARK: - Flow Steps

struct RecipientStep: View {
    @Binding var recipient: String
    var onNext: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("SPECIFY RECIPIENT")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                TextField("IDENTIFIER (PHONE/EMAIL)", text: $recipient)
                    .font(DesignSystem.Typography.title2)
                    .padding()
                    .background(DesignSystem.Colors.surface(scheme))
                    .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Text("Funds will be available immediately after confirmation.")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
            
            Button("PROCEED", action: onNext)
                .buttonStyle(PrimaryButtonStyle(isEnabled: !recipient.isEmpty))
                .padding()
                .disabled(recipient.isEmpty)
        }
    }
}

struct SourceSelectionStep: View {
    @Binding var selectedSource: Institution?
    @StateObject private var dashVM = DashboardViewModel()
    var onNext: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("CHOOSE FUNDING SOURCE")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            if dashVM.isLoading {
                Spacer()
                ProgressView().tint(DesignSystem.Colors.textPrimary(scheme)).frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(dashVM.institutions) { inst in
                            Button(action: {
                                withAnimation {
                                    selectedSource = inst
                                    onNext()
                                }
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: inst.iconSymbol)
                                        .font(.system(size: 20))
                                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                                        .frame(width: 44, height: 44)
                                        .background(DesignSystem.Colors.background(scheme))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(inst.name.uppercased())
                                            .font(DesignSystem.Typography.footnote).bold()
                                        Text("\(Int(inst.balance)) RWF AVAILABLE")
                                            .font(DesignSystem.Typography.caption)
                                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                    }
                                    Spacer()
                                    if selectedSource?.id == inst.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                                    }
                                }
                                .padding()
                                .background(DesignSystem.Colors.surface(scheme))
                                .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
            }
            Spacer()
        }
        .onAppear { Task { await dashVM.refreshData() } }
    }
}

struct AmountStep: View {
    @Binding var amount: Double
    @State private var amountStr = ""
    var onNext: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: 12) {
                Text("ENTER AMOUNT")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    TextField("0", text: $amountStr)
                        .font(DesignSystem.Typography.balance)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .fixedSize()
                        .onChange(of: amountStr) { val in
                            amount = Double(val) ?? 0
                        }
                    
                    Text("RWF")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                }
            }
            .padding(.top, DesignSystem.Spacing.xl)
            
            Spacer()
            
            Button("REVIEW TRANSACTION", action: onNext)
                .buttonStyle(PrimaryButtonStyle(isEnabled: amount > 0))
                .padding()
                .disabled(amount <= 0)
        }
    }
}

struct ConfirmStep: View {
    @ObservedObject var viewModel: TransactionViewModel
    @State private var isDone = false
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            if isDone {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    
                    Text("PAYMENT SUCCESSFUL")
                        .font(DesignSystem.Typography.title)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 4) {
                        Text("RECIPIENT")
                            .font(DesignSystem.Typography.caption)
                        Text(viewModel.recipient.uppercased())
                            .font(DesignSystem.Typography.headline)
                    }
                    
                    Text("\(Int(viewModel.amount)) RWF")
                        .font(DesignSystem.Typography.balanceSmall)
                    
                    Spacer()
                    
                    Button("FINISHED", action: { presentationMode.wrappedValue.dismiss() })
                        .buttonStyle(PrimaryButtonStyle())
                        .padding()
                }
                .padding(.top, DesignSystem.Spacing.xl)
                .transition(.scale.combined(with: .opacity))
            } else {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    Text("REVIEW DETAILS")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    VStack(spacing: 1) {
                        ConfirmRow(label: "RECIPIENT", value: viewModel.recipient.uppercased())
                        ConfirmRow(label: "FUNDING SOURCE", value: viewModel.selectedSource?.name.uppercased() ?? "")
                        ConfirmRow(label: "AMOUNT", value: "\(Int(viewModel.amount)) RWF")
                        ConfirmRow(label: "FEE", value: "0 RWF")
                    }
                    .background(DesignSystem.Colors.surface(scheme))
                    .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                        .padding()
                        .background(DesignSystem.Colors.softBeige.opacity(0.3))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        if await viewModel.sendMoney() {
                            withAnimation(.spring()) { isDone = true }
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView().tint(DesignSystem.Colors.background(scheme))
                    } else {
                        Text("AUTHORIZE PAYMENT")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            }
        }
    }
}

struct ConfirmRow: View {
    let label: String
    let value: String
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack {
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            Spacer()
            Text(value)
                .font(DesignSystem.Typography.subheadline)
                .bold()
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
        }
        .padding()
    }
}
