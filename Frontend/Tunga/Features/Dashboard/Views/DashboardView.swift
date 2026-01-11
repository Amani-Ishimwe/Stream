import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    // Sheet States
    @State private var showSendMoney = false
    @State private var showRequestMoney = false
    @State private var showScan = false
    @State private var showTopUp = false
    @State private var showNotifications = false
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background(colorScheme)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(DesignSystem.Colors.accent(colorScheme))
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: DesignSystem.Spacing.large) {
                            
                            // 1. Top Section (Greeting, Notification, Avatar)
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Good morning,")
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                                    Text(appState.currentUser?.name ?? "Alex")
                                        .font(DesignSystem.Typography.title)
                                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                }
                                Spacer()
                                
                                HStack(spacing: 16) {
                                    Button(action: { showNotifications = true }) {
                                        ZStack {
                                            Circle()
                                                .fill(DesignSystem.Colors.surface(colorScheme))
                                                .frame(width: 44, height: 44)
                                                .overlay(
                                                    Circle().stroke(DesignSystem.Colors.accent(colorScheme).opacity(0.2), lineWidth: 1)
                                                )
                                            
                                            Image(systemName: "bell.fill")
                                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                            
                                            // Badge
                                            Circle()
                                                .fill(DesignSystem.Colors.error(colorScheme))
                                                .frame(width: 10, height: 10)
                                                .offset(x: 10, y: -10)
                                        }
                                    }
                                    .accessibilityLabel("Notifications")
                                    .accessibilityHint("You have unread notifications")
                                    
                                    Button(action: { showProfile = true }) {
                                        let name = appState.currentUser?.name ?? "User"
                                        let firstLetter = String(name.prefix(1)).uppercased()
                                        
                                        Circle()
                                            .fill(DesignSystem.Colors.accent(colorScheme))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Text(firstLetter)
                                                    .font(DesignSystem.Typography.headline)
                                                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                            )
                                    }
                                    .accessibilityLabel("Profile for \(appState.currentUser?.name ?? "User")")
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            // 2. Balance Card (Hero)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Total Balance")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.textSecondary(.dark))
                                
                                HStack(alignment: .lastTextBaseline) {
                                    Text("$")
                                        .font(DesignSystem.Typography.title)
                                        .foregroundColor(DesignSystem.Colors.accent(.dark))
                                    Text(String(format: "%.2f", viewModel.balance))
                                        .font(DesignSystem.Typography.balance)
                                        .foregroundColor(DesignSystem.Colors.accent(.dark))
                                }
                            }
                            .padding(DesignSystem.Spacing.large)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadius)
                                    .fill(DesignSystem.Colors.primary(colorScheme))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadius)
                                            .stroke(DesignSystem.Colors.accent(colorScheme).opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .shadow(color: DesignSystem.Colors.primary(colorScheme).opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                            .onTapGesture {
                                // Action to view full balance details
                            }
                            .accessibilityHint("Double tap to view details")
                            
                            // 3. Virtual Card
                             FlipCardView(
                                 cardNumber: "**** **** **** 4281",
                                 expiry: "12/28",
                                 holder: appState.currentUser?.name ?? "ALEX RIVERA"
                             )
                             .frame(height: 200)
                             .padding(.horizontal)
                            
                            // 4. Quick Actions
                            HStack(spacing: 20) {
                                QuickActionButton(icon: "paperplane.fill", label: "Send", color: DesignSystem.Colors.accent(colorScheme)) {
                                    showSendMoney = true
                                }
                                QuickActionButton(icon: "arrow.down.left.circle.fill", label: "Request", color: DesignSystem.Colors.accent(colorScheme)) {
                                    showRequestMoney = true
                                }
                                QuickActionButton(icon: "qrcode.viewfinder", label: "Scan", color: DesignSystem.Colors.accent(colorScheme)) {
                                    showScan = true
                                }
                                QuickActionButton(icon: "plus.circle.fill", label: "Top-Up", color: DesignSystem.Colors.primary(colorScheme)) {
                                    showTopUp = true
                                }
                            }
                            .padding(.horizontal)
                            
                            // 5. Recent Transactions
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Transactions")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                
                                if viewModel.transactions.isEmpty {
                                    Text("No recent transactions")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(viewModel.transactions.prefix(5)) { transaction in
                                        TransactionRowItem(transaction: transaction)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer(minLength: 100)
                        }
                    }
                    .refreshable {
                        await viewModel.loadDashboardData()
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadDashboardData()
                // Inject current user from Demo Data if needed for Greeting
                if appState.currentUser == nil {
                     appState.currentUser = DemoDataManager.shared.userProfile
                }
            }
            .sheet(isPresented: $showSendMoney) {
                SendMoneyView()
            }
            .sheet(isPresented: $showRequestMoney) {
                ReceiveMoneyView()
            }
            .sheet(isPresented: $showScan) {
                QRScanView()
            }
            .sheet(isPresented: $showTopUp) {
                TopUpView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}

// Components moved to separate files
