import SwiftUI

struct RequestMoneyFlow: View {
    var preSelectedDestination: Institution? = nil
    @StateObject private var viewModel = TransactionViewModel()
    @State private var qrCodeGenerated = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                flowHeader
                
                if qrCodeGenerated {
                    qrStep
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                              removal: .move(edge: .leading).combined(with: .opacity)))
                } else {
                    inputStep
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                              removal: .move(edge: .leading).combined(with: .opacity)))
                }
            }
        }
        .onAppear {
            if let dest = preSelectedDestination {
                viewModel.selectedDestination = dest
            }
        }
    }
    
    private var flowHeader: some View {
        HStack {
            Button("CLOSE") { presentationMode.wrappedValue.dismiss() }
                .font(DesignSystem.Typography.caption)
                .bold()
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            Spacer()
            Text("REQUEST FUNDS")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            Spacer()
            Rectangle().frame(width: 40, height: 1).opacity(0) // Balance
        }
        .padding()
    }
    
    private var inputStep: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("AMOUNT")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    
                    TextField("0", value: $viewModel.amount, format: .number)
                        .font(DesignSystem.Typography.title)
                        .padding()
                        .background(DesignSystem.Colors.surface(scheme))
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("PAYER IDENTIFIER")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    
                    TextField("NAME OR PHONE", text: $viewModel.payer)
                        .font(DesignSystem.Typography.subheadline)
                        .padding()
                        .background(DesignSystem.Colors.surface(scheme))
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
            
            Button("GENERATE PAYMENT LINK") {
                withAnimation(.spring()) { qrCodeGenerated = true }
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.amount > 0 && !viewModel.payer.isEmpty))
            .padding()
            .disabled(viewModel.amount <= 0 || viewModel.payer.isEmpty)
        }
    }
    
    private var qrStep: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("SHARE PAYMENT QR")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                VStack(spacing: DesignSystem.Spacing.lg) {
                    QRCodeView(data: "stream://request?amount=\(viewModel.amount)&payer=\(viewModel.payer)")
                        .frame(width: 200, height: 200)
                        .padding(DesignSystem.Spacing.lg)
                        .background(Color.white)
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                        .shadow(color: DesignSystem.Colors.textPrimary(scheme).opacity(0.1), radius: 20)
                    
                    VStack(spacing: 4) {
                        Text("\(Int(viewModel.amount)) RWF")
                            .font(DesignSystem.Typography.balanceSmall)
                        Text("REQUESTING FROM \(viewModel.payer.uppercased())")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    }
                }
            }
            .padding(.top, DesignSystem.Spacing.xl)
            
            Spacer()
            
            Button("SAVE AS IMAGE") {
                // Save logic
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
        }
    }
}
