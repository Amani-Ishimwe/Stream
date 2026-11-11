import SwiftUI

struct TopUpFlow: View {
    var preSelectedSource: Institution? = nil
    var preSelectedDestination: Institution? = nil
    
    @StateObject private var viewModel = TransactionViewModel()
    @State private var step: Int = 1
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    
    private var isDestinationFixed: Bool {
        preSelectedDestination != nil
    }
    
    private var totalSteps: Int {
        isDestinationFixed ? 3 : 4
    }
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                // Progress bar
                ProgressStepBar(currentStep: step, totalSteps: totalSteps)
                    .padding(.vertical, DesignSystem.Spacing.md)
                
                ZStack {
                    if isDestinationFixed {
                        // 3-step flow when destination is already chosen (e.g. from account details)
                        switch step {
                        case 1:
                            TopUpSourceStep(viewModel: viewModel, destinationToExclude: viewModel.selectedDestination, onNext: {
                                withAnimation(.spring()) { step = 2 }
                            })
                        case 2:
                            TopUpAmountStep(viewModel: viewModel, onNext: {
                                withAnimation(.spring()) { step = 3 }
                            })
                        case 3:
                            TopUpConfirmStep(viewModel: viewModel, onDone: {
                                presentationMode.wrappedValue.dismiss()
                            })
                        default:
                            EmptyView()
                        }
                    } else {
                        // 4-step flow when launched from quick actions (select source -> select dest -> amount -> confirm)
                        switch step {
                        case 1:
                            TopUpSourceStep(viewModel: viewModel, destinationToExclude: nil, onNext: {
                                withAnimation(.spring()) { step = 2 }
                            })
                        case 2:
                            TopUpDestinationStep(viewModel: viewModel, onNext: {
                                withAnimation(.spring()) { step = 3 }
                            })
                        case 3:
                            TopUpAmountStep(viewModel: viewModel, onNext: {
                                withAnimation(.spring()) { step = 4 }
                            })
                        case 4:
                            TopUpConfirmStep(viewModel: viewModel, onDone: {
                                presentationMode.wrappedValue.dismiss()
                            })
                        default:
                            EmptyView()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if let dest = preSelectedDestination {
                viewModel.selectedDestination = dest
            }
            if let src = preSelectedSource {
                viewModel.selectedSource = src
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: {
                if step > 1 {
                    withAnimation { step -= 1 }
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                if step > 1 {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                } else {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                }
            }
            Spacer()
            Text("ADD MONEY")
                .font(DesignSystem.Typography.headline)
                .tracking(2)
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
        .background(DesignSystem.Colors.surface(scheme))
    }
}

// MARK: - Step 1: Choose Source
struct TopUpSourceStep: View {
    @ObservedObject var viewModel: TransactionViewModel
    var destinationToExclude: Institution? = nil
    @StateObject private var dashVM = DashboardViewModel()
    @Environment(\.colorScheme) var scheme
    var onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TRANSFER FROM")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                Text("Select the account you want to take money from")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.lg)
            
            if dashVM.isLoading {
                Spacer()
                ProgressView().tint(DesignSystem.Colors.textPrimary(scheme)).frame(maxWidth: .infinity)
                Spacer()
            } else {
                let availableSources = dashVM.institutions.filter { $0.id != destinationToExclude?.id }
                
                if availableSources.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "creditcard.trianglebadge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        Text("No other accounts available to transfer from.")
                            .font(DesignSystem.Typography.footnote)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(availableSources) { inst in
                                Button(action: {
                                    viewModel.selectedSource = inst
                                    onNext()
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
                                                .font(DesignSystem.Typography.footnote)
                                                .bold()
                                                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                                            Text("Available: \(Int(inst.balance ?? 0)) RWF")
                                                .font(DesignSystem.Typography.caption)
                                                .monospacedDigit()
                                                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                    }
                                    .padding()
                                    .background(DesignSystem.Colors.surface(scheme))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                }
            }
        }
        .onAppear { Task { await dashVM.refreshData() } }
    }
}

// MARK: - Step 2: Choose Destination (Quick Actions)
struct TopUpDestinationStep: View {
    @ObservedObject var viewModel: TransactionViewModel
    @StateObject private var dashVM = DashboardViewModel()
    @Environment(\.colorScheme) var scheme
    var onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DEPOSIT INTO")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                Text("Select which account should receive the money")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.lg)
            
            if dashVM.isLoading {
                Spacer()
                ProgressView().tint(DesignSystem.Colors.textPrimary(scheme)).frame(maxWidth: .infinity)
                Spacer()
            } else {
                let availableDestinations = dashVM.institutions.filter { $0.id != viewModel.selectedSource?.id }
                
                if availableDestinations.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "building.columns")
                            .font(.system(size: 40))
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        Text("No other destination accounts found.")
                            .font(DesignSystem.Typography.footnote)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 1) {
                            ForEach(availableDestinations) { inst in
                                Button(action: {
                                    viewModel.selectedDestination = inst
                                    onNext()
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
                                                .font(DesignSystem.Typography.footnote)
                                                .bold()
                                                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                                            Text("Current balance: \(Int(inst.balance ?? 0)) RWF")
                                                .font(DesignSystem.Typography.caption)
                                                .monospacedDigit()
                                                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                    }
                                    .padding()
                                    .background(DesignSystem.Colors.surface(scheme))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                    }
                }
            }
        }
        .onAppear { Task { await dashVM.refreshData() } }
    }
}

// MARK: - Step 3: Specify Amount
struct TopUpAmountStep: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.colorScheme) var scheme
    @State private var input = ""
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("ENTER AMOUNT")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("RWF")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    
                    TextField("0", text: $input)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                        .onChange(of: input) { _, newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                input = filtered
                            }
                            viewModel.amount = Double(filtered) ?? 0
                        }
                }
            }
            .padding(.top, 24)
            
            // Route Card showing From and To
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        Text("FROM")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    }
                    Spacer()
                    Text(viewModel.selectedSource?.name.uppercased() ?? "SOURCE")
                        .font(DesignSystem.Typography.footnote)
                        .bold()
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                }
                
                Divider()
                
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        Text("TO")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    }
                    Spacer()
                    Text(viewModel.selectedDestination?.name.uppercased() ?? "DESTINATION")
                        .font(DesignSystem.Typography.footnote)
                        .bold()
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                }
            }
            .padding()
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
            
            Button(action: onNext) {
                Text("CONTINUE")
                    .font(DesignSystem.Typography.callout)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.amount > 0 ? DesignSystem.Colors.textPrimary(scheme) : DesignSystem.Colors.textSecondary(scheme).opacity(0.3))
                    .foregroundColor(DesignSystem.Colors.background(scheme))
                    .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
            }
            .disabled(viewModel.amount <= 0)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Step 4: Confirm
struct TopUpConfirmStep: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.colorScheme) var scheme
    @State private var status: FlowStatus = .idle
    var onDone: () -> Void
    
    enum FlowStatus {
        case idle, loading, success, failure
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            if status == .success {
                successView
            } else if status == .failure {
                failureView
            } else {
                confirmView
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var confirmView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: 8) {
                Text("REVIEW TRANSFER")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                Text("\(Int(viewModel.amount)) RWF")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            }
            .padding(.top, 16)
            
            VStack(spacing: 1) {
                SummaryRow(label: "TRANSFER FROM", value: viewModel.selectedSource?.name.uppercased() ?? "")
                SummaryRow(label: "DEPOSIT TO", value: viewModel.selectedDestination?.name.uppercased() ?? "")
                SummaryRow(label: "FEE", value: "0 RWF (Free)")
            }
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
            
            Spacer()
            
            Button(action: executeTopUp) {
                HStack {
                    if status == .loading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.background(scheme)))
                    } else {
                        Text("CONFIRM TRANSFER")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(DesignSystem.Colors.textPrimary(scheme))
                .foregroundColor(DesignSystem.Colors.background(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
            }
            .disabled(status == .loading)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(DesignSystem.Colors.successGreen)
            
            Text("MONEY ADDED")
                .font(DesignSystem.Typography.title)
                .bold()
            
            Text("Successfully transferred \(Int(viewModel.amount)) RWF from \(viewModel.selectedSource?.name ?? "") to \(viewModel.selectedDestination?.name ?? "").")
                .font(DesignSystem.Typography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            Spacer()
            
            Button("DONE", action: onDone)
                .buttonStyle(.primary)
                .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
    
    private var failureView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 80))
                .foregroundColor(DesignSystem.Colors.errorRed)
            
            Text("COULD NOT ADD MONEY")
                .font(DesignSystem.Typography.title)
                .bold()
            
            Text(viewModel.errorMessage ?? "We could not add money. Please check your account balance and try again.")
                .font(DesignSystem.Typography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            Spacer()
            
            Button("TRY AGAIN", action: { status = .idle })
                .buttonStyle(.primary)
                .padding(.bottom, DesignSystem.Spacing.lg)
        }
    }
    
    private func executeTopUp() {
        status = .loading
        Task {
            let success = await viewModel.topUp()
            await MainActor.run {
                withAnimation {
                    status = success ? .success : .failure
                }
            }
        }
    }
}

struct SummaryRow: View {
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
                .font(DesignSystem.Typography.footnote)
                .bold()
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
        }
        .padding()
        .background(DesignSystem.Colors.surface(scheme))
    }
}
