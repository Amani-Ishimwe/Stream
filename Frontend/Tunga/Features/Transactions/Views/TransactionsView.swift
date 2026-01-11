import SwiftUI
import Charts

struct TransactionsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = "All"
    @State private var searchText = ""
    
    // Data Source
    let allTransactions = DemoDataManager.shared.transactions
    
    var filteredTransactions: [Transaction] {
        var transactions = allTransactions
        
        // Tab Filter
        if selectedTab == "Sent" {
            transactions = transactions.filter { !$0.isPositive }
        } else if selectedTab == "Received" {
            transactions = transactions.filter { $0.isPositive }
        }
        
        // Search Filter
        if !searchText.isEmpty {
            transactions = transactions.filter {
                $0.counterparty.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return transactions.sorted(by: { $0.date > $1.date }) // Newest first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                        TextField("Search transactions", text: $searchText)
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    }
                    .padding()
                    .background(DesignSystem.Colors.surface(colorScheme))
                    .cornerRadius(10)
                    .padding()
                    
                    // Custom Tabs
                    HStack {
                        ForEach(["All", "Sent", "Received"], id: \.self) { tab in
                            Button(action: {
                                withAnimation { selectedTab = tab }
                            }) {
                                Text(tab)
                                    .font(DesignSystem.Typography.headline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Capsule()
                                            .fill(selectedTab == tab ? DesignSystem.Colors.accent(colorScheme) : Color.clear)
                                    )
                                    .foregroundColor(selectedTab == tab ? DesignSystem.Colors.primary(colorScheme) : DesignSystem.Colors.textSecondary(colorScheme))
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    // List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTransactions) { transaction in
                                NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                                    TransactionRowItem(transaction: transaction)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Simple Detail View Placeholder
struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Receipt Style Card
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                    
                    Text(transaction.formattedAmount)
                        .font(DesignSystem.Typography.balance)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    
                    Text("Success")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    
                    Divider()
                    
                    DetailRow(label: "Date", value: transaction.date.formatted(date: .long, time: .shortened))
                    DetailRow(label: "Reference", value: transaction.id)
                    DetailRow(label: "To/From", value: transaction.counterparty)
                    DetailRow(label: "Note", value: transaction.description)
                }
                .padding(24)
                .background(DesignSystem.Colors.surface(colorScheme))
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle("Details")
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(label).foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
            Spacer()
            Text(value).fontWeight(.medium).foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
        }
    }
}
