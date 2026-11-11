import SwiftUI

struct AccountLimitsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    
    @State private var institutions: [Institution] = []
    @State private var isLoading = true
    @State private var editingInstitutionId: UUID? = nil
    @State private var editDailyLimitText: String = ""
    @State private var editMonthlyLimitText: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                if let success = successMessage {
                    FriendlySuccessBanner(message: success)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.top, DesignSystem.Spacing.sm)
                }
                
                if let error = errorMessage {
                    FriendlyErrorBanner(message: error)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.top, DesignSystem.Spacing.sm)
                }
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading accounts...")
                        .font(DesignSystem.Typography.footnote)
                        .tint(DesignSystem.Colors.textPrimary(scheme))
                    Spacer()
                } else if institutions.isEmpty {
                    Spacer()
                    Text("No connected accounts found")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.lg) {
                            ForEach(institutions) { inst in
                                accountLimitCard(for: inst)
                            }
                        }
                        .padding(DesignSystem.Spacing.lg)
                    }
                }
            }
        }
        .onAppear {
            loadInstitutions()
        }
    }
    
    private var header: some View {
        HStack {
            Button("CLOSE") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(DesignSystem.Typography.caption)
            .bold()
            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
            
            Spacer()
            
            Text("SPENDING LIMITS")
                .font(DesignSystem.Typography.headline)
                .tracking(1.5)
                .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
            
            Spacer()
            
            Rectangle()
                .frame(width: 45, height: 1)
                .opacity(0)
        }
        .padding()
        .background(DesignSystem.Colors.surface(scheme))
    }
    
    @ViewBuilder
    private func accountLimitCard(for inst: Institution) -> some View {
        let isEditing = (editingInstitutionId == inst.id)
        
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header row with Icon, Name, and Balance
            HStack(spacing: 12) {
                Image(systemName: inst.iconSymbol)
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    .frame(width: 44, height: 44)
                    .background(DesignSystem.Colors.background(scheme))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(inst.name.uppercased())
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    
                    if let balance = inst.balance {
                        Text("Balance: \(Int(balance)) RWF")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    }
                }
                
                Spacer()
                
                if !isEditing {
                    Button(action: {
                        startEditing(inst)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 11, weight: .semibold))
                            Text("CHANGE")
                                .font(DesignSystem.Typography.caption)
                                .bold()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DesignSystem.Colors.background(scheme))
                        .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                        .cornerRadius(14)
                    }
                }
            }
            
            Divider()
            
            if isEditing {
                // Editing mode
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("SET NEW LIMITS FOR \(inst.name.uppercased())")
                        .font(DesignSystem.Typography.caption)
                        .bold()
                        .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DAILY LIMIT (RWF)")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        
                        TextField("0", text: $editDailyLimitText)
                            .keyboardType(.numberPad)
                            .font(DesignSystem.Typography.body)
                            .padding()
                            .background(DesignSystem.Colors.background(scheme))
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                            .onChange(of: editDailyLimitText) { _, val in
                                editDailyLimitText = val.filter { "0123456789".contains($0) }
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("MONTHLY LIMIT (RWF)")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        
                        TextField("0", text: $editMonthlyLimitText)
                            .keyboardType(.numberPad)
                            .font(DesignSystem.Typography.body)
                            .padding()
                            .background(DesignSystem.Colors.background(scheme))
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                            .onChange(of: editMonthlyLimitText) { _, val in
                                editMonthlyLimitText = val.filter { "0123456789".contains($0) }
                            }
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            editingInstitutionId = nil
                            errorMessage = nil
                        }) {
                            Text("Cancel")
                                .font(DesignSystem.Typography.footnote)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(DesignSystem.Colors.background(scheme))
                                .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                                .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                        }
                        
                        Button(action: {
                            saveLimits(for: inst)
                        }) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(DesignSystem.Colors.background(scheme))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Save Changes")
                                        .font(DesignSystem.Typography.footnote)
                                        .bold()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(DesignSystem.Colors.textPrimary(scheme))
                            .foregroundColor(DesignSystem.Colors.background(scheme))
                            .cornerRadius(DesignSystem.Spacing.cornerRadiusButton)
                        }
                        .disabled(isSaving)
                    }
                    .padding(.top, 4)
                }
            } else {
                // View mode: shows daily & monthly limit side by side
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DAILY LIMIT")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        
                        Text("\(Int(inst.dailyLimit ?? 1000000)) RWF")
                            .font(DesignSystem.Typography.footnote)
                            .bold()
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(DesignSystem.Colors.background(scheme))
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MONTHLY LIMIT")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(scheme))
                        
                        Text("\(Int(inst.monthlyLimit ?? 5000000)) RWF")
                            .font(DesignSystem.Typography.footnote)
                            .bold()
                            .foregroundColor(DesignSystem.Colors.textPrimary(scheme))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(DesignSystem.Colors.background(scheme))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(DesignSystem.Colors.surface(scheme))
        .cornerRadius(DesignSystem.Spacing.cornerRadiusCard)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadiusCard)
                .stroke(isEditing ? DesignSystem.Colors.textPrimary(scheme).opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
    }
    
    private func startEditing(_ inst: Institution) {
        editingInstitutionId = inst.id
        editDailyLimitText = "\(Int(inst.dailyLimit ?? 1000000))"
        editMonthlyLimitText = "\(Int(inst.monthlyLimit ?? 5000000))"
        errorMessage = nil
        successMessage = nil
    }
    
    private func loadInstitutions() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let response = try await APIService.shared.fetchInstitutions()
                await MainActor.run {
                    self.institutions = response.data ?? []
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func saveLimits(for inst: Institution) {
        guard let daily = Double(editDailyLimitText), daily > 0 else {
            errorMessage = "Please enter a valid daily limit greater than 0."
            return
        }
        guard let monthly = Double(editMonthlyLimitText), monthly > 0 else {
            errorMessage = "Please enter a valid monthly limit greater than 0."
            return
        }
        guard daily <= monthly else {
            errorMessage = "Daily limit cannot exceed monthly limit."
            return
        }
        
        isSaving = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.updateLimits(id: inst.id, daily: daily, monthly: monthly)
                await MainActor.run {
                    self.isSaving = false
                    if response.success {
                        self.successMessage = "Limits updated successfully for \(inst.name)."
                        self.editingInstitutionId = nil
                        // Reload institutions to get updated values
                        self.loadInstitutions()
                    } else {
                        self.errorMessage = response.message ?? "Failed to update limits."
                    }
                }
            } catch {
                await MainActor.run {
                    self.isSaving = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

