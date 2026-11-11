import SwiftUI
import CoreImage.CIFilterBuiltins

struct CardsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var scheme
    @StateObject private var viewModel = DashboardViewModel()
    
    @State private var isFlipped = false
    @State private var degrees: Double = 0
    @State private var showingScanner = false
    @State private var activeQRPayload: QRPayload?
    @State private var qrPayload: QRPayload?
    @State private var showLimitEdit = false
    @State private var showRequestFlow = false
    @State private var dailyLimit: String = ""
    @State private var monthlyLimit: String = ""
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                headerSection
                
                // Smart Card Container
                VStack(spacing: DesignSystem.Spacing.lg) {
                    ZStack {
                        cardFront
                            .opacity(isFlipped ? 0 : 1)
                            .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
                        
                        cardBack
                            .opacity(isFlipped ? 1 : 0)
                            .rotation3DEffect(.degrees(degrees + 180), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(height: 220)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isFlipped.toggle()
                            degrees += 180
                        }
                    }
                    
                    Text(isFlipped ? "TAP TO VIEW DETAILS" : "TAP TO REVEAL PAYMENT QR")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                }
                .padding(.top, DesignSystem.Spacing.xl)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                // Card Actions
                VStack(spacing: DesignSystem.Spacing.md) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        CardActionBtn(title: viewModel.institutions.first?.isFrozen == true ? "UNFREEZE" : "FREEZE", 
                                     icon: viewModel.institutions.first?.isFrozen == true ? "sun.max.fill" : "snow", 
                                     isActive: true) {
                            if let first = viewModel.institutions.first {
                                Task { await toggleFreeze(id: first.id) }
                            }
                        }
                        CardActionBtn(title: "SCAN", icon: "qrcode.viewfinder", isActive: true) {
                            showingScanner = true
                        }
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.md) {
                        CardActionBtn(title: "LIMITS", icon: "slider.horizontal.3", isActive: true) {
                            showLimitEdit = true
                        }
                        CardActionBtn(title: "REQUEST", icon: "arrow.down.to.line.compact", isActive: true) {
                            showRequestFlow = true
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showingScanner) {
            QRScannerView { result in
                handleScanResult(result)
            }
        }
        .sheet(item: $activeQRPayload) { payload in
            QRPaymentFlow(payload: payload)
        }
        .sheet(isPresented: $showRequestFlow) {
            RequestMoneyFlow(preSelectedDestination: viewModel.institutions.first)
        }
        .sheet(isPresented: $showLimitEdit, onDismiss: {
            Task { await viewModel.refreshData() }
        }) {
            AccountLimitsView()
        }
        .alert("Invalid QR Code", isPresented: $showDecodeError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(decodeErrorMessage ?? "We could not read this QR code. Please scan a valid Stream payment QR code.")
        }
        .onAppear {
            Task { 
                await viewModel.refreshData() 
                await fetchSecureQR()
            }
        }
    }

    private func fetchSecureQR() async {
        do {
            // Default payment QR for the user's primary account
            if let firstInst = viewModel.institutions.first {
                let response = try await APIService.shared.generateQR(type: .send, amount: 0, destinationId: firstInst.id)
                self.qrPayload = response.data
            }
        } catch {
            print("Failed to fetch secure QR: \(error)")
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("MY CARD")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            Spacer()
            Circle()
                .fill(DesignSystem.Colors.textPrimary(scheme))
                .frame(width: 8, height: 8)
                .overlay(Text(" LIVE").font(DesignSystem.Typography.caption).offset(x: 25))
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.md)
    }
    
    private var cardFront: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("STREAM")
                    .font(DesignSystem.Typography.headline)
                    .tracking(4)
                Spacer()
                Image(systemName: "shrike.fill") // Monochrome Logo
                    .font(.title2)
            }
            
            Spacer()
            
            Text("•••• •••• •••• 9283")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
            
            Spacer()
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CARD HOLDER")
                        .font(DesignSystem.Typography.caption)
                    Text(appState.currentUser?.name.uppercased() ?? "USER NAME")
                        .font(DesignSystem.Typography.subheadline)
                        .bold()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("STATUS")
                        .font(DesignSystem.Typography.caption)
                    Text(viewModel.institutions.first?.isFrozen == true ? "FROZEN" : "ACTIVE")
                        .font(DesignSystem.Typography.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignSystem.Colors.background(scheme))
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                        .cornerRadius(6)
                }
            }
        }
        .padding(24)
        .foregroundColor(DesignSystem.Colors.background(scheme))
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DesignSystem.Colors.textPrimary(scheme))
        )
    }
    
    private var cardBack: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("PAYMENT QR CODE")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            if let payload = qrPayload, 
               let jsonData = try? QRPayload.qrEncoder.encode(payload), 
               let jsonString = String(data: jsonData, encoding: .utf8) {
                QRCodeView(data: jsonString)
                    .frame(width: 140, height: 140)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                ProgressView()
                    .frame(width: 140, height: 140)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DesignSystem.Colors.surface(scheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(DesignSystem.Colors.textPrimary(scheme).opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    @State private var decodeErrorMessage: String?
    @State private var showDecodeError = false
    
    private func handleScanResult(_ result: String) {
        print("DEBUG: Scanned result string: \(result)")
        
        var cleanJson = result.trimmingCharacters(in: .whitespacesAndNewlines)
        if let start = cleanJson.range(of: "{")?.lowerBound,
           let end = cleanJson.range(of: "}", options: .backwards)?.upperBound {
            cleanJson = String(cleanJson[start..<end])
        }
        
        guard let data = cleanJson.data(using: .utf8) else { return }

        let strategies: [(JSONDecoder.DateDecodingStrategy, JSONDecoder.KeyDecodingStrategy)] = [
            (.iso8601, .convertFromSnakeCase),
            (.iso8601, .useDefaultKeys),
            (.deferredToDate, .useDefaultKeys),
            (.deferredToDate, .convertFromSnakeCase),
            (.secondsSince1970, .convertFromSnakeCase),
            (.secondsSince1970, .useDefaultKeys)
        ]

        for (dateStr, keyStr) in strategies {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateStr
            decoder.keyDecodingStrategy = keyStr
            if let payload = try? decoder.decode(QRPayload.self, from: data) {
                processPayload(payload)
                return
            }
        }
        
        self.decodeErrorMessage = "We could not read this QR code. Please scan a valid Stream payment QR code."
        self.showDecodeError = true
    }

    private func processPayload(_ payload: QRPayload) {
        print("Successfully decoded QR Payload: \(payload)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.activeQRPayload = payload
        }
    }

    func toggleFreeze(id: UUID) async {
        do {
            _ = try await APIService.shared.toggleFreeze(id: id)
            await viewModel.refreshData()
        } catch {
            print("Toggle freeze failed: \(error)")
        }
    }
}

struct CardActionBtn: View {
    let title: String
    let icon: String
    let isActive: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(DesignSystem.Typography.callout)
                    .bold()
                Spacer()
            }
            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            .padding()
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
        }
    }
}

struct QRCodeView: View {
    let data: String
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        if let image = generateQRCode(from: data) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .opacity(0.2)
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return nil
    }
}
