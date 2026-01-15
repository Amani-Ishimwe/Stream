import SwiftUI

struct SlideToAction: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var offset: CGFloat = 0
    @State private var isFinished = false
    
    let title: String
    let perform: () -> Void
    
    private let height: CGFloat = 56
    private let padding: CGFloat = 4
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(DesignSystem.Colors.surface(colorScheme))
                
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    .frame(maxWidth: .infinity)
                
                // Slider
                HStack {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.textPrimary(colorScheme))
                            .frame(width: height - 2 * padding, height: height - 2 * padding)
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(DesignSystem.Colors.background(colorScheme))
                    }
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isFinished {
                                    let totalWidth = geo.size.width - height
                                    if value.translation.width > 0 && value.translation.width < totalWidth {
                                        offset = value.translation.width
                                    }
                                }
                            }
                            .onEnded { value in
                                let totalWidth = geo.size.width - height
                                if offset > totalWidth * 0.8 {
                                    withAnimation {
                                        offset = totalWidth
                                        isFinished = true
                                    }
                                    // Trigger action
                                    perform()
                                } else {
                                    withAnimation {
                                        offset = 0
                                    }
                                }
                            }
                    )
                    Spacer()
                }
                .padding(padding)
            }
        }
        .frame(height: height)
        .padding(.horizontal)
    }
}
