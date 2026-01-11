import  SwiftUI

struct QRScanView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var isScanning = true
    @State private var showConfirmation = false
    @State private var scannedCode: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera Layer
                if isScanning {
                    QRScannerView { code in
                        self.scannedCode = code
                        self.isScanning = false
                        
                        // Haptic
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        withAnimation {
                            showConfirmation = true
                        }
                    }
                    .ignoresSafeArea()
                }
                
                // Overlay
                ZStack {
                    DesignSystem.Colors.primary(colorScheme).opacity(0.8) // Use Primary for overlay
                        .background(.ultraThinMaterial.opacity(0.3))
                        .mask(
                            Rectangle()
                                .fill(Color.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .frame(width: 280, height: 280)
                                        .blendMode(.destinationOut)
                                )
                                .compositingGroup()
                        )
                        .ignoresSafeArea()
                    
                    // Animated Border frame
                    ScanningFrame(color: DesignSystem.Colors.accent(colorScheme))
                        .frame(width: 280, height: 280)
                    
                    VStack {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(DesignSystem.Colors.background(colorScheme)) // High contrast
                            }
                            .padding()
                            Spacer()
                        }
                        
                        Text("Scan to Pay")
                            .font(DesignSystem.Typography.title)
                            .foregroundColor(DesignSystem.Colors.background(colorScheme))
                        
                        Text("Point the camera at a SwiftPay+ QR code")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.background(colorScheme).opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        // Torch Toggle Mock
                        Button(action: { /* Toggle Torch */ }) {
                            Image(systemName: "flashlight.on.fill")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                                .padding()
                                .background(Circle().fill(DesignSystem.Colors.accent(colorScheme)))
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showConfirmation) {
                PaymentConfirmationSheet(code: scannedCode ?? "", onDismiss: {
                    isScanning = true
                    showConfirmation = false
                })
                .presentationDetents([.fraction(0.6)])
            }
        }
    }
}

struct ScanningFrame: View {
    let color: Color
    @State private var animate = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .stroke(color, lineWidth: 2)
                .opacity(0.3)
            
            // Corners
            ForEach(0..<4) { index in
                cornerPiece
                    .rotationEffect(.degrees(Double(index) * 90))
            }
            
            // Scanning Line
            Rectangle()
                .fill(LinearGradient(colors: [color.opacity(0), color, color.opacity(0)], startPoint: .top, endPoint: .bottom))
                .frame(height: 2)
                .offset(y: animate ? 140 : -140)
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
    
    var cornerPiece: some View {
        GeometryReader { proxy in
            Path { path in
                let w = proxy.size.width
                let h = proxy.size.height
                let l: CGFloat = 40
                
                path.move(to: CGPoint(x: 0, y: l))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: l, y: 0))
            }
            .stroke(color, lineWidth: 4)
        }
    }
}

struct PaymentConfirmationSheet: View {
    let code: String
    let onDismiss: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var processing = false
    @State private var success = false
    
    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top)
            
            if success {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                    Text("Payment Successful!")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    Button("Dismiss", action: onDismiss)
                        .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            } else {
                Text("Confirm Payment")
                    .font(DesignSystem.Typography.headline)
                
                HStack(spacing: 16) {
                    Circle()
                        .fill(DesignSystem.Colors.accent(colorScheme).opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(Image(systemName: "person.fill").foregroundColor(DesignSystem.Colors.accent(colorScheme)))
                    
                    VStack(alignment: .leading) {
                        Text("Merchant / User")
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        Text(code)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    }
                    Spacer()
                }
                .padding()
                .background(DesignSystem.Colors.surface(colorScheme))
                .cornerRadius(16)
                
                Spacer()
                
                if processing {
                    ProgressView("Processing Securely...")
                        .tint(DesignSystem.Colors.accent(colorScheme))
                } else {
                    SlideToAction(title: "Slide to Pay") {
                        processing = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            success = true
                            processing = false
                        }
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(DesignSystem.Colors.background(colorScheme))
    }
}
