import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wallet.pass.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            Text("SwiftPay+")
                .font(.title.bold())
            Text("Version 1.0.0")
                .foregroundColor(.secondary)
            
            Text("SwiftPay+ is a modern e-wallet for fast, secure payments, built with SwiftUI and a focus on delightful user experience.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("About")
    }
}

#Preview {
    AboutView()
}

