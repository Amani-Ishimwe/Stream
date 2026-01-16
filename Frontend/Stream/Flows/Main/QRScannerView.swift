import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    @State private var isScanning = true
    @State private var scannedResult: String? {
        didSet {
            if scannedResult != nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(scheme).ignoresSafeArea()
            
            CameraScannerView(result: $scannedResult)
                .overlay(
                    VStack {
                        Spacer()
                        designOverlay
                        Spacer()
                    }
                )
                .ignoresSafeArea()
            
            VStack {
                header
                Spacer()
                footer
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            Spacer()
            Text("SCAN QR CODE")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.white)
            Spacer()
            Button(action: { /* Toggle Flash */ }) {
                Image(systemName: "bolt.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding()
        .foregroundColor(.white)
    }
    
    private var designOverlay: some View {
        ZStack {
            // Scanner Frame
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(DesignSystem.Colors.softBeige, lineWidth: 2)
                .frame(width: 260, height: 260)
            
            // Animated Scanning Line
            Rectangle()
                .fill(DesignSystem.Colors.softBeige)
                .frame(width: 240, height: 2)
                .offset(y: isScanning ? -120 : 120)
                .onAppear {
                    withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: true)) {
                        isScanning.toggle()
                    }
                }
        }
    }
    
    private var footer: some View {
        VStack(spacing: 16) {
            Text("ALIGN QR CODE WITHIN THE FRAME")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 24) {
                Button(action: { /* Upload from Gallery */ }) {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                        Text("GALLERY")
                            .font(DesignSystem.Typography.caption)
                    }
                }
                
                Button(action: { /* Show My QR */ }) {
                    VStack {
                        Image(systemName: "qrcode")
                            .font(.title2)
                        Text("MY CODE")
                            .font(DesignSystem.Typography.caption)
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.bottom, 40)
        }
    }
}
