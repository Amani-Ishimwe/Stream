import SwiftUI

struct CreatePinView: View {
    @State private var currentPin: String = ""
    @State private var confirmPin: String = ""
    @State private var step: Int = 1 // 1: Create, 2: Confirm
    
    // UI state to show matching error
    @State private var pinsMatch: Bool = true
    
    var body: some View {
        VStack(spacing: 50) {
            Text(step == 1 ? "Create Your Wallet PIN" : "Confirm Your PIN")
                .font(.title2).bold()
            
            Text("This 6-digit PIN is required for all transactions.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // PIN Display Indicators
            HStack(spacing: 15) {
                ForEach(0..<6) { index in
                    Circle()
                        .fill(indicatorColor(for: index))
                        .frame(width: 20, height: 20)
                }
            }
            .animation(.easeInOut, value: activeInput.count)
            .padding(.bottom, 20)
            
            // Custom Numeric Keypad Simulation (Component Blueprint)
            NumericKeypadView(input: activeInputBinding)
            
            if !pinsMatch {
                Text("PINs do not match. Try again.")
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
            
            Spacer()
        }
        .padding()
        .onChange(of: activeInput) { _, newValue in
            if newValue.count == 6 {
                handlePinCompletion()
            }
        }
    }
    
    // Current input value and binding for the active step
    private var activeInput: String { activeInputBinding.wrappedValue }
    
    private var activeInputBinding: Binding<String> {
        step == 1 ? $currentPin : $confirmPin
    }
    
    func indicatorColor(for index: Int) -> Color {
        index < activeInput.count ? .blue : Color(.systemGray4)
    }

    func handlePinCompletion() {
        if step == 1 {
            // Move to confirmation step
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                step = 2
                currentPin = activeInputBinding.wrappedValue // Store the first pin
                activeInputBinding.wrappedValue = "" // Reset input for confirmation
            }
        } else {
            // Confirmation step
            if currentPin == confirmPin {
                pinsMatch = true
                // ViewModel: Call API to save PIN hash for the user
                print("PIN Saved Successfully!")
                // Navigate to Dashboard
            } else {
                pinsMatch = false
                // Reset to step 1 after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    step = 1
                    currentPin = ""
                    confirmPin = ""
                }
            }
        }
    }
}
