//
//  CardDetailView.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//


import SwiftUI
import UIKit

// MARK: - Card Manager Main Screen

struct CardManagerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var showCreateCard     = false
    @State private var showCreateCategory = false
    var onDismissToHome: (() -> Void)? = nil
    var onViewCategory: ((Category) -> Void)? = nil

    var body: some View {
        ZStack {
            Color(hex: "EAF4FB").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Хедер ──
                    HStack {
                        Button { dismiss() } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 36, height: 36)
                                    .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "1C3F6E"))
                            }
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text("Card Manager")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "1C3F6E"))
                            Text("\(homeViewModel.recentCards.count) cards total")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "6B8BAE"))
                        }
                        Spacer()
                        Circle().fill(Color.clear).frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                    // ── Recent Cards ──
                    HStack {
                        Text("Recent Cards")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Spacer()
                        Button("View All >") { onDismissToHome?() }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "F87171"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // Грид реальных карточек
                    let columns = [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                    ]
                    if homeViewModel.recentCards.isEmpty {
                        Text("No cards yet")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "9BB8CC"))
                            .padding(.vertical, 20)
                    } else {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(homeViewModel.recentCards) { card in
                                RealMiniCardView(card: card)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    Spacer().frame(height: 20)

                    // ── Create New Card ──
                    Button { showCreateCard = true } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "F5A623").opacity(0.25))
                                    .frame(width: 42, height: 42)
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "F5A623"))
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Create New Card")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "1C3F6E"))
                                Text("Add a custom card to your library")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "6B8BAE"))
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(hex: "FFF8E7"))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // ── Create New Category ──
                    Button { showCreateCategory = true } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "A78BFA").opacity(0.2))
                                    .frame(width: 42, height: 42)
                                Image(systemName: "paintpalette.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "A78BFA"))
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Create New Category")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(hex: "1C3F6E"))
                                Text("Design your own custom category")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "6B8BAE"))
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(hex: "F3EEFF"))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await homeViewModel.loadRecentCards()
        }
        .sheet(isPresented: $showCreateCard) {
            CreateCardFlow(onDismissToHome: onDismissToHome)
                .environmentObject(homeViewModel)
        }
        .sheet(isPresented: $showCreateCategory) {
            CreateCategoryFlow(onDismissToHome: onDismissToHome, onViewCategory: onViewCategory)
                .environmentObject(homeViewModel)
        }
    }
}

// MARK: - Real Mini Card View

private struct RealMiniCardView: View {
    let card: Card
    @State private var uiImage: UIImage? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                if let img = uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 56)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.horizontal, 6)
                        .padding(.top, 6)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "C5D8F5"))
                        .frame(height: 56)
                        .padding(.horizontal, 6)
                        .padding(.top, 6)
                }
                Text(card.word)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "2C3E50"))
                    .lineLimit(1)
                    .padding(.bottom, 6)
            }
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "EAF4FB"))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .task(id: card.id) {
            guard uiImage == nil else { return }
            let base64 = card.imageBase64
            let img = await Task.detached(priority: .userInitiated) {
                guard let data = Data(base64Encoded: base64) else { return UIImage?.none }
                return UIImage(data: data)
            }.value
            uiImage = img
        }
    }
}

// MARK: - Mini Card View (legacy, unused)

private struct MiniCardView: View {
    let word: String
    let color: Color

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.4))
                    .frame(height: 50)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                Text(word)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "2C3E50"))
                    .padding(.vertical, 8)
            }
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.2))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )

            // Edit кнопка
            ZStack {
                Circle()
                    .fill(Color(hex: "F87171"))
                    .frame(width: 22, height: 22)
                Image(systemName: "pencil")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(x: 4, y: -4)
        }
    }
}


// MARK: - ═══════════════════════════════════════
// MARK:   CREATE CARD FLOW
// MARK: - ═══════════════════════════════════════

enum CreateCardStep: Int, CaseIterable {
    case imageSource = 1
    case describeImage = 2
    case previewImage = 3
    case nameCard = 4
    case saveCard = 5  // step 6 в дизайне
    case success = 6
}

struct CreateCardFlow: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var homeViewModel: HomeViewModel
    var onDismissToHome: (() -> Void)? = nil
    @State private var step: CreateCardStep = .imageSource
    @State private var useAI = true
    @State private var imagePrompt = ""
    @State private var cardName = ""
    @State private var selectedCategoryId: Int? = nil
    @State private var selectedCategoryName: String = ""
    @State private var selectedStyle = "cartoon"
    @State private var generatedImageBase64: String? = nil
    @State private var generatedTranslatedWord: String = ""
    @State private var generatedCardId: Int? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var availableCategories: [Category] = []
    @State private var showCamera = false
    @State private var showLibrary = false

    // Прогресс: 5 реальных шага (success не считается)
    private var progress: Double {
        Double(step.rawValue) / 5.0
    }

    private func generateImage() async -> Bool {
        guard !imagePrompt.isEmpty else { return false }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response = try await ImageGenService.shared.generateImage(
                word: imagePrompt,
                language: "ru", // TODO: взять из настроек пользователя
                categoryId: nil,
                style: selectedStyle
            )
            generatedImageBase64 = response.imageBase64
            generatedTranslatedWord = response.translatedWord
            generatedCardId = response.id
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "EAF4FB").ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar ──
                if step != .success {
                    CreateFlowTopBar(
                        stepLabel: stepLabel,
                        progress: min(progress, 1.0),
                        accentColor: Color(hex: "F87171"),
                        onBack: goBack,
                        onClose: {
                            deleteGeneratedCardIfNeeded()
                            dismiss()
                        }
                    )
                }

                // ── Контент ──
                switch step {
                case .imageSource:
                    CardImageSourceStep(
                        useAI: $useAI,
                        onAI: { step = .describeImage },
                        onCamera: { showCamera = true },
                        onLibrary: { showLibrary = true }
                    )
                case .describeImage:
                    CardDescribeStep(
                        prompt: $imagePrompt,
                        selectedStyle: $selectedStyle,
                        isLoading: $isLoading,
                        errorMessage: $errorMessage,
                        generateAction: generateImage,
                        onSuccess: { step = .previewImage }
                    )
                case .previewImage:
                    CardPreviewStep(imageBase64: generatedImageBase64, onSave: {
                        step = .nameCard
                    }, onRegenerate: {
                        step = .describeImage
                    })
                case .nameCard:
                    CardNameStep(name: $cardName, imageBase64: generatedImageBase64) {
                        step = .saveCard
                    }
                case .saveCard:
                    CardSaveStep(
                        cardName: cardName,
                        imageBase64: generatedImageBase64,
                        translatedWord: generatedTranslatedWord,
                        generatedCardId: generatedCardId,
                        categories: availableCategories,
                        selectedCategoryId: $selectedCategoryId,
                        selectedCategoryName: $selectedCategoryName
                    ) {
                        step = .success
                    }
                case .success:
                    CardSuccessScreen(cardName: cardName, categoryName: selectedCategoryName, imageBase64: generatedImageBase64) {
                        step = .imageSource
                        imagePrompt = ""
                        cardName = ""
                        selectedCategoryId = nil
                        selectedCategoryName = ""
                    } onGoToBoard: {
                        onDismissToHome?() ?? dismiss()
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showCamera) {
            PhotoPickerView(sourceType: .camera) { img in
                let base64 = img.jpegData(compressionQuality: 0.8).map { $0.base64EncodedString() } ?? ""
                generatedImageBase64 = base64
                step = .nameCard
            }
        }
        .sheet(isPresented: $showLibrary) {
            PhotoPickerView(sourceType: .photoLibrary) { img in
                let base64 = img.jpegData(compressionQuality: 0.8).map { $0.base64EncodedString() } ?? ""
                generatedImageBase64 = base64
                step = .nameCard
            }
        }
        .task {
            do {
                var loaded = try await CategoryService.shared.getCategories()
                if loaded.isEmpty {
                    let defaults: [(name: String, nameKk: String, nameEn: String, icon: String)] = [
                        ("Основы",    "Негіздер",     "Basics",   "✨"),
                        ("Еда",       "Тамақ",        "Food",     "🍎"),
                        ("Действия",  "Іс-әрекеттер", "Actions",  "🏃"),
                        ("Чувства",   "Сезімдер",     "Feelings", "💛"),
                        ("Люди",      "Адамдар",      "People",   "👨‍👩‍👧"),
                        ("Места",     "Орындар",      "Places",   "🏠"),
                    ]
                    for cat in defaults {
                        _ = try await CategoryService.shared.createCategory(
                            name: cat.name, nameKk: cat.nameKk, nameEn: cat.nameEn, icon: cat.icon
                        )
                    }
                    loaded = try await CategoryService.shared.getCategories()
                }
                availableCategories = loaded
            } catch {
                print("[CreateCardFlow] categories error: \(error)")
            }
        }
    }

    private var stepLabel: String {
        switch step {
        case .imageSource:  return "STEP 1: GENERATE WITH AI"
        case .describeImage: return "STEP 2: CHOOSE IMAGE SOURCE"
        case .previewImage:  return "STEP 3: PREVIEW IMAGE"
        case .nameCard:     return "STEP 4: NAME YOUR CARD"
        case .saveCard:     return "STEP 5: SAVE YOUR CARD"
        case .success:      return ""
        }
    }

    private func deleteGeneratedCardIfNeeded() {
        guard let cardId = generatedCardId else { return }
        Task { try? await CardService.shared.deleteCard(id: cardId) }
        generatedCardId = nil
        generatedImageBase64 = nil
        generatedTranslatedWord = ""
    }

    private func goBack() {
        switch step {
        case .imageSource:   dismiss()
        case .describeImage: step = .imageSource
        case .previewImage:
            deleteGeneratedCardIfNeeded()
            step = .describeImage
        case .nameCard:      step = .previewImage
        case .saveCard:      step = .nameCard
        case .success:       break
        }
    }
}

// MARK: - Step 1: Image Source

private struct CardImageSourceStep: View {
    @Binding var useAI: Bool
    var onAI: () -> Void = {}
    var onCamera: () -> Void = {}
    var onLibrary: () -> Void = {}

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Иконка
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "D4C5F5"))
                        .frame(width: 72, height: 72)
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: "7C5CBF"))
                }
                .padding(.top, 32)

                VStack(spacing: 8) {
                    Text("Add an Image")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                    Text("Choose how to create your card image")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6B8BAE"))
                }

                // AI Magic
                ImageSourceRow(
                    icon: "wand.and.stars",
                    iconBg: Color(hex: "D4C5F5"),
                    iconFg: Color(hex: "7C5CBF"),
                    title: "AI Magic ✨",
                    subtitle: "Describe and let AI create it",
                    borderColor: Color(hex: "D4C5F5")
                ) {
                    useAI = true
                    onAI()
                }

                // Camera
                ImageSourceRow(
                    icon: "camera.fill",
                    iconBg: Color(hex: "34D399"),
                    iconFg: .white,
                    title: "Take a Photo 📷",
                    subtitle: "Use your camera",
                    borderColor: Color(hex: "C5F5D8")
                ) {
                    useAI = false
                    onCamera()
                }

                // Gallery
                ImageSourceRow(
                    icon: "photo.on.rectangle",
                    iconBg: Color(hex: "5BAECC"),
                    iconFg: .white,
                    title: "Choose from Gallery 🖼️",
                    subtitle: "Pick from your photo library",
                    borderColor: Color(hex: "C5E8F5")
                ) {
                    useAI = false
                    onLibrary()
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

private struct ImageSourceRow: View {
    let icon: String
    let iconBg: Color
    let iconFg: Color
    let title: String
    let subtitle: String
    let borderColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconBg)
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconFg)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6B8BAE"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "9BB8CC"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(borderColor, lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Step 2: Describe Image

private struct CardDescribeStep: View {
    @Binding var prompt: String
    @Binding var selectedStyle: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let generateAction: () async -> Bool
    let onSuccess: () -> Void
    
    private let styles = [
        ("cartoon", "🎨 Cartoon", "Яркие цвета, простые линии"),
        ("realistic", "📷 Realistic", "Реалистичные фото"),
        ("watercolor", "🖌️ Watercolor", "Акварельная живопись"),
        ("simple", "✨ Simple", "Простые иконки")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Иконка
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "D4C5F5"))
                            .frame(width: 72, height: 72)
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "7C5CBF"))
                    }
                    .padding(.top, 32)

                    VStack(spacing: 8) {
                        Text("Describe your image")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Tell AI what you want to see")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }

                    // Текстовое поле
                    VStack(alignment: .trailing, spacing: 6) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                                .frame(height: 120)

                            if prompt.isEmpty {
                                Text("Enter your description...")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "9BB8CC"))
                                    .padding(14)
                            }

                            TextEditor(text: $prompt)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "1C3F6E"))
                                .padding(10)
                                .frame(height: 120)
                                .background(Color.clear)
                        }

                        Text("\(prompt.count)/150 characters")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "9BB8CC"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Сообщение об ошибке
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Color.red)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }

            // Кнопка Generate
            VStack {
                Button(action: {
                    Task {
                        let success = await generateAction()
                        if success {
                            onSuccess()
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                        }
                        Text(isLoading ? "Generating..." : "Generate Image")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "5BAECC"))
                    )
                }
                .disabled(prompt.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                .opacity((prompt.trimmingCharacters(in: .whitespaces).isEmpty || isLoading) ? 0.5 : 1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Step 3: Preview Image

private struct CardPreviewStep: View {
    let imageBase64: String?
    let onSave: () -> Void
    let onRegenerate: () -> Void
    
    private var uiImage: UIImage? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Иконка
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "D4C5F5"))
                            .frame(width: 72, height: 72)
                        Image(systemName: "photo.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "7C5CBF"))
                    }
                    .padding(.top, 32)
                    
                    VStack(spacing: 8) {
                        Text("Превью изображения")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Нравится сгенерированное изображение?")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                    
                    // Превью изображения
                    if let uiImage = uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(20)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "C5D8F5"))
                            .frame(width: 200, height: 200)
                            .overlay(
                                Text("No image")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    // Кнопки
                    VStack(spacing: 12) {
                        Button(action: onSave) {
                            Text("Сохранить и продолжить")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color(hex: "6DBF82"))
                                )
                        }
                        
                        Button(action: onRegenerate) {
                            Text("Сгенерировать заново")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(hex: "F87171"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color(hex: "F87171"), lineWidth: 2)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Step 4: Name Card

private struct CardNameStep: View {
    @Binding var name: String
    let imageBase64: String?
    let onContinue: () -> Void

    private var uiImage: UIImage? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Превью сгенерированного изображения
                    Group {
                        if let uiImage = uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .cornerRadius(20)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "C5D8F5"))
                                .frame(width: 120, height: 120)
                        }
                    }
                    .padding(.top, 32)

                    VStack(spacing: 8) {
                        Text("Name Your Card")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("What does this represent?")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }

                    // Поле ввода
                    VStack(alignment: .trailing, spacing: 6) {
                        TextField("Enter card name...", text: $name)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "1C3F6E"))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                            )
                        Text("\(name.count)/30 characters")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "9BB8CC"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Кнопка Continue
            Button(action: onContinue) {
                Text("Continue →")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "5BAECC"))
                    )
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Step 4: Save Card

private struct CardSaveStep: View {
    let cardName: String
    let imageBase64: String?
    let translatedWord: String
    let generatedCardId: Int?
    let categories: [Category]
    @Binding var selectedCategoryId: Int?
    @Binding var selectedCategoryName: String
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var localCategories: [Category] = []
    @State private var isLoadingCategories = false
    @State private var categoriesError: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showCategoryPicker = false
    let onSave: () -> Void

    private var displayCategories: [Category] {
        localCategories.isEmpty ? categories : localCategories
    }

    private var uiImage: UIImage? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Check иконка
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "6DBF82"))
                            .frame(width: 60, height: 60)
                        Image(systemName: "checkmark")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 8) {
                        Text("Ready to Save!")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Your card looks amazing")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }

                    // Превью карточки с реальным изображением
                    VStack(spacing: 8) {
                        if let uiImage = uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 130)
                                .cornerRadius(16)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "C5D8F5"))
                                .frame(width: 130, height: 130)
                        }

                        Text(cardName.isEmpty ? "music" : cardName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "1C3F6E"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            )
                    }

                    // Dropdown категории (обязательно)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Text("Select category")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "6B8BAE"))
                            Text("*")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "F87171"))
                        }

                        if isLoadingCategories {
                            HStack {
                                ProgressView().scaleEffect(0.8)
                                Text("Loading categories...")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "9BB8CC"))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                        } else if displayCategories.isEmpty {
                            VStack(spacing: 8) {
                                Text(categoriesError ?? "No categories found")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "F87171"))
                                Button("Retry") { fetchCategories() }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "5BAECC"))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "F87171"), lineWidth: 1))
                            )
                        } else {
                            Button {
                                showCategoryPicker = true
                            } label: {
                                HStack(spacing: 10) {
                                    if let selId = selectedCategoryId,
                                       let cat = displayCategories.first(where: { $0.id == selId }) {
                                        Text(cat.icon ?? "📁")
                                            .font(.system(size: 20))
                                        Text(cat.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color(hex: "1C3F6E"))
                                    } else {
                                        Image(systemName: "square.grid.2x2")
                                            .foregroundColor(Color(hex: "9BB8CC"))
                                        Text("Select category")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(hex: "9BB8CC"))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color(hex: "9BB8CC"))
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    selectedCategoryId != nil ? Color(hex: "5BAECC") : Color(hex: "D0E5F0"),
                                                    lineWidth: 1.5
                                                )
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .sheet(isPresented: $showCategoryPicker) {
                                CategoryPickerSheet(
                                    categories: displayCategories,
                                    selectedId: $selectedCategoryId,
                                    selectedName: $selectedCategoryName
                                )
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.visible)
                            }
                        }
                    }
                    
                    // Сообщение об ошибке
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(Color.red)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Save Card кнопка
            Button(action: saveCard) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isLoading ? "Saving..." : "Save Card →")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(hex: "6DBF82"))
                )
            }
            .disabled(isLoading || selectedCategoryId == nil)
            .opacity((isLoading || selectedCategoryId == nil) ? 0.5 : 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .task { fetchCategories() }
    }

    private func fetchCategories() {
        isLoadingCategories = true
        categoriesError = nil
        Task {
            do {
                var loaded = try await CategoryService.shared.getCategories()
                if loaded.isEmpty {
                    try await createDefaultCategories()
                    loaded = try await CategoryService.shared.getCategories()
                }
                localCategories = loaded
                isLoadingCategories = false
            } catch {
                categoriesError = error.localizedDescription
                isLoadingCategories = false
                print("[CardSaveStep] categories error: \(error)")
            }
        }
    }

    private func createDefaultCategories() async throws {
        let defaults: [(name: String, nameKk: String, nameEn: String, icon: String)] = [
            ("Основы",    "Негіздер",     "Basics",   "✨"),
            ("Еда",       "Тамақ",        "Food",     "🍎"),
            ("Действия",  "Іс-әрекеттер", "Actions",  "🏃"),
            ("Чувства",   "Сезімдер",     "Feelings", "💛"),
            ("Люди",      "Адамдар",      "People",   "👨‍👩‍👧"),
            ("Места",     "Орындар",      "Places",   "🏠"),
        ]
        for cat in defaults {
            _ = try await CategoryService.shared.createCategory(
                name: cat.name,
                nameKk: cat.nameKk,
                nameEn: cat.nameEn,
                icon: cat.icon
            )
        }
    }

    private func saveCard() {
        guard !cardName.isEmpty, let imgBase64 = imageBase64, let categoryId = selectedCategoryId else {
            if selectedCategoryId == nil { errorMessage = "Please select a category" }
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let cardService = CardService.shared
                if let existingId = generatedCardId {
                    // Карточка уже сохранена бэкендом — обновляем слово и категорию
                    _ = try await cardService.updateCard(id: existingId, word: cardName, categoryId: categoryId)
                } else {
                    // Загрузка из галереи — сохраняем через /cards/save
                    let language = detectCardLanguage(cardName)
                    _ = try await cardService.saveCard(
                        word: cardName,
                        language: language,
                        translatedWord: translatedWord.isEmpty ? cardName : translatedWord,
                        imageBase64: imgBase64,
                        categoryId: categoryId
                    )
                }
                await homeViewModel.loadRecentCards()
                await homeViewModel.loadCategories()
                if let category = homeViewModel.selectedCategory {
                    await homeViewModel.loadCards(for: category)
                }
                isLoading = false
                onSave()
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func detectCardLanguage(_ text: String) -> String {
        let kazakhSpecific = CharacterSet(charactersIn: "әғқңөұүһӘҒҚҢӨҰҮҺ")
        for scalar in text.unicodeScalars {
            if kazakhSpecific.contains(scalar) { return "kk" }
        }
        for scalar in text.unicodeScalars {
            let v = scalar.value
            if v >= 0x0400 && v <= 0x04FF { return "ru" }
        }
        return "ru" // backend не поддерживает "en", fallback на ru
    }
}

// MARK: - Card Success Screen

private struct CardSuccessScreen: View {
    let cardName: String
    let categoryName: String
    let imageBase64: String?
    let onCreateAnother: () -> Void
    let onGoToBoard: () -> Void

    private var uiImage: UIImage? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                // Конфетти-иконка
                ZStack {
                    Circle()
                        .fill(Color(hex: "C5F5D8"))
                        .frame(width: 90, height: 90)
                    Text("🎉")
                        .font(.system(size: 44))
                }

                VStack(spacing: 8) {
                    Text("Card saved!")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(hex: "2A7A4A"))
                    Text("Added to your library.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "3A8A52"))
                }

                // Превью сохранённой карточки
                HStack(spacing: 12) {
                    if let img = uiImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "C5D8F5"))
                            .frame(width: 56, height: 56)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(cardName.isEmpty ? "music" : cardName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Saved to: \(categoryName.isEmpty ? "General" : categoryName)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
            }

            Spacer()

            // Кнопки
            VStack(spacing: 12) {
                Button(action: onCreateAnother) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Create another card")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "6DBF82"))
                    )
                }

                Button(action: onGoToBoard) {
                    Text("Go to Board")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}


// MARK: - ═══════════════════════════════════════
// MARK:   CREATE CATEGORY FLOW
// MARK: - ═══════════════════════════════════════

enum CreateCategoryStep {
    case nameCategory
    case addCards
    case savingPreview
    case success
}

struct CreateCategoryFlow: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var homeViewModel: HomeViewModel
    var onDismissToHome: (() -> Void)? = nil
    var onViewCategory: ((Category) -> Void)? = nil
    @State private var step: CreateCategoryStep = .nameCategory
    @State private var categoryName = ""
    @State private var selectedCardIds: Set<Int> = []
    @State private var coverCardId: Int? = nil
    @State private var unassignedCards: [Card] = []
    @State private var createdCardCount = 0
    @State private var createdCategory: Category? = nil

    private var progress: Double {
        switch step {
        case .nameCategory:  return 0.33
        case .addCards:      return 0.66
        case .savingPreview: return 1.0
        case .success:       return 1.0
        }
    }

    private var stepLabel: String {
        switch step {
        case .nameCategory:  return "STEP 1: NAME CATEGORY"
        case .addCards:      return "STEP 2: ADD CARDS"
        case .savingPreview: return "STEP 3: SAVE CATEGORY"
        case .success:       return ""
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "EAF4FB").ignoresSafeArea()

            VStack(spacing: 0) {
                if step != .success {
                    CreateFlowTopBar(
                        stepLabel: stepLabel,
                        progress: progress,
                        accentColor: Color(hex: "A78BFA"),
                        onBack: goBack,
                        onClose: { dismiss() }
                    )
                }

                switch step {
                case .nameCategory:
                    CategoryNameStep(name: $categoryName) {
                        step = .addCards
                    }
                case .addCards:
                    CategoryAddCardsStep(
                        cards: unassignedCards,
                        selectedCardIds: $selectedCardIds,
                        coverCardId: $coverCardId
                    ) {
                        step = .savingPreview
                    }
                case .savingPreview:
                    CategorySaveStep(
                        categoryName: categoryName,
                        selectedCardIds: selectedCardIds,
                        coverCard: unassignedCards.first(where: { $0.id == coverCardId })
                    ) { count, category in
                        createdCardCount = count
                        createdCategory = category
                        step = .success
                    }
                case .success:
                    CategorySuccessScreen(categoryName: categoryName, cardCount: createdCardCount, coverCard: unassignedCards.first(where: { $0.id == coverCardId })) {
                        step = .nameCategory
                        categoryName = ""
                        selectedCardIds = []
                        coverCardId = nil
                        createdCardCount = 0
                        createdCategory = nil
                    } onView: {
                        if let cat = createdCategory {
                            onViewCategory?(cat) ?? onDismissToHome?() ?? dismiss()
                        } else {
                            onDismissToHome?() ?? dismiss()
                        }
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
        .task {
            do {
                unassignedCards = try await CardService.shared.getCards()
            } catch {
                // silent — user sees empty list, can still name & save category
            }
        }
    }

    private func goBack() {
        switch step {
        case .nameCategory:  dismiss()
        case .addCards:      step = .nameCategory
        case .savingPreview: step = .addCards
        case .success:       break
        }
    }
}

// MARK: - Category Step 1: Name

private struct CategoryNameStep: View {
    @Binding var name: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // T иконка
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "A78BFA"))
                            .frame(width: 72, height: 72)
                        Text("T")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 8) {
                        Text("Category Name")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Give your category a unique name")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }

                    VStack(alignment: .trailing, spacing: 6) {
                        TextField("Enter the name", text: $name)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "1C3F6E"))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                            )
                        Text("\(name.count)/20 characters")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "9BB8CC"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Button(action: onContinue) {
                Text("Continue →")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "A78BFA"))
                    )
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Category Step 2: Add Cards

private struct CategoryAddCardsStep: View {
    let cards: [Card]
    @Binding var selectedCardIds: Set<Int>
    @Binding var coverCardId: Int?
    let onNext: () -> Void

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your cards")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Select cards to add. Long press to set as cover.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                    .padding(.top, 20)

                    if cards.isEmpty {
                        Text("No cards yet")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "9BB8CC"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    } else {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(cards) { card in
                                RealSelectableCardView(
                                    card: card,
                                    isSelected: selectedCardIds.contains(card.id),
                                    isCover: coverCardId == card.id
                                ) {
                                    if selectedCardIds.contains(card.id) {
                                        selectedCardIds.remove(card.id)
                                        if coverCardId == card.id { coverCardId = nil }
                                    } else {
                                        selectedCardIds.insert(card.id)
                                    }
                                } onLongPress: {
                                    selectedCardIds.insert(card.id)
                                    coverCardId = card.id
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Button(action: onNext) {
                Text(selectedCardIds.isEmpty ? "Skip →" : "Add \(selectedCardIds.count) Cards →")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "A78BFA"))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

private struct RealSelectableCardView: View {
    let card: Card
    let isSelected: Bool
    let isCover: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    @State private var uiImage: UIImage? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                if let img = uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 54)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.horizontal, 6)
                        .padding(.top, 6)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "C5D8F5"))
                        .frame(height: 54)
                        .padding(.horizontal, 6)
                        .padding(.top, 6)
                }
                Text(card.word)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "2C3E50"))
                    .lineLimit(1)
                    .padding(.bottom, 6)
            }
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isCover ? Color(hex: "F5A623") : (isSelected ? Color(hex: "A78BFA") : Color.clear),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            )

            if isCover {
                ZStack {
                    Circle().fill(Color(hex: "F5A623")).frame(width: 22, height: 22)
                    Image(systemName: "star.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: -4)
            } else if isSelected {
                ZStack {
                    Circle().fill(Color(hex: "A78BFA")).frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: -4)
            }
        }
        .onTapGesture { onTap() }
        .onLongPressGesture { onLongPress() }
        .task(id: card.id) {
            guard uiImage == nil else { return }
            let base64 = card.imageBase64
            let img = await Task.detached(priority: .userInitiated) {
                guard let data = Data(base64Encoded: base64) else { return UIImage?.none }
                return UIImage(data: data)
            }.value
            uiImage = img
        }
    }
}

// MARK: - Category Save Step

private struct CategorySaveStep: View {
    let categoryName: String
    let selectedCardIds: Set<Int>
    let coverCard: Card?
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var isLoading = false
    @State private var errorMessage: String?
    let onSave: (Int, Category) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "6DBF82"))
                            .frame(width: 60, height: 60)
                        Image(systemName: "checkmark")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 8) {
                        Text("Almost Done!")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Your category looks perfect")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }

                    // Превью категории с обложкой
                    ZStack(alignment: .bottom) {
                        if let img = coverCard?.image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(18)
                                .padding(.horizontal, 40)
                        } else {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(hex: "C5E8F5"))
                                .frame(height: 120)
                                .padding(.horizontal, 40)
                        }
                        Text(categoryName.isEmpty ? "New Category" : categoryName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(coverCard?.image != nil ? Color.white : Color(hex: "1C3F6E"))
                            .padding(.horizontal, 12)
                            .padding(.bottom, 10)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 1)
                    }

                    if !selectedCardIds.isEmpty {
                        Text("\(selectedCardIds.count) card\(selectedCardIds.count == 1 ? "" : "s") will be added")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(Color.red)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Button(action: createCategory) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isLoading ? "Creating..." : "Create Category")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "6DBF82")))
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.7 : 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }

    private func createCategory() {
        guard !categoryName.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                var category = try await CategoryService.shared.createCategory(
                    name: categoryName, nameKk: nil, nameEn: nil, icon: nil
                )
                // Загружаем обложку если выбрана
                if let coverBase64 = coverCard?.imageBase64, !coverBase64.isEmpty {
                    if let updated = try? await CategoryService.shared.uploadCover(categoryId: category.id, imageBase64: coverBase64) {
                        category = updated
                    }
                }
                // Назначаем выбранные карточки в новую категорию
                for cardId in selectedCardIds {
                    _ = try? await CardService.shared.updateCard(id: cardId, categoryId: category.id)
                }
                await homeViewModel.refreshCategories()
                isLoading = false
                onSave(selectedCardIds.count, category)
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - Category Success

private struct CategorySuccessScreen: View {
    let categoryName: String
    let cardCount: Int
    let coverCard: Card?
    let onCreateAnother: () -> Void
    let onView: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "C5F5D8"))
                        .frame(width: 90, height: 90)
                    Text("🎉")
                        .font(.system(size: 44))
                }

                VStack(spacing: 8) {
                    Text("Category created!")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(hex: "2A7A4A"))
                    Text("Your new category is ready.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "3A8A52"))
                }

                HStack(spacing: 12) {
                    if let img = coverCard?.image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "C5D8F5"))
                            .frame(width: 52, height: 52)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(categoryName.isEmpty ? "music" : categoryName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("\(cardCount) card\(cardCount == 1 ? "" : "s")")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onCreateAnother) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus").font(.system(size: 14, weight: .bold))
                        Text("Create another category")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "6DBF82")))
                }

                Button(action: onView) {
                    Text("View Category")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}


// MARK: - ═══════════════════════════════════════
// MARK:   SHARED COMPONENTS
// MARK: - ═══════════════════════════════════════

struct CreateFlowTopBar: View {
    let stepLabel: String
    let progress: Double
    let accentColor: Color
    let onBack: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 34, height: 34)
                            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                    }
                }

                Spacer()

                Text(stepLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(accentColor)
                    .tracking(0.5)

                Spacer()

                Button(action: onClose) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 34, height: 34)
                            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: "E5EEF5"))
                        .frame(height: 3)
                    Rectangle()
                        .fill(accentColor)
                        .frame(width: geo.size.width * progress, height: 3)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 3)
        }
    }
}

// MARK: - Style Chip

private struct StyleChip: View {
    let title: String
    let description: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "7C5CBF") : Color(hex: "1C3F6E"))
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? Color(hex: "9B7CE0") : Color(hex: "6B8BAE"))
                    .lineLimit(2)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color(hex: "F0E8FF") : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color(hex: "7C5CBF") : Color(hex: "D0E5F0"), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Camera Card Flow

struct CameraCardFlow: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var homeViewModel: HomeViewModel
    var onDismissToHome: (() -> Void)? = nil

    @State private var step: CameraStep = .pickSource
    @State private var capturedImage: UIImage? = nil
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var cardWord = ""
    @State private var selectedCategoryId: Int? = nil
    @State private var categories: [Category] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showCategoryPicker = false

    enum CameraStep { case pickSource, nameCard, done }

    var body: some View {
        ZStack {
            Color(hex: "EAF4FB").ignoresSafeArea()
            switch step {
            case .pickSource:
                sourcePickerStep
            case .nameCard:
                nameCardStep
            case .done:
                EmptyView()
            }
        }
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showCamera) {
            PhotoPickerView(sourceType: .camera) { img in
                capturedImage = img
                step = .nameCard
            }
        }
        .sheet(isPresented: $showLibrary) {
            PhotoPickerView(sourceType: .photoLibrary) { img in
                capturedImage = img
                step = .nameCard
            }
        }
        .task { categories = (try? await CategoryService.shared.getCategories()) ?? [] }
    }

    // MARK: Step 1 — выбор источника

    private var sourcePickerStep: some View {
        VStack(spacing: 32) {
            Text("Add Photo Card")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "1C3F6E"))
                .padding(.top, 32)

            VStack(spacing: 16) {
                Button { showCamera = true } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Circle().fill(Color(hex: "34D399")))
                        Text("Take a photo")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Spacer()
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2))
                }
                .buttonStyle(PlainButtonStyle())

                Button { showLibrary = true } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Circle().fill(Color(hex: "5BAECC")))
                        Text("Choose from library")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Spacer()
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)

            Spacer()

            Button("Cancel") { dismiss() }
                .foregroundColor(Color(hex: "9BB8CC"))
                .padding(.bottom, 32)
        }
    }

    // MARK: Step 2 — название + категория

    private var nameCardStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Превью фото
                if let img = capturedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(18)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                }

                // Поле названия
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card name")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "6B8BAE"))
                    TextField("e.g. Apple, Dog, Happy...", text: $cardWord)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                }
                .padding(.horizontal, 20)

                // Категория
                if !categories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "6B8BAE"))
                        Button {
                            showCategoryPicker = true
                        } label: {
                            HStack(spacing: 10) {
                                if let selId = selectedCategoryId,
                                   let cat = categories.first(where: { $0.id == selId }) {
                                    Text(cat.icon ?? "📁").font(.system(size: 20))
                                    Text(cat.name)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color(hex: "1C3F6E"))
                                } else {
                                    Image(systemName: "square.grid.2x2")
                                        .foregroundColor(Color(hex: "9BB8CC"))
                                    Text("Select category")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(hex: "9BB8CC"))
                                }
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "9BB8CC"))
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                selectedCategoryId != nil ? Color(hex: "5BAECC") : Color(hex: "D0E5F0"),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $showCategoryPicker) {
                            CategoryPickerSheet(
                                categories: categories,
                                selectedId: $selectedCategoryId,
                                selectedName: .constant("")
                            )
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                if let err = errorMessage {
                    Text(err).font(.system(size: 13)).foregroundColor(.red)
                        .padding(.horizontal, 20)
                }

                // Кнопки
                VStack(spacing: 12) {
                    Button {
                        Task { await savePhotoCard() }
                    } label: {
                        if isLoading {
                            ProgressView().tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        } else {
                            Text("Save Card")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 18)
                        .fill(cardWord.trimmingCharacters(in: .whitespaces).isEmpty || selectedCategoryId == nil
                              ? Color(hex: "9BB8CC") : Color(hex: "34D399")))
                    .disabled(cardWord.trimmingCharacters(in: .whitespaces).isEmpty || selectedCategoryId == nil || isLoading)

                    Button("Back") { step = .pickSource }
                        .foregroundColor(Color(hex: "9BB8CC"))
                        .font(.system(size: 15))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }

    private func savePhotoCard() async {
        guard let img = capturedImage,
              let base64 = img.toBase64PNG() else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let word = cardWord.trimmingCharacters(in: .whitespaces)
            let card = try await CardService.shared.saveCard(
                word: word,
                language: detectLang(word),
                translatedWord: word,
                imageBase64: base64,
                categoryId: selectedCategoryId
            )
            await homeViewModel.loadRecentCards()
            CacheService.shared.saveCards([card])
            onDismissToHome?() ?? dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func detectLang(_ text: String) -> String {
        let kk = CharacterSet(charactersIn: "әғқңөұүһӘҒҚҢӨҰҮҺ")
        for s in text.unicodeScalars { if kk.contains(s) { return "kk" } }
        for s in text.unicodeScalars { if s.value >= 0x0400 && s.value <= 0x04FF { return "ru" } }
        return "ru"
    }
}

// MARK: - Category Picker Sheet

struct CategoryPickerSheet: View {
    let categories: [Category]
    @Binding var selectedId: Int?
    @Binding var selectedName: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "EAF4FB").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(categories) { cat in
                            Button {
                                selectedId = cat.id
                                selectedName = cat.name
                                dismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "A8C8F0").opacity(0.4))
                                            .frame(width: 44, height: 44)
                                        Text(cat.icon ?? "📁")
                                            .font(.system(size: 22))
                                    }
                                    Text(cat.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "1C3F6E"))
                                    Spacer()
                                    if selectedId == cat.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(hex: "5BAECC"))
                                            .font(.system(size: 20))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedId == cat.id ? Color(hex: "EAF4FB") : Color.white)
                                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "5BAECC"))
                }
            }
        }
    }
}

#Preview {
    CardManagerView()
        .environmentObject(HomeViewModel())
}
