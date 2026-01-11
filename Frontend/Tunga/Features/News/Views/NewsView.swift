import SwiftUI

struct NewsView: View {
    @StateObject private var viewModel = NewsViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading News...")
                            .padding(.top, 50)
                            .tint(DesignSystem.Colors.accent(colorScheme))
                    } else {
                        ForEach(viewModel.articles) { article in
                            NewsCard(article: article)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding()
                .animation(.spring(), value: viewModel.articles)
            }
            .navigationTitle("Financial News")
            .refreshable {
                await viewModel.loadNews()
            }
            .background(DesignSystem.Colors.background(colorScheme))
        }
    }
}

struct NewsCard: View {
    let article: NewsArticle
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.source.uppercased())
                        .font(DesignSystem.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                    
                    Text(article.title)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary(colorScheme))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: article.imageURL ?? "newspaper")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(DesignSystem.Colors.accent(colorScheme))
                    .padding(10)
                    .background(DesignSystem.Colors.accent(colorScheme).opacity(0.1))
                    .clipShape(Circle())
            }
            
            Text(article.summary)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme))
                .lineLimit(3)
            
            HStack {
                Spacer()
                Text(article.date, style: .date)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary(colorScheme).opacity(0.8))
            }
        }
        .padding()
        .background(DesignSystem.Colors.surface(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: DesignSystem.Colors.primary(colorScheme).opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
