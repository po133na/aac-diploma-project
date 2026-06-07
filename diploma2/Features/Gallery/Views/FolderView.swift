// Features/Gallery/Views/FolderView.swift
import Foundation
import SwiftUI

struct FolderDetailView: View {
    let folder: Category
    @ObservedObject var viewModel: GalleryViewModel
    @Environment(\.dismiss) var dismiss

    var folderCards: [Card] {
        viewModel.recentCards.filter { $0.categoryId == folder.id }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBgAlt").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if folderCards.isEmpty {
                            EmptyFolderView()
                        } else {
                            ForEach(folderCards) { card in
                                FolderCardRow(card: card)
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
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                }
            }
        }
    }
}

private struct FolderCardRow: View {
    let card: Card
    @ObservedObject private var l = LocalizationManager.shared
    @State private var uiImage: UIImage? = nil

    var body: some View {
        HStack {
            Group {
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("AppPlaceholderBg"))
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(card.localizedWord(language: l.currentLanguage))
                .font(.system(size: 15))
                .foregroundColor(Color("AppTextPrimary"))

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("AppSurface"))
        )
        .task(id: card.id) {
            guard uiImage == nil, !card.imageBase64.isEmpty else { return }
            let base64 = card.imageBase64
            let img = await Task.detached(priority: .userInitiated) {
                guard let data = Data(base64Encoded: base64) else { return UIImage?.none }
                return UIImage(data: data)
            }.value
            uiImage = img
        }
    }
}

struct EmptyFolderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 80))
                .foregroundColor(Color("AppTextSecondary"))

            Text(LocalizationManager.shared.folderEmpty)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("AppTextPrimary"))

            Text(LocalizationManager.shared.folderAddHint)
                .font(.system(size: 14))
                .foregroundColor(Color("AppTextSecondary"))
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
}
