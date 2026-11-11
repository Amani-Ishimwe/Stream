import SwiftUI
import Photos

struct RequestMoneyFlow: View {
    var preSelectedDestination: Institution? = nil
    @StateObject private var viewModel = TransactionViewModel()
    @State private var qrCodeGenerated = false
    @State private var availableInstitutions: [Institution] = []
    @State private var amountText: String = ""
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
            Task {
                do {
                    let response = try await APIService.shared.fetchInstitutions()
                    if let list = response.data, !list.isEmpty {
                        self.availableInstitutions = list
                        if viewModel.selectedDestination == nil {
                            viewModel.selectedDestination = list.first
                        }
                    }
                } catch {
                    print("Failed to fetch accounts for request: \(error)")
                }
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
            Text("REQUEST MONEY")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            Spacer()
            Rectangle().frame(width: 40, height: 1).opacity(0) // Balance
        }
        .padding()
    }
    
    private var inputStep: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            if let err = viewModel.errorMessage {
                FriendlyErrorBanner(message: err)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                // Account selector
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("RECEIVE INTO ACCOUNT")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    
                    if availableInstitutions.isEmpty {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading accounts...")
                                .font(DesignSystem.Typography.footnote)
                                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DesignSystem.Colors.surface(scheme))
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                    } else {
                        Menu {
                            ForEach(availableInstitutions) { inst in
                                Button(action: {
                                    viewModel.selectedDestination = inst
                                }) {
                                    HStack {
                                        Text(inst.name)
                                        if viewModel.selectedDestination?.id == inst.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: viewModel.selectedDestination?.iconSymbol ?? "building.columns.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                                    .frame(width: 36, height: 36)
                                    .background(DesignSystem.Colors.background(scheme))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(viewModel.selectedDestination?.name ?? "Select Account")
                                        .font(DesignSystem.Typography.headline)
                                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                                    
                                    if let balance = viewModel.selectedDestination?.balance {
                                        Text("Balance: \(Int(balance)) RWF")
                                            .font(DesignSystem.Typography.caption)
                                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                            }
                            .padding()
                            .background(DesignSystem.Colors.surface(scheme))
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("AMOUNT")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    
                    TextField("0", text: $amountText)
                        .font(DesignSystem.Typography.title)
                        .padding()
                        .background(DesignSystem.Colors.surface(scheme))
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                        .keyboardType(.numberPad)
                        .onChange(of: amountText) { _, newValue in
                            let digits = newValue.filter { "0123456789".contains($0) }
                            if digits != newValue {
                                amountText = digits
                            }
                            viewModel.amount = Double(digits) ?? 0
                        }
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("PAYER OR NOTE (OPTIONAL)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    
                    TextField("e.g. Eric, Lunch, or leave blank", text: $viewModel.payer)
                        .font(DesignSystem.Typography.subheadline)
                        .padding()
                        .background(DesignSystem.Colors.surface(scheme))
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            
            Spacer()
            
            Button("Create Payment QR Code") {
                Task {
                    await viewModel.generateQR(type: .request)
                    if viewModel.qrPayload != nil {
                        withAnimation(.spring()) { qrCodeGenerated = true }
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.amount > 0))
            .padding()
            .disabled(viewModel.amount <= 0)
        }
    }
    
    private var qrStep: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("SHARE PAYMENT QR")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                VStack(spacing: DesignSystem.Spacing.lg) {
                    if let payload = viewModel.qrPayload,
                       let jsonData = try? QRPayload.qrEncoder.encode(payload),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        QRCodeView(data: jsonString)
                            .frame(width: 200, height: 200)
                            .padding(DesignSystem.Spacing.lg)
                            .background(Color.white)
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                            .shadow(color: DesignSystem.Colors.textPrimary(scheme).opacity(0.1), radius: 20)
                    } else {
                        ProgressView()
                            .frame(width: 200, height: 200)
                    }
                    
                    VStack(spacing: 6) {
                        Text("\(Int(viewModel.amount)) RWF")
                            .font(DesignSystem.Typography.balanceSmall)
                        
                        if let destName = viewModel.selectedDestination?.name {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                Text("Depositing to \(destName)")
                                    .font(DesignSystem.Typography.footnote)
                                    .bold()
                                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                            }
                        }
                        
                        if !viewModel.payer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("REQUESTING FROM \(viewModel.payer.uppercased())")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        } else {
                            Text("SCAN TO PAY")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        }
                    }
                }
            }
            .padding(.top, DesignSystem.Spacing.xl)
            
            Spacer()
            
            Button("SAVE AS IMAGE") {
                saveQRToPhotos()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
        }
    }
    
    private func saveQRToPhotos() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let payload = viewModel.qrPayload,
              let jsonData = try? encoder.encode(payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        
        let payerNote = viewModel.payer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Payment Request" : "From: \(viewModel.payer)"
        
        let qrView = VStack(spacing: 16) {
            Text("STREAM PAYMENT REQUEST")
                .font(.headline)
            QRCodeView(data: jsonString)
                .frame(width: 200, height: 200)
                .padding()
                .background(Color.white)
            Text("\(Int(viewModel.amount)) RWF")
                .font(.title3)
                .bold()
            Text(payerNote)
                .font(.subheadline)
        }
        .padding(40)
        .background(Color.white)
        
        let renderer = ImageRenderer(content: qrView)
        renderer.scale = UIScreen.main.scale
        
        if let uiImage = renderer.uiImage {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                if status == .authorized || status == .limited {
                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                    print("Request QR Saved to Photos")
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
