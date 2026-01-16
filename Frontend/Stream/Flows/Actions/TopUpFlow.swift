import SwiftUI

struct TopUpFlow: View {
    var preSelectedSource: Institution? = nil
    @StateObject private var viewModel = TransactionViewModel()
    @State private var step: Int = 1
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ZStack {
                    switch step {
                    case 1:
                        TopUpSourceStep(viewModel: viewModel, onNext: { 
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if let source = preSelectedSource {
                viewModel.selectedSource = source
                // We'll skip to step 2 if source is pre-selected
                step = 2
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            }
            Spacer()
            Text("CAPITAL INFUSION")
                .font(DesignSystem.Typography.headline)
                .tracking(2)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            Spacer()
            Button(action: {}) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 16))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            }
        }
        .padding()
        .background(DesignSystem.Colors.surface(scheme))
    }
}

struct TopUpSourceStep: View {
    @ObservedObject var viewModel: TransactionViewModel
    @StateObject private var dashVM = DashboardViewModel()
    @Environment(\.colorScheme) var scheme
    var onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            Text("SELECT SOURCE ASSET")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 1) {
                    ForEach(dashVM.institutions) { inst in
                        Button(action: {
                            viewModel.selectedSource = inst
                            viewModel.selectedDestination = dashVM.institutions.first(where: { $0.id != inst.id })
                            onNext()
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "building.columns.base")
                                    .font(.system(size: 18))
                                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(inst.name.uppercased())
                                        .font(DesignSystem.Typography.footnote)
                                        .bold()
                                    Text("AVAIL: \(Int(inst.balance)) RWF")
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
        .onAppear { Task { await dashVM.refreshData() } }
    }
}

struct TopUpAmountStep: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.colorScheme) var scheme
    @State private var input = ""
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl * 2) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("SPECIFY AMOUNT")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("RWF")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    
                    TextField("0", text: $input)
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                        .onChange(of: input) { viewModel.amount = Double($0) ?? 0 }
                }
            }
            .padding(.top, 40)
            
            VStack(spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Text("FROM")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    Spacer()
                    Text(viewModel.selectedSource?.name.uppercased() ?? "SOURCE")
                        .font(DesignSystem.Typography.footnote)
                        .bold()
                }
                .padding()
                .background(DesignSystem.Colors.surface(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                
                Button(action: onNext) {
                    Text("VALIDATE AMOUNT")
                        .font(DesignSystem.Typography.callout)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(DesignSystem.Colors.textPrimary(scheme))
                        .foregroundColor(DesignSystem.Colors.background(scheme))
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
        }
    }
}

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
                Text("REVIEW TRANSACTION")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                Text("\(Int(viewModel.amount)) RWF")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            }
            
            VStack(spacing: 1) {
                SummaryRow(label: "ORIGIN", value: viewModel.selectedSource?.name.uppercased() ?? "")
                SummaryRow(label: "DESTINATION", value: viewModel.selectedDestination?.name.uppercased() ?? "")
                SummaryRow(label: "FEE", value: "0 RWF")
            }
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
            
            Button(action: executeTopUp) {
                HStack {
                    if status == .loading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.background(scheme)))
                    } else {
                        Text("EXECUTE TRANSFER")
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
        }
    }
    
    private var successView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            Text("INFUSION COMPLETE")
                .font(DesignSystem.Typography.title)
                .bold()
            
            Text("Asset successfully transferred to your main account.")
                .font(DesignSystem.Typography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            Button("RETURN TO DASHBOARD", action: onDone)
                .buttonStyle(.primary)
                .padding(.top, 20)
        }
    }
    
    private var failureView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 80))
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            Text("INFUSION FAILED")
                .font(DesignSystem.Typography.title)
                .bold()
            
            Text("We could not process this capital infusion. Please check your source balance.")
                .font(DesignSystem.Typography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            Button("RETRY", action: { status = .idle })
                .buttonStyle(.primary)
                .padding(.top, 20)
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
