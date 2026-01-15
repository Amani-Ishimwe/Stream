import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var scheme
    
    @State private var isBalanceExpanded = false
    @State private var showSendFlow = false
    @State private var showRequestFlow = false
    @State private var showTopUpFlow = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    headerSection
                    
                    balanceSection
                    
                    quickActionsSection
                    
                    institutionSection
                    
                    recentActivitySection
                    
                    Spacer(minLength: 100)
                }
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
        .onAppear {
            Task { await viewModel.refreshData() }
        }
        .sheet(isPresented: $showSendFlow) { SendMoneyFlow() }
        .sheet(isPresented: $showRequestFlow) { RequestMoneyFlow() }
        .sheet(isPresented: $showTopUpFlow) { TopUpFlow() }
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.tny) {
                Text(appState.currentUser?.name.uppercased() ?? "STREAM USER")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(DesignSystem.Colors.textPrimary(scheme))
                        .frame(width: 8, height: 8)
                    Text("ACTIVE")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    
                    Text("•  SYNCED \(viewModel.lastSync, style: .time)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                }
            }
            Spacer()
            
            Button(action: { Task { await viewModel.refreshData() } }) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    .padding(DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.surface(scheme))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.md)
    }
    
    private var balanceSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            VStack(spacing: 4) {
                Text("TOTAL NET WORTH")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                Text("\(Int(viewModel.totalBalance))")
                    .font(DesignSystem.Typography.balance)
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Text("RWF")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadiusCard)
                    .fill(DesignSystem.Colors.surface(scheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadiusCard)
                            .stroke(DesignSystem.Colors.textPrimary(scheme).opacity(0.1), lineWidth: 1)
                    )
            )
            .onTapGesture {
                withAnimation(.spring()) { isBalanceExpanded.toggle() }
            }
            
            if isBalanceExpanded {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(viewModel.institutions) { inst in
                        HStack {
                            Text(inst.name)
                                .font(DesignSystem.Typography.footnote)
                            Spacer()
                            Text("\(Int(inst.balance)) RWF")
                                .font(DesignSystem.Typography.footnote)
                                .bold()
                        }
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    }
                }
                .padding()
                .background(DesignSystem.Colors.surface(scheme).opacity(0.5))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Change Indicator
            HStack(spacing: 4) {
                Image(systemName: viewModel.lastTransactionChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text("\(abs(Int(viewModel.lastTransactionChange))) RWF")
                Text("since last activity")
                    .opacity(0.7)
            }
            .font(DesignSystem.Typography.caption)
            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, 6)
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(20)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var quickActionsSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            QuickActionBtn(title: "SEND", icon: "arrow.up.right", action: { showSendFlow = true })
            QuickActionBtn(title: "REQUEST", icon: "arrow.down.left", action: { showRequestFlow = true })
            QuickActionBtn(title: "SCAN", icon: "qrcode.viewfinder", action: { /* Scan Action */ })
            QuickActionBtn(title: "TOP UP", icon: "plus.circle", action: { showTopUpFlow = true })
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var institutionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("INSTITUTIONS")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                .padding(.horizontal, DesignSystem.Spacing.lg)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                if viewModel.isLoading {
                    ProgressView().tint(DesignSystem.Colors.textPrimary(scheme))
                } else {
                    ForEach(viewModel.institutions) { inst in
                        InstitutionRow(institution: inst)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("RECENT ACTIVITY")
                    .font(DesignSystem.Typography.caption)
                Spacer()
                Text("VIEW ALL")
                    .font(DesignSystem.Typography.caption)
                    .bold()
            }
            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            VStack(spacing: 1) {
                ForEach(viewModel.recentTransactions) { tx in
                    ActivityRow(tx: tx)
                }
            }
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Subviews

struct QuickActionBtn: View {
    let title: String
    let icon: String
    let action: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(DesignSystem.Typography.caption)
                    .bold()
            }
            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
        }
    }
}

struct InstitutionRow: View {
    let institution: Institution
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: institution.iconSymbol)
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .frame(width: 44, height: 44)
                .background(DesignSystem.Colors.background(scheme))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(institution.name.uppercased())
                    .font(DesignSystem.Typography.footnote)
                    .bold()
                Text(institution.type)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(institution.balance))")
                    .font(DesignSystem.Typography.headline)
                    .monospacedDigit()
                Text(institution.isFrozen ? "FROZEN" : "ACTIVE")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(institution.isFrozen ? DesignSystem.Colors.textPrimary(scheme).opacity(0.5) : DesignSystem.Colors.textPrimary(scheme))
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface(scheme))
        .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
    }
}

struct ActivityRow: View {
    let tx: Transaction
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tx.counterparty.uppercased())
                    .font(DesignSystem.Typography.footnote)
                    .bold()
                Text(tx.createdAt, style: .time)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            Spacer()
            Text(tx.formattedAmount)
                .font(DesignSystem.Typography.subheadline)
                .bold()
                .monospacedDigit()
        }
        .padding(DesignSystem.Spacing.md)
        .contentShape(Rectangle())
    }
}
