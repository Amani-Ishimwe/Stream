import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background(colorScheme)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Choose Language")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                    .padding(.top, 40)
                
                Text("You can change this later in Settings.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(MockData.languages, id: \.self) { language in
                        Button {
                            appState.chooseLanguage(language)
                        } label: {
                            Text(language)
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(DesignSystem.Colors.surface(colorScheme))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

