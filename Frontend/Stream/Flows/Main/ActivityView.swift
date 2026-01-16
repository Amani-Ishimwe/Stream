import SwiftUI
import Combine

struct ActivityView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                filterSection
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(DesignSystem.Colors.textPrimary(scheme))
                    Spacer()
                } else if viewModel.filteredTransactions.isEmpty {
                    emptyState
                } else {
                    ledgerList
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchData() }
        }
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        HStack {
            Text("ACTIVITY LEDGER")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            Spacer()
            // High density sync indicator
            HStack(spacing: 4) {
                Circle().fill(DesignSystem.Colors.textPrimary(scheme)).frame(width: 4, height: 4)
                Text("REAL-TIME")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FilterPill(title: "ALL", isSelected: viewModel.selectedType == nil) {
                    viewModel.selectedType = nil
                }
                FilterPill(title: "SENT", isSelected: viewModel.selectedType == "SENT") {
                    viewModel.selectedType = "SENT"
                }
                FilterPill(title: "RECEIVED", isSelected: viewModel.selectedType == "RECEIVED") {
                    viewModel.selectedType = "RECEIVED"
                }
                
                Divider().frame(height: 20).background(DesignSystem.Colors.textPrimary(scheme).opacity(0.2))
                
                ForEach(viewModel.institutions) { inst in
                    FilterPill(title: inst.name.uppercased(), isSelected: viewModel.selectedInstitutionID == inst.id) {
                        viewModel.selectedInstitutionID = viewModel.selectedInstitutionID == inst.id ? nil : inst.id
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .padding(.bottom, DesignSystem.Spacing.md)
    }
    
    private var ledgerList: some View {
        List {
            ForEach(viewModel.groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(viewModel.formatHeaderDate(date))
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    .padding(.vertical, 8)
                ) {
                    ForEach(viewModel.groupedTransactions[date] ?? []) { tx in
                        NavigationLink(destination: TransactionDetailView(transaction: tx)) {
                            ActivityLedgerRow(tx: tx)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: DesignSystem.Spacing.lg, bottom: 0, trailing: DesignSystem.Spacing.lg))
                        .listRowSeparator(.visible, edges: .bottom)
                        .listRowSeparatorTint(DesignSystem.Colors.textPrimary(scheme).opacity(0.1))
                        .listRowBackground(Color.clear)
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private var emptyState: some View {
        Spacer()
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "archivebox")
                .font(.system(size: 40))
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme).opacity(0.3))
            Text("NO RECORDS FOUND")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
        }
        Spacer()
    }
}

// MARK: - View Model

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var filteredTransactions: [Transaction] = []
    @Published var institutions: [Institution] = []
    @Published var isLoading = false
    
    @Published var selectedType: String? = nil { didSet { applyFilters() } }
    @Published var selectedInstitutionID: UUID? = nil { didSet { applyFilters() } }
    
    private var allTransactions: [Transaction] = []
    private let api = APIService.shared
    
    var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { tx in
            Calendar.current.startOfDay(for: tx.createdAt)
        }
    }
    
    func fetchData() async {
        isLoading = true
        do {
            async let txs = api.fetchTransactions()
            async let insts = api.fetchInstitutions()
            
            let (txResponse, instResponse) = try await (txs, insts)
            
            if txResponse.success, let data = txResponse.data {
                self.allTransactions = data
                applyFilters()
            }
            
            if instResponse.success, let data = instResponse.data {
                self.institutions = data
            }
        } catch {
            print("Activity fetch failed: \(error)")
        }
        isLoading = false
    }
    
    private func applyFilters() {
        filteredTransactions = allTransactions.filter { tx in
            let typeMatch = selectedType == nil || (selectedType == "SENT" ? tx.amount < 0 : tx.amount >= 0)
            let instMatch = selectedInstitutionID == nil || tx.sourceInstitutionID == selectedInstitutionID || tx.destinationInstitutionID == selectedInstitutionID
            return typeMatch && instMatch
        }
    }
    
    func formatHeaderDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "TODAY" }
        if Calendar.current.isDateInYesterday(date) { return "YESTERDAY" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: date).uppercased()
    }
}

// MARK: - Subviews

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.caption)
                .bold()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? DesignSystem.Colors.textPrimary(scheme) : DesignSystem.Colors.surface(scheme))
                .foregroundColor(isSelected ? DesignSystem.Colors.background(scheme) : DesignSystem.Colors.textPrimary(scheme))
                .cornerRadius(20)
        }
    }
}

struct ActivityLedgerRow: View {
    let tx: Transaction
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // High density icon indicator
            Image(systemName: tx.amount >= 0 ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .opacity(0.8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text((tx.counterparty ?? "UNKNOWN").uppercased())
                    .font(DesignSystem.Typography.footnote)
                    .bold()
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                HStack(spacing: 4) {
                    Text(tx.createdAt, style: .time)
                    Text("•")
                    Text(tx.status.uppercased())
                }
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(tx.formattedAmount)
                    .font(DesignSystem.Typography.subheadline)
                    .bold()
                    .monospacedDigit()
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Text(tx.type.uppercased())
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
        }
        .padding(.vertical, DesignSystem.Spacing.md)
    }
}
