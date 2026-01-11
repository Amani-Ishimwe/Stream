import SwiftUI

struct BankAccountsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var linkedAccounts: [MockBankAccount] = MockData.bankAccounts
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: AddBankAccountView()) {
                    Label("Link New Account", systemImage: "plus.circle.fill")
                        .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                }
            }
            
            Section("Linked Accounts") {
                ForEach(linkedAccounts) { account in
                    HStack {
                        Image(systemName: account.icon)
                            .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(account.bankName)
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                            Text(account.accountNumber)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                        }
                        Spacer()
                        if account.bankName == "Chase Bank" {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DesignSystem.Colors.success(colorScheme))
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteAccount)
            }
            
            Section {
                 // Withdraw / Top Up
                 Button("Include Top-Up Flow") { }
                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
            }
        }
        .navigationTitle("Bank Accounts")
        .background(DesignSystem.Colors.background(colorScheme))
    }
    
    func deleteAccount(at offsets: IndexSet) {
        linkedAccounts.remove(atOffsets: offsets)
    }
}

struct AddBankAccountView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section("Bank Details") {
                TextField("Bank Name", text: .constant(""))
                TextField("Account Number", text: .constant(""))
            }
            Button("Link Account") {
                dismiss()
            }
        }
        .navigationTitle("Add Bank")
    }
}
