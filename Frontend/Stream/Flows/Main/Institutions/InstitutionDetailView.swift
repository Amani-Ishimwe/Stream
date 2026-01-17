import SwiftUI
import Combine
import Photos

struct InstitutionDetailView: View {
    @State var institution: Institution
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = InstitutionDetailViewModel()
    
    @State private var showSend = false
    @State private var showRequest = false
    @State private var showTopUp = false
    @State private var isFlipped = false
    @State private var showLimitEdit = false
    @State private var dailyLimit: String = ""
    @State private var monthlyLimit: String = ""
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        ZStack {
                            balanceCard
                                .opacity(isFlipped ? 0 : 1)
                                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                            
                            qrCodeBack
                                .opacity(isFlipped ? 1 : 0)
                                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                        }
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipped)
                        
                        limitsSection
                        
                        quickActions
                        
                        historySection
                    }
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.institution = institution
            Task {
                await viewModel.refreshAll()
            }
        }
        .onChange(of: viewModel.institution) { newValue in
            if let newValue = newValue {
                self.institution = newValue
            }
        }
        .sheet(isPresented: $showSend, onDismiss: { Task { await viewModel.refreshAll() } }) {
            SendMoneyFlow(preSelectedSource: institution)
        }
        .sheet(isPresented: $showTopUp, onDismiss: { Task { await viewModel.refreshAll() } }) {
            TopUpFlow(preSelectedSource: institution)
        }
        .sheet(isPresented: $showRequest, onDismiss: { Task { await viewModel.refreshAll() } }) {
            RequestMoneyFlow(preSelectedDestination: institution)
        }
        .sheet(isPresented: $showLimitEdit) {
            LimitEditView(daily: $dailyLimit, monthly: $monthlyLimit) {
                Task {
                    await viewModel.updateLimits(id: institution.id, daily: Double(dailyLimit) ?? 0, monthly: Double(monthlyLimit) ?? 0)
                    showLimitEdit = false
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
                Text("CURRENT ASSET VALUE")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                Text("\(Int(institution.balance ?? 0))")
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
                StatusPill(title: (institution.isFrozen ?? false) ? "FROZEN" : "ACTIVE", 
                          isActive: !(institution.isFrozen ?? false))
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
            HStack {
                Text("INSTITUTIONAL LIMITS")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                Spacer()
                Button(action: { 
                    dailyLimit = "\(Int(institution.dailyLimit ?? 0))"
                    monthlyLimit = "\(Int(institution.monthlyLimit ?? 0))"
                    showLimitEdit = true 
                }) {
                    Text("MANAGE")
                        .font(DesignSystem.Typography.caption).bold()
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                }
            }
            
            VStack(spacing: 1) {
                LimitRow(label: "DAILY SPENDING", value: "\(Int(institution.dailyLimit ?? 0)) RWF")
                LimitRow(label: "MONTHLY VOLUME", value: "\(Int(institution.monthlyLimit ?? 0)) RWF")
            }
            .background(DesignSystem.Colors.surface(scheme))
            .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
            
            Button(action: {
                Task {
                    await viewModel.toggleFreeze(id: institution.id)
                }
            }) {
                HStack {
                    if viewModel.isFreezing {
                        ProgressView().tint(DesignSystem.Colors.background(scheme))
                    } else {
                        Image(systemName: (institution.isFrozen ?? false) ? "lock.open.fill" : "lock.fill")
                        Text((institution.isFrozen ?? false) ? "REACTIVATE INSTRUMENT" : "FREEZE INSTRUMENT")
                            .font(DesignSystem.Typography.caption).bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background((institution.isFrozen ?? false) ? DesignSystem.Colors.textPrimary(scheme) : Color.red.opacity(0.8))
                .foregroundColor(DesignSystem.Colors.background(scheme))
                .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var quickActions: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ActionIconBtn(title: "SEND", icon: "arrow.up.right") { showSend = true }
            ActionIconBtn(title: isFlipped ? "VIEW CARD" : "REQUEST", icon: isFlipped ? "creditcard" : "qrcode") {
                withAnimation { isFlipped.toggle() }
            }
            ActionIconBtn(title: "TOP UP", icon: "plus") { showTopUp = true }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }
    
    private var qrCodeBack: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("SECURE PAYMENT QR")
                .font(DesignSystem.Typography.caption).bold()
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            VStack {
                if let payload = viewModel.qrPayload, let jsonData = try? JSONEncoder().encode(payload), let jsonString = String(data: jsonData, encoding: .utf8) {
                    QRCodeView(data: jsonString)
                        .frame(width: 140, height: 140)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: DesignSystem.Colors.textPrimary(scheme).opacity(0.1), radius: 10)
                } else {
                    ProgressView()
                        .frame(width: 140, height: 140)
                        .onAppear {
                            Task { await viewModel.generatePaymentQR() }
                        }
                }
            }
            
            Text(institution.accountNumber ?? "STREAM-USER-ID")
                .font(DesignSystem.Typography.footnote).monospaced()
                .opacity(0.6)
            
            Button(action: { viewModel.saveQRToPhotos() }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("SAVE TO PHOTOS")
                        .font(DesignSystem.Typography.caption).bold()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(DesignSystem.Colors.textPrimary(scheme))
                .foregroundColor(DesignSystem.Colors.background(scheme))
                .cornerRadius(20)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.surface(scheme))
        .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
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

@MainActor
class InstitutionDetailViewModel: ObservableObject {
    @Published var institution: Institution?
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var isFreezing = false
    @Published var qrPayload: QRPayload?
    
    func refreshAll() async {
        guard let id = institution?.id else { return }
        isLoading = true
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchDetail(id: id) }
            group.addTask { await self.fetchTransactions(id: id) }
        }
        isLoading = false
    }

    func generatePaymentQR() async {
        guard let id = institution?.id else { return }
        do {
            let response = try await APIService.shared.generateQR(type: .send, amount: 0, destinationId: id)
            self.qrPayload = response.data
        } catch {
            print("Failed to generate QR: \(error)")
        }
    }
    
    private func fetchDetail(id: UUID) async {
        do {
            let response = try await APIService.shared.fetchInstitutionDetail(id: id)
            if response.success, let data = response.data {
                self.institution = data
            }
        } catch {
            print("Failed to fetch detail: \(error)")
        }
    }
    
    private func fetchTransactions(id: UUID) async {
        do {
            let response = try await APIService.shared.fetchInstitutionTransactions(id: id)
            if response.success, let data = response.data {
                self.transactions = data
            }
        } catch {
            print("Failed to fetch inst transactions: \(error)")
        }
    }
    
    func toggleFreeze(id: UUID) async {
        isFreezing = true
        do {
            let response = try await APIService.shared.toggleFreeze(id: id)
            if response.success, let data = response.data {
                self.institution = data
            }
        } catch {
            print("Failed to toggle freeze: \(error)")
        }
        isFreezing = false
    }
    
    func updateLimits(id: UUID, daily: Double, monthly: Double) async {
        do {
            let response = try await APIService.shared.updateLimits(id: id, daily: daily, monthly: monthly)
            if response.success, let data = response.data {
                self.institution = data
            }
        } catch {
            print("Failed to update limits: \(error)")
        }
    }

    func saveQRToPhotos() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let payload = qrPayload,
              let jsonData = try? encoder.encode(payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        
        // Create a temporary view to render
        let qrView = VStack(spacing: 16) {
            Text("STREAM PAYMENT QR")
                .font(.headline)
            QRCodeView(data: jsonString)
                .frame(width: 200, height: 200)
                .padding()
                .background(Color.white)
            Text(institution?.name ?? "STREAM")
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
                    print("QR Saved to Photos")
                } else {
                    print("Photo Library Access Denied")
                }
            }
        }
    }
}

struct LimitEditView: View {
    @Binding var daily: String
    @Binding var monthly: String
    @Environment(\.colorScheme) var scheme
    var onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("MANAGE INSTRUMENT LIMITS")
                .font(DesignSystem.Typography.headline)
                .tracking(2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("DAILY SPENDING LIMIT (RWF)")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                TextField("", text: $daily)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(DesignSystem.Colors.surface(scheme))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("MONTHLY VOLUME LIMIT (RWF)")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                TextField("", text: $monthly)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(DesignSystem.Colors.surface(scheme))
                    .cornerRadius(12)
            }
            
            Button("UPDATE LIMITS", action: onSave)
                .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding(32)
        .background(DesignSystem.Colors.background(scheme).ignoresSafeArea())
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
