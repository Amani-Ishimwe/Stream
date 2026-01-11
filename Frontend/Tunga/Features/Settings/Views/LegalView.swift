import SwiftUI

struct LegalView: View {
    private let text = """
    SwiftPay+ Privacy & Terms (Placeholder)
    
    Your data is securely stored. By using this app you agree to the terms of service and privacy policy. Replace this text with your legal copy.
    """
    
    var body: some View {
        ScrollView {
            Text(text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Legal & Privacy")
    }
}

