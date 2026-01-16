import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        statusSection
                        
                        detailSection
                        
                        if let metadata = transaction.metadata, !metadata.isEmpty {
                            metadataSection(metadata)
                        }
                        
                        actionsSection
                    }
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
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
            Text("TRANSACTION DETAIL")
                .font(DesignSystem.Typography.headline)
                .tracking(2)
            Spacer()
            Image(systemName: "square.and.arrow.up")
                .font(.headline)
        }
        .padding()
        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
    }
    
    private var statusSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: statusIcon)
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .padding()
                .background(DesignSystem.Colors.surface(scheme))
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(transaction.type == "SEND" ? "TRANSFER TO" : "PAYMENT FROM")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                Text(transaction.counterparty ?? "UNKNOWN")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            }
            
            Text(transaction.formattedAmount)
                .font(DesignSystem.Typography.balanceSmall)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            StatusPill(title: transaction.status.uppercased(), isActive: transaction.status == "Completed")
        }
        .padding(.vertical, DesignSystem.Spacing.xl)
    }
    
    private var detailSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("TRANSACTION DETAILS")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            VStack(spacing: 1) {
                DetailRow(label: "TRANSACTION ID", value: transaction.id.uuidString.prefix(12).uppercased())
                DetailRow(label: "COMPLETED AT", value: transaction.createdAt.formatted(date: .abbreviated, time: .shortened))
                DetailRow(label: "DESCRIPTION", value: transaction.description ?? "N/A")
                DetailRow(label: "TYPE", value: transaction.type)
            }
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private func metadataSection(_ metadata: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("ADDITIONAL INFO")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            VStack(spacing: 1) {
                ForEach(Array(metadata.keys).sorted(), id: \.self) { key in
                    DetailRow(label: key.uppercased(), value: metadata[key] ?? "")
                }
            }
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var actionsSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Button(action: { /* Download Receipt */ }) {
                HStack {
                    Image(systemName: "doc.plaintext")
                    Text("RECEIPT")
                }
                .font(DesignSystem.Typography.caption).bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.surface(scheme))
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
            }
            
            Button(action: { /* Report Issue */ }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("REPORT")
                }
                .font(DesignSystem.Typography.caption).bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.surface(scheme))
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var statusIcon: String {
        switch transaction.type {
        case "SEND": return "arrow.up.right.circle.fill"
        case "RECEIVE": return "arrow.down.left.circle.fill"
        case "TOPUP": return "plus.circle.fill"
        default: return "circle.fill"
        }
    }
}

struct DetailRow: View {
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
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }
}
