import SwiftUI
import CoreImage.CIFilterBuiltins

struct CardsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var scheme
    @StateObject private var viewModel = DashboardViewModel()
    
    @State private var isFlipped = false
    @State private var degrees: Double = 0
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                headerSection
                
                // Smart Card Container
                VStack(spacing: DesignSystem.Spacing.lg) {
                    smartCard
                        .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
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
                
                // Card Actions
                VStack(spacing: DesignSystem.Spacing.md) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        CardActionBtn(title: "FREEZE", icon: "snow", isActive: true) {
                            if let first = viewModel.institutions.first {
                                Task { await toggleFreeze(id: first.id) }
                            }
                        }
                        CardActionBtn(title: "SCAN", icon: "qrcode.viewfinder", isActive: true) {
                            // QR Scan
                        }
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.md) {
                        CardActionBtn(title: "LIMITS", icon: "slider.horizontal.3", isActive: true) { }
                        CardActionBtn(title: "REQUEST", icon: "arrow.down.to.line.compact", isActive: true) { }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                Spacer()
            }
        }
        .onAppear {
            Task { await viewModel.refreshData() }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("SMART CARD")
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
    
    private var smartCard: some View {
        ZStack {
            if isFlipped {
                cardBack.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                cardFront
            }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignSystem.Spacing.lg)
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
            
            Text(appState.currentUser?.id.uuidString.prefix(18).uppercased() ?? "STRM-9283-KLA-112")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
            
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
                        .padding(.vertical, 2)
                        .background(DesignSystem.Colors.background(scheme))
                        .cornerRadius(4)
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
            Text("SECURE PAYMENT QR")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            if let id = appState.currentUser?.id {
                QRCodeView(data: "stream://user/\(id.uuidString)")
                    .frame(width: 140, height: 140)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(8)
                    .background(DesignSystem.Colors.textPrimary(scheme))
                    .cornerRadius(16)
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
