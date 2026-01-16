import SwiftUI
import Combine

struct LinkInstitutionFlow: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    @StateObject private var viewModel = LinkInstitutionViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.background(scheme).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView().tint(DesignSystem.Colors.textPrimary(scheme))
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.red)
                            Text(error)
                                .font(DesignSystem.Typography.body)
                                .multilineTextAlignment(.center)
                            Button("RETRY") {
                                Task { await viewModel.fetchAvailable() }
                            }
                            .buttonStyle(.primary)
                        }
                        .padding()
                        Spacer()
                    } else if let selected = viewModel.selectedInstitution {
                        balanceInputView(for: selected)
                    } else {
                        availableList
                    }
                }
            }
            .navigationTitle("LINK INSTITUTION")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("CANCEL") {
                        if viewModel.selectedInstitution != nil {
                            withAnimation {
                                viewModel.selectedInstitution = nil
                            }
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .font(DesignSystem.Typography.caption).bold()
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchAvailable() }
        }
    }
    
    private var availableList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.available) { inst in
                    Button(action: {
                        withAnimation {
                            viewModel.selectedInstitution = inst
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: inst.iconSymbol)
                                .font(.system(size: 20))
                                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                                .frame(width: 44, height: 44)
                                .background(DesignSystem.Colors.background(scheme))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(inst.name.uppercased())
                                    .font(DesignSystem.Typography.footnote).bold()
                                Text(inst.type.replacingOccurrences(of: "_", with: " "))
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                            }
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                        }
                        .padding()
                        .background(DesignSystem.Colors.surface(scheme))
                        .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    private func balanceInputView(for inst: Institution) -> some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Image(systemName: inst.iconSymbol)
                    .font(.system(size: 64))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                
                Text("LINK \(inst.name.uppercased())")
                    .font(DesignSystem.Typography.headline)
                    .tracking(2)
            }
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("ENTER INITIAL BALANCE (RWF)")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                
                TextField("0", text: $viewModel.initialBalance)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .keyboardType(.numberPad)
                    .padding()
                    .background(DesignSystem.Colors.surface(scheme))
                    .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        if await viewModel.link() {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView().tint(DesignSystem.Colors.background(scheme))
                    } else {
                        Text("CONFIRM & LINK")
                            .font(DesignSystem.Typography.callout).bold()
                    }
                }
                .buttonStyle(.primary)
                
                Button("BACK") {
                    withAnimation {
                        viewModel.selectedInstitution = nil
                    }
                }
                .font(DesignSystem.Typography.caption).bold()
                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            }
            .padding()
        }
    }
}

@MainActor
class LinkInstitutionViewModel: ObservableObject {
    @Published var available: [Institution] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedInstitution: Institution?
    @Published var initialBalance: String = ""
    
    private let api = APIService.shared
    
    func fetchAvailable() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await api.fetchAvailableInstitutions()
            if response.success, let data = response.data {
                self.available = data
            } else {
                errorMessage = response.message ?? "Failed to load institutions"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func link() async -> Bool {
        guard let inst = selectedInstitution else { return false }
        isLoading = true
        errorMessage = nil
        let cleanBalance = initialBalance.replacingOccurrences(of: " ", with: "")
        let balance = Double(cleanBalance) ?? 0
        
        do {
            let response = try await api.linkInstitution(id: inst.id, balance: balance)
            isLoading = false
            return response.success
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
