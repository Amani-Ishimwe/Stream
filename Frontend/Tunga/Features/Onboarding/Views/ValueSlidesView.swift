import SwiftUI

struct ValueSlidesView: View {
    @Binding var path: NavigationPath
    @Environment(\.colorScheme) var colorScheme
    @State private var currentPage = 0
    
    let slides = [
        OnboardingSlide(image: "globe.americas.fill", title: "Global Connectivity", description: "Send money instantly to anyone, anywhere in the world."),
        OnboardingSlide(image: "lock.shield.fill", title: "Bank-Grade Security", description: "Your transactions are protected by advanced encryption and biometrics."),
        OnboardingSlide(image: "bolt.fill", title: "Instant Transfers", description: "Experience lightning-fast payments that arrive in seconds."),
        OnboardingSlide(image: "creditcard.circle.fill", title: "Virtual & Physical Cards", description: "Shop online or in-store with our secure card solutions."),
        OnboardingSlide(image: "chart.bar.doc.horizontal.fill", title: "Smart Insights", description: "Track your spending habits with detailed, easy-to-read reports.")
    ]
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            // Illustration Area (approx 50-60% of screen height contextually)
                            GeometryReader { geometry in
                                ZStack {
                                    Circle()
                                        .fill(DesignSystem.Colors.accent(colorScheme).opacity(0.1))
                                        .frame(width: geometry.size.height * 0.8, height: geometry.size.height * 0.8)
                                    
                                    Image(systemName: slides[index].image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: geometry.size.height * 0.5)
                                        .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(height: UIScreen.main.bounds.height * 0.5)
                            .accessibilityHidden(true) // Decorational only, text handles the content
                            
                            // Text Area
                            VStack(spacing: 16) {
                                Text(slides[index].title)
                                    .font(DesignSystem.Typography.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                    .multilineTextAlignment(.center)
                                    .accessibilityAddTraits(.isHeader)
                                
                                Text(slides[index].description)
                                    .font(DesignSystem.Typography.valueProp) // 24pt+ equivalent requested
                                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .tag(index)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Slide \(index + 1) of \(slides.count). \(slides[index].title), \(slides[index].description)")
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Dot Indicator
                HStack(spacing: 12) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? DesignSystem.Colors.accent(colorScheme) : DesignSystem.Colors.textSecondary(colorScheme).opacity(0.3))
                            .frame(width: 10, height: 10)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .accessibilityLabel("Page \(index + 1)")
                            .onTapGesture {
                                withAnimation { currentPage = index }
                            }
                    }
                }
                .padding(.bottom, 24)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Page indicator, page \(currentPage + 1) of \(slides.count)")
                
                // Navigation Buttons or "Get Started" logic
                Button(action: {
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    
                    if currentPage < slides.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        // Move to Account Creation
                        path.append(OnboardingStep.createAccount)
                    }
                }) {
                    Text(currentPage < slides.count - 1 ? "Next" : "Create Account")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primary(colorScheme))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadius)
                                .fill(DesignSystem.Colors.accent(colorScheme))
                        )
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.bottom, DesignSystem.Spacing.xLarge)
                .accessibilityHint(currentPage < slides.count - 1 ? "Moves to the next slide" : "Starts the account creation process")
            }
        }
        .navigationBarHidden(true)
    }
}

struct OnboardingSlide {
    let image: String
    let title: String
    let description: String
}
