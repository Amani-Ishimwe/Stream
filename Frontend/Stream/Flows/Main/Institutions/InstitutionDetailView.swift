import SwiftUI
import Combine

struct InstitutionDetailView: View {
    let institution: Institution
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = InstitutionDetailViewModel()
    
    @State private var showSend = false
    @State private var showRequest = false
    @State private var showTopUp = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        balanceCard
                        
                        limitsSection
                        
                        quickActions
                        
                        historySection
                    }
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchTransactions(for: institution.id) }
        }
        .sheet(isPresented: $showSend) {
            SendMoneyFlow(preSelectedSource: institution)
        }
        .sheet(isPresented: $showTopUp) {
            TopUpFlow(preSelectedSource: institution)
        }
        .sheet(isPresented: $showRequest) {
            RequestMoneyFlow(preSelectedDestination: institution)
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            }
            Spacer()
            Text(institution.name.uppercased())
                .font(DesignSystem.Typography.headline)
                .tracking(2)
            Spacer()
            Image(systemName: institution.iconSymbol)
                .font(.headline)
        }
        .padding()
        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
    }
    
    private var balanceCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            VStack(spacing: 4) {
                Text("CURRENT BALANCE")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                Text("\(Int(institution.balance))")
                    .font(DesignSystem.Typography.balanceSmall)
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Text(institution.accountNumber ?? "NO ACCOUNT NUMBER")
                    .font(DesignSystem.Typography.footnote)
                    .monospacedDigit()
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
            
            HStack {
                StatusPill(title: institution.isFrozen ? "FROZEN" : "ACTIVE", 
                          isActive: !institution.isFrozen)
                Spacer()
                Text("Last Synced: \(institution.lastSynced?.formatted(date: .omitted, time: .shortened) ?? "Now")")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var limitsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("INSTITUTIONAL LIMITS")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            VStack(spacing: 1) {
                LimitRow(label: "DAILY SPENDING", value: "\(Int(institution.dailyLimit)) RWF")
                LimitRow(label: "MONTHLY VOLUME", value: "\(Int(institution.monthlyLimit)) RWF")
            }
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var quickActions: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ActionIconBtn(title: "SEND", icon: "arrow.up.right") { showSend = true }
            ActionIconBtn(title: "REQUEST", icon: "arrow.down.left") { showRequest = true }
            ActionIconBtn(title: "TOP UP", icon: "plus") { showTopUp = true }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("RECENT HISTORY")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            if viewModel.isLoading {
                ProgressView().tint(DesignSystem.Colors.textPrimary(scheme)).frame(maxWidth: .infinity)
            } else if viewModel.transactions.isEmpty {
                Text("NO ACTIVITY RECORDED")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 1) {
                    ForEach(viewModel.transactions) { tx in
                        NavigationLink(destination: TransactionDetailView(transaction: tx)) {
                            ActivityRow(tx: tx)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(DesignSystem.Colors.surface(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
}

class InstitutionDetailViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    
    func fetchTransactions(for id: UUID) async {
        isLoading = true
        do {
            let response = try await APIService.shared.fetchInstitutionTransactions(id: id)
            if response.success, let data = response.data {
                self.transactions = data
            }
        } catch {
            print("Failed to fetch inst transactions: \(error)")
        }
        isLoading = false
    }
}

struct LimitRow: View {
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
                .font(DesignSystem.Typography.footnote).bold()
                .monospacedDigit()
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
        }
        .padding()
    }
}

struct StatusPill: View {
    let title: String
    let isActive: Bool
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        Text(title)
            .font(DesignSystem.Typography.caption)
            .bold()
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isActive ? DesignSystem.Colors.textPrimary(scheme) : DesignSystem.Colors.textSecondary(scheme).opacity(0.3))
            .foregroundColor(isActive ? DesignSystem.Colors.background(scheme) : DesignSystem.Colors.textPrimary(scheme))
            .cornerRadius(20)
    }
}

struct ActionIconBtn: View {
    let title: String
    let icon: String
    let action: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(DesignSystem.Typography.caption).bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface(scheme))
            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
        }
    }
}
