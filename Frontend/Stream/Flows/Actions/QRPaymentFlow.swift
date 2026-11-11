import SwiftUI
import LocalAuthentication

struct QRPaymentFlow: View {
    let payload: QRPayload
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    
    @State private var isAuthenticating = false
    @State private var pin: String = ""
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var success = false
    @State private var destinationInstitution: Institution?
    @State private var sourceInstitutions: [Institution] = []
    @State private var selectedSourceId: UUID?
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            if success {
                successView
            } else {
                ScrollView {
                    VStack(spacing: 32) {
                        header
                        
                        detailsCard
                        
                        authSection
                        
                        confirmButton
                        
                        if let error = errorMessage {
                            FriendlyErrorBanner(message: error)
                        }
                    }
                    .padding(24)
                }
            }
        }
        .disabled(isProcessing)
        .onAppear {
            fetchDestinationInfo()
            fetchAvailableSources()
        }
    }
    
    private func fetchDestinationInfo() {
        guard let destId = payload.destinationId else { return }
        Task {
            do {
                let response = try await APIService.shared.fetchInstitutionDetail(id: destId)
                if response.success {
                    self.destinationInstitution = response.data
                }
            } catch {
                print("Failed to fetch destination info: \(error)")
            }
        }
    }
    
    private func fetchAvailableSources() {
        Task {
            do {
                let response = try await APIService.shared.fetchInstitutions()
                if response.success {
                    self.sourceInstitutions = response.data ?? []
                    self.selectedSourceId = sourceInstitutions.first?.id
                }
            } catch {
                print("Failed to fetch sources: \(error)")
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Text("CONFIRM PAYMENT")
                .font(DesignSystem.Typography.headline)
                .tracking(2)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            if let inst = destinationInstitution {
                Text("PAYING \(inst.name.uppercased())")
                    .font(DesignSystem.Typography.subheadline).bold()
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    .padding(.top, 4)
            } else {
                Text("Please check the details below")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
        }
    }
    
    private var detailsCard: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("AMOUNT")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                Text("\(Int(payload.amount)) RWF")
                    .font(DesignSystem.Typography.balanceSmall)
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            }
            
            Divider()
            
            HStack {
                QRDetailRow(label: "TYPE", value: payload.type.rawValue)
                Spacer()
                QRDetailRow(label: "EXPIRES", value: payload.expiresAt.formatted(date: .omitted, time: .shortened))
            }
            
            if !sourceInstitutions.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("PAY FROM")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    
                    Picker("Source", selection: $selectedSourceId) {
                        ForEach(sourceInstitutions) { inst in
                            Text(inst.name).tag(inst.id as UUID?)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(DesignSystem.Colors.textPrimary(scheme))
                    .padding(.horizontal, -12) // Align with text
                }
            }
        }
        .padding(24)
        .background(DesignSystem.Colors.surface(scheme))
        .cornerRadius(16)
    }
    
    private var authSection: some View {
        VStack(spacing: 16) {
            Text("ENTER YOUR 4-DIGIT PIN")
                .font(DesignSystem.Typography.caption).bold()
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            SecureField("••••", text: $pin)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                .padding()
                .frame(width: 160)
                .background(DesignSystem.Colors.surface(scheme))
                .cornerRadius(12)
        }
    }
    
    private var confirmButton: some View {
        Button(action: executeTransaction) {
            HStack {
                if isProcessing {
                    ProgressView().tint(.white)
                } else {
                    Text("Confirm & Pay")
                        .font(DesignSystem.Typography.callout).bold()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(DesignSystem.Colors.textPrimary(scheme))
            .foregroundColor(DesignSystem.Colors.background(scheme))
            .cornerRadius(12)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("TRANSACTION SUCCESSFUL")
                .font(DesignSystem.Typography.headline).bold()
            
            Button("DONE") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    private func executeTransaction() {
        guard pin.count >= 4 else { return }
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.executeQR(
                    payload: payload, 
                    pin: pin, 
                    sourceId: selectedSourceId
                )
                if response.success {
                    withAnimation { success = true }
                } else {
                    errorMessage = response.message ?? "Transaction failed"
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isProcessing = false
        }
    }
}

struct QRDetailRow: View {
    let label: String
    let value: String
    @Environment(\.colorScheme) var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            Text(value)
                .font(DesignSystem.Typography.footnote).bold()
        }
    }
}
