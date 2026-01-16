import SwiftUI
import AVFoundation
import PhotosUI

struct QRScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var scheme
    @State private var isScanning = true
    @State private var scannedResult: String?
    @State private var showPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var errorMessage: String?
    @State private var showError = false
    
    var onScan: ((String) -> Void)? = nil
    
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
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { newItem in
            Task {
                do {
                    print("DEBUG: Processing selected gallery item...")
                    guard let item = newItem else { return }
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        throw NSError(domain: "Scanner", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load image data"])
                    }
                    guard let image = UIImage(data: data) else {
                        throw NSError(domain: "Scanner", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image format"])
                    }
                    
                    print("DEBUG: Image loaded, size: \(image.size). Attempting QR detection...")
                    if let result = QRScannerUtils.detectQRCode(from: image) {
                        print("DEBUG: QR Detected from gallery: \(result)")
                        scannedResult = result
                    } else {
                        throw NSError(domain: "Scanner", code: 0, userInfo: [NSLocalizedDescriptionKey: "No QR code detected in this image"])
                    }
                } catch {
                    print("DEBUG: Gallery Error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
        .onChange(of: scannedResult) { newValue in
            if let result = newValue {
                print("DEBUG: scannedResult changed, notifying parent: \(result)")
                onScan?(result)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .alert("SCANNER ERROR", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Unknown error")
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
                Button(action: { showPhotoPicker = true }) {
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
