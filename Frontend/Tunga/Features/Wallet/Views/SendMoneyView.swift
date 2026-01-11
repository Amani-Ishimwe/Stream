import SwiftUI

struct SendMoneyView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    @State private var amountString = "0"
    @State private var note = ""
    @State private var step = SendStep.contact
    @State private var selectedContact: Contact?
    @State private var showSuccess = false
    
    enum SendStep {
        case contact
        case amount
        case confirm
    }
    
    let contacts = DemoDataManager.shared.contacts
    
    var body: some View {
        VStack {
            if showSuccess {
                SuccessView(message: "$\(amountString) sent successfully to \(selectedContact?.name ?? "Recipient")") {
                    dismiss()
                }
            } else {
                switch step {
                case .contact:
                    contactSelectionView
                case .amount:
                    amountInputView
                case .confirm:
                    confirmationView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Step 1: Contact
    var contactSelectionView: some View {
        VStack(spacing: 20) {
            Text("Send Money")
                .font(DesignSystem.Typography.headline)
                .padding(.top)
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                TextField("Name, email, or phone", text: $searchText)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
            }
            .padding()
            .background(DesignSystem.Colors.surface(colorScheme))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Recent Grid
            Text("Suggested")
                .font(DesignSystem.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                    ForEach(contacts, id: \.id) { contact in
                        Button(action: {
                            selectedContact = contact
                            withAnimation { step = .amount }
                        }) {
                            VStack {
                                if let avatar = contact.avatar {
                                    Image(systemName: avatar)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                                        .padding(4)
                                        .background(Circle().stroke(DesignSystem.Colors.accent(colorScheme).opacity(0.2), lineWidth: 1))
                                }
                                
                                Text(contact.name)
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Step 2: Amount
    var amountInputView: some View {
        VStack(spacing: 30) {
            // Header
            VStack {
                if let avatar = selectedContact?.avatar {
                    Image(systemName: avatar)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                        .clipShape(Circle())
                }
                Text("Sending to \(selectedContact?.name ?? "Unknown")")
                    .font(DesignSystem.Typography.headline)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Display
            Text("$\(amountString)")
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
            
            TextField("Add a note", text: $note)
                .multilineTextAlignment(.center)
                .padding()
                .background(DesignSystem.Colors.surface(colorScheme))
                .cornerRadius(10)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Keypad Mock (Just using buttons for layout)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(1...9, id: \.self) { num in
                    keypadButton("\(num)")
                }
                keypadButton(".")
                keypadButton("0")
                Button(action: {
                    if !amountString.isEmpty && amountString != "0" {
                        amountString.removeLast()
                        if amountString.isEmpty { amountString = "0" }
                    }
                }) {
                    Image(systemName: "delete.left")
                        .font(.title)
                        .frame(width: 80, height: 80)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                }
            }
            .padding(.bottom)
            
            Button(action: {
                withAnimation { step = .confirm }
            }) {
                Text("Continue")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(DesignSystem.Colors.accent(colorScheme)))
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    func keypadButton(_ val: String) -> some View {
        Button(action: {
            if amountString == "0" { amountString = val }
            else { amountString.append(val) }
        }) {
            Text(val)
                .font(.title)
                .fontWeight(.semibold)
                .frame(width: 80, height: 80)
                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                .background(Circle().fill(DesignSystem.Colors.surface(colorScheme)))
        }
    }
    
    // MARK: - Step 3: Confirm
    var confirmationView: some View {
        VStack(spacing: 30) {
            Text("Confirm Transfer")
                .font(DesignSystem.Typography.title2)
                .padding(.top)
            
            VStack(spacing: 12) {
                Text("$\(amountString)")
                    .font(.system(size: 48, weight: .bold))
                
                Text(selectedContact?.name ?? "Recipient")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                
                if !note.isEmpty {
                    Text("Note: \(note)")
                        .font(DesignSystem.Typography.body)
                        .padding(8)
                        .background(DesignSystem.Colors.surface(colorScheme))
                        .cornerRadius(8)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.background(colorScheme))
            .cornerRadius(16)
            .padding()
            
            Spacer()
            
            // Security Prompt Mock
            HStack {
                Image(systemName: "faceid")
                Text("Authenticated with FaceID")
            }
            .foregroundColor(DesignSystem.Colors.accent(colorScheme))
            .padding(.bottom)
            
            Button("Send Now") {
                // Mock API Call
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                withAnimation { showSuccess = true }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
        }
    }
}

// Model for Contacts (if not in DemoDataManager, add to Services later)
struct Contact: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let avatar: String?
}

// SuccessView (Reusing existing or defining)
struct SuccessView: View {
    let message: String
    let onDismiss: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                .symbolEffect(.bounce)
            
            Text("Transfer Successful!")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
            
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button("Done", action: onDismiss)
                .buttonStyle(PrimaryButtonStyle())
                .padding()
        }
    }
}
