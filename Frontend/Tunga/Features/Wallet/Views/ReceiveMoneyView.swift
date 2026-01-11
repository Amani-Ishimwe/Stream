import SwiftUI

struct ReceiveMoneyView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    
    @State private var selectedTab = 0 // 0: My QR, 1: Request from Contact
    @State private var amount = ""
    @State private var showAmountInput = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Custom Tab Picker
                    HStack(spacing: 0) {
                        tabButton(title: "My QR", index: 0)
                        tabButton(title: "Request", index: 1)
                    }
                    .background(DesignSystem.Colors.surface(colorScheme))
                    .clipShape(Capsule())
                    .padding(.horizontal)
                    
                    if selectedTab == 0 {
                        myQRSection
                    } else {
                        requestSection
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Receive Money")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    var myQRSection: some View {
        VStack(spacing: 32) {
            // QR Container
            VStack(spacing: 20) {
                // Profile Info
                HStack(spacing: 12) {
                    Circle()
                        .fill(DesignSystem.Colors.accent(colorScheme))
                        .frame(width: 44, height: 44)
                        .overlay(Text(appState.currentUser?.name.prefix(1) ?? "A").foregroundColor(DesignSystem.Colors.primary(colorScheme)))
                    
                    VStack(alignment: .leading) {
                        Text(appState.currentUser?.name ?? "Alex Rivera")
                            .font(DesignSystem.Typography.headline)
                        Text("@\(appState.currentUser?.name.lowercased().replacingOccurrences(of: " ", with: "") ?? "alexrivera")")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    }
                    Spacer()
                }
                
                // The QR Code (Placeholder with SF Symbol or simple drawing)
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(DesignSystem.Colors.background(.light)) // Keep light for QR contrast
                        .shadow(color: DesignSystem.Colors.primary(colorScheme).opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "qrcode")
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding()
                        
                        if !amount.isEmpty {
                            Text("Requesting $\(amount)")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(DesignSystem.Colors.accent(colorScheme))
                                .cornerRadius(12)
                        }
                    }
                }
                .frame(width: 280, height: 320)
                
                Text("Scan this code to pay me instantly")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
            }
            .padding(24)
            .background(DesignSystem.Colors.surface(colorScheme))
            .cornerRadius(32)
            .padding(.horizontal)
            
            // Actions
            HStack(spacing: 20) {
                actionButton(icon: "dollarsign.circle.fill", label: amount.isEmpty ? "Set Amount" : "Edit Amount") {
                    showAmountInput = true
                }
                
                actionButton(icon: "square.and.arrow.up.fill", label: "Share Link") {
                    // Share Action
                }
            }
        }
        .sheet(isPresented: $showAmountInput) {
            AmountInputSheet(amount: $amount)
                .presentationDetents([.height(300)])
        }
    }
    
    var requestSection: some View {
        VStack(spacing: 20) {
            // Simplified Transfer to the actual request flow or contact selection
            Text("Send a payment request to someone in your contacts.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { /* Navigate to Contact Picker */ }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Select Contact")
                }
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                .padding()
                .frame(maxWidth: .infinity)
                .background(DesignSystem.Colors.accent(colorScheme))
                .cornerRadius(16)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Pending Requests")
                    .font(DesignSystem.Typography.headline)
                
                ForEach(DemoDataManager.shared.pendingRequests) { request in
                    HStack {
                        Circle()
                            .fill(DesignSystem.Colors.accent(colorScheme).opacity(0.1))
                            .frame(width: 48, height: 48)
                            .overlay(Image(systemName: "arrow.down.left").foregroundColor(DesignSystem.Colors.accent(colorScheme)))
                        
                        VStack(alignment: .leading) {
                            Text(request.requester)
                                .font(DesignSystem.Typography.body)
                                .fontWeight(.semibold)
                            Text(request.note)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                        }
                        Spacer()
                        Text("$\(String(format: "%.2f", request.amount))")
                            .font(DesignSystem.Typography.headline)
                    }
                    .padding()
                    .background(DesignSystem.Colors.surface(colorScheme))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
    
    // MARK: - Helpers
    
    func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = index
            }
        }) {
            Text(title)
                .font(DesignSystem.Typography.callout)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTab == index ? DesignSystem.Colors.accent(colorScheme) : Color.clear)
                .foregroundColor(selectedTab == index ? DesignSystem.Colors.primary(colorScheme) : DesignSystem.Colors.textSecondary(colorScheme))
        }
    }
    
    func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.bold)
            }
            .foregroundColor(DesignSystem.Colors.accent(colorScheme))
            .frame(width: 100)
            .padding(.vertical, 12)
            .background(DesignSystem.Colors.accent(colorScheme).opacity(0.1))
            .cornerRadius(16)
        }
    }
}

struct AmountInputSheet: View {
    @Binding var amount: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Set Requested Amount")
                .font(DesignSystem.Typography.headline)
            
            HStack {
                Text("$").font(.largeTitle).bold().foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                TextField("0.00", text: $amount)
                    .font(.largeTitle)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
            }
            .padding()
            .background(DesignSystem.Colors.surface(colorScheme))
            .cornerRadius(16)
            
            Button("Confirm") {
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding()
    }
}

// PaymentRequest Model (Should be in Models)
struct PaymentRequest: Identifiable {
    let id: String
    let amount: Double
    let requester: String
    let note: String
    let type: RequestType
}

enum RequestType {
    case incoming, outgoing
}

