//
//  GalleryView.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

import SwiftUI

struct GalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @EnvironmentObject var localization: LocalizationManager
    @State private var selectedTab = 0  // 0: Все, 1: Избранное, 2: Категории
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            Color("AppBg").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Заголовок
                VStack(spacing: 8) {
                    HStack {
                        Text(localization.galleryTitle)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Spacer()
                        Button(action: {
                            Task { await viewModel.loadData() }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "5BAECC"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Сегментированный контрол
                    Picker("", selection: $selectedTab) {
                        Text(localization.allTab).tag(0)
                        Text(localization.favoritesTab).tag(1)
                        Text(localization.categoriesTab).tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(Color(hex: "5BAECC"))
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            switch selectedTab {
                            case 0: // Все карточки
                                if viewModel.recentCards.isEmpty {
                                    emptyStateView(
                                        icon: "photo.on.rectangle",
                                        title: localization.noCardsGallery,
                                        subtitle: localization.createFirstCardHint
                                    )
                                } else {
                                    allCardsSection
                                }

                            case 1: // Избранное
                                if viewModel.favoriteCards.isEmpty {
                                    emptyStateView(
                                        icon: "heart",
                                        title: localization.noFavorites,
                                        subtitle: localization.addToFavoritesHint
                                    )
                                } else {
                                    favoriteCardsSection
                                }

                            case 2: // Категории
                                if viewModel.categories.isEmpty {
                                    emptyStateView(
                                        icon: "folder",
                                        title: localization.noCategoriesGallery,
                                        subtitle: localization.createCategoryHint
                                    )
                                } else {
                                    categoriesSection
                                }
                                
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }
            }
        }
        .onAppear {
            Task { await viewModel.loadData() }
        }
    }
    
    // MARK: - Все карточки
    private var allCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(localization.allTab) (\(viewModel.recentCards.count))")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("AppTextPrimary"))
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.recentCards) { card in
                    CardGridItem(card: card, viewModel: viewModel)
                }
            }
        }
    }
    
    // MARK: - Избранные карточки
    private var favoriteCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(localization.favoritesTab) (\(viewModel.favoriteCards.count))")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("AppTextPrimary"))
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.favoriteCards) { card in
                    CardGridItem(card: card, viewModel: viewModel)
                }
            }
        }
    }
    
    // MARK: - Категории
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(localization.categoriesTab) (\(viewModel.categories.count))")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("AppTextPrimary"))
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 140, maximum: 160), spacing: 12)
            ], spacing: 12) {
                ForEach(viewModel.categories) { category in
                    CategoryGridItem(category: category)
                }
            }
        }
    }
    
    // MARK: - Пустое состояние
    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)
            ZStack {
                Circle()
                    .fill(Color("AppTintPurple"))
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "7C5CBF"))
            }
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("AppTextPrimary"))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            Spacer().frame(height: 40)
        }
    }
}

// MARK: - Карточка в сетке
struct CardGridItem: View {
    let card: Card
    @ObservedObject var viewModel: GalleryViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Изображение
            if let uiImage = card.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(12)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("AppPlaceholderBg"))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // Слово и кнопки
            VStack(spacing: 6) {
                Text(card.word)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("AppTextPrimary"))
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.toggleFavorite(card)
                    }) {
                        Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(card.isFavorite ? Color(hex: "F87171") : Color("AppTextSecondary"))
                    }
                    
                    Button(action: {
                        viewModel.speakCard(card)
                    }) {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "5BAECC"))
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Категория в сетке
struct CategoryGridItem: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("AppTintPurple"))
                    .frame(height: 80)
                
                if let icon = category.icon, !icon.isEmpty {
                    Text(icon)
                        .font(.system(size: 32))
                } else {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "7C5CBF"))
                }
            }
            
            Text(category.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color("AppTextPrimary"))
                .lineLimit(1)
            
            if let count = category.cardCount {
                Text("\(count) \(LocalizationManager.shared.cardsSuffix)")
                    .font(.system(size: 12))
                    .foregroundColor(Color("AppTextSecondary"))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("AppSurface"))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Расширение Category для cardCount
extension Category {
    var cardCount: Int? {
        // В текущей схеме нет поля cardCount, можно добавить позже
        nil
    }
}

#Preview {
    GalleryView()
}