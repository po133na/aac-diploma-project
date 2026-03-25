// Features/Gallery/Views/FolderView.swift
import Foundation
import SwiftUI

struct FolderDetailView: View {
    let folder: Category                        // ← Folder → Category
    @ObservedObject var viewModel: GalleryViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    // Карточки этой категории
    var folderCards: [Card] {
        viewModel.recentCards.filter { $0.categoryId == folder.id }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.currentTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if folderCards.isEmpty {
                            EmptyFolderView()
                        } else {
                            ForEach(folderCards) { card in
                                HStack {
                                    // Изображение карточки
                                    if let image = card.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 48, height: 48)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "C5D8F5"))
                                            .frame(width: 48, height: 48)
                                    }

                                    Text(card.word)             // ← card.text → card.word
                                        .font(.system(size: 15))
                                        .foregroundColor(themeManager.currentTheme.textPrimary)

                                    Spacer()
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.currentTheme.surface)
                                )
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle(folder.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                }
            }
        }
    }
}

struct EmptyFolderView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 80))
                .foregroundColor(themeManager.currentTheme.textSecondary)

            Text("Папка пуста")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            Text("Добавьте карточки в эту папку")
                .font(.system(size: 14))
                .foregroundColor(themeManager.currentTheme.textSecondary)
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    FolderDetailView(
        folder: Category(
            id: 1, name: "Test",
            nameKk: nil, nameEn: nil,
            icon: "📁", userId: nil,
            createdAt: Date()
        ),
        viewModel: GalleryViewModel()
    )
    .environmentObject(ThemeManager())
}
