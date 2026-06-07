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
    @EnvironmentObject var localization: LocalizationManager
    @State private var showCreateCard     = false
    @State private var showCreateCategory = false
    var onDismissToHome: (() -> Void)? = nil
    var onViewCategory: ((Category) -> Void)? = nil

    var body: some View {
        ZStack {
            Color("AppBg").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Хедер ──
                    HStack {
                        Button { dismiss() } label: {
                            ZStack {
                                Circle()
                                    .fill(Color("AppSurface"))
                                    .frame(width: 36, height: 36)
                                    .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color("AppTextPrimary"))
                            }
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text(localization.cardManager)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color("AppTextPrimary"))
                            Text(localization.cardManager)
                                .font(.system(size: 12))
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                        Spacer()
                        Circle().fill(Color.clear).frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                    // ── Create New Card ──
                    Button { showCreateCard = true } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color("AppSurface"))
                                    .frame(width: 52, height: 52)
                                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "F5A623"))
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(localization.createNewCard)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Color("AppTextPrimary"))
                                Text(localization.addCustomCardSubtitle)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("AppTextSecondary"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color("AppTextHint"))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("AppSurface"))
                                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)

                    // ── Create New Category ──
                    Button { showCreateCategory = true } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "paintpalette.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "A78BFA"))
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(localization.createNewCategory)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Color("AppCategoryCardText"))
                                Text(localization.createNewCategorySubtitle)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("AppCategoryCardSubtext"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color("AppCategoryCardChevron"))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("AppCategoryCardBg"))
                                .shadow(color: Color(hex: "A78BFA").opacity(0.2), radius: 12, x: 0, y: 4)
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
    @ObservedObject private var l = LocalizationManager.shared

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
                        .fill(Color("AppPlaceholderBg"))
                        .frame(height: 56)
                        .padding(.horizontal, 6)
                        .padding(.top, 6)
                }
                Text(card.localizedWord(language: LocalizationManager.shared.currentLanguage))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color("AppTextDark"))
                    .lineLimit(1)
                    .padding(.bottom, 6)
            }
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("AppBg"))
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
                    .foregroundColor(Color("AppTextDark"))
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

private final class CreateCardCancellationToken: ObservableObject {
    var isCancelled = false
}

struct CreateCardFlow: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var homeViewModel: HomeViewModel
    var onDismissToHome: (() -> Void)? = nil
    @StateObject private var cancellationToken = CreateCardCancellationToken()
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
    @ObservedObject private var l = LocalizationManager.shared

    private var progress: Double {
        if useAI {
            return Double(step.rawValue) / 5.0
        } else {
            switch step {
            case .imageSource: return 1.0 / 3.0
            case .nameCard:    return 2.0 / 3.0
            case .saveCard:    return 1.0
            default:           return 0.0
            }
        }
    }

    private func detectPromptLanguage(_ text: String) -> String {
        let kazakhSpecific = CharacterSet(charactersIn: "әғқңөұүһӘҒҚҢӨҰҮҺ")
        for scalar in text.unicodeScalars {
            if kazakhSpecific.contains(scalar) { return "kk" }
        }
        for scalar in text.unicodeScalars {
            let v = scalar.value
            if v >= 0x0400 && v <= 0x04FF { return "ru" }
        }
        return "en"
    }

    private func generateImage() async -> Bool {
        guard !imagePrompt.isEmpty else { return false }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let word = imagePrompt
        let language = detectPromptLanguage(imagePrompt)
        let style = selectedStyle
        cancellationToken.isCancelled = false  // сбрасываем флаг для новой попытки
        let token = cancellationToken

        do {
            let response = try await Task.detached(priority: .userInitiated) {
                try await ImageGenService.shared.generateImage(
                    word: word,
                    language: language,
                    categoryId: nil,
                    style: style
                )
            }.value

            // Если юзер закрыл flow пока шла генерация — удаляем созданную карточку
            if token.isCancelled {
                Task { try? await CardService.shared.deleteCard(id: response.id) }
                return false  // предотвращает вызов onSuccess() на закрытом sheet
            }

            generatedImageBase64 = response.imageBase64
            generatedTranslatedWord = response.translatedWord
            generatedCardId = response.id
            return true
        } catch {
            print("[generateImage] error: \(error)")
            errorMessage = error.localizedDescription
            return false
        }
    }

    var body: some View {
        ZStack {
            Color("AppBg").ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar ──
                if step != .success {
                    CreateFlowTopBar(
                        stepLabel: stepLabel,
                        progress: min(progress, 1.0),
                        accentColor: Color(hex: "1B3F6E"),
                        onBack: goBack,
                        onClose: {
                            cancellationToken.isCancelled = true
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
                        deleteGeneratedCardIfNeeded()
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
                availableCategories = try await CategoryService.shared.getCategories()
            } catch {
                print("[CreateCardFlow] categories error: \(error)")
            }
        }
    }

    private var stepLabel: String {
        if useAI {
            switch step {
            case .imageSource:   return l.step1Label
            case .describeImage: return l.step2Label
            case .previewImage:  return l.step3Label
            case .nameCard:      return l.step4Label
            case .saveCard:      return l.step5Label
            case .success:       return ""
            }
        } else {
            switch step {
            case .imageSource:   return l.step1Label
            case .nameCard:      return l.step1PhotoLabel
            case .saveCard:      return l.step2PhotoLabel
            default:             return ""
            }
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
        case .describeImage:
            cancellationToken.isCancelled = true
            step = .imageSource
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
    @ObservedObject private var l = LocalizationManager.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Иконка
                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(hex: "C4B5FD"))
                                        .frame(width: 72, height: 72)
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                .padding(.top, 32)

                VStack(spacing: 8) {
                    Text(l.addAnImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("AppTextPrimary"))
                    Text(l.chooseHowToCreate)
                        .font(.system(size: 14))
                        .foregroundColor(Color("AppTextSecondary"))
                }

                // AI Magic
                ImageSourceRow(
                    icon: "wand.and.stars",
                    iconBg: Color(hex: "A78BFA"),
                    iconFg: .white,
                    title: l.aiMagic,
                    subtitle: l.describeAndAI,
                    borderColor: Color("AppAIRowBorder"),
                    rowBg: Color("AppAIRowBg")
                ) {
                    useAI = true
                    onAI()
                }

                // Camera
                ImageSourceRow(
                    icon: "camera.fill",
                    iconBg: Color(hex: "2B9BAF"),
                    iconFg: .white,
                    title: l.takeAPhotoCam,
                    subtitle: l.useYourCamera,
                    borderColor: Color("AppPhotoRowBorder"),
                    rowBg: Color("AppPhotoRowBg")
                ) {
                    useAI = false
                    onCamera()
                }

                // Gallery
                ImageSourceRow(
                    icon: "photo.on.rectangle",
                    iconBg: Color(hex: "2B9BAF"),
                    iconFg: .white,
                    title: l.chooseGalleryEmoji,
                    subtitle: l.pickFromLibrary,
                    borderColor: Color("AppPhotoRowBorder"),
                    rowBg: Color("AppPhotoRowBg")
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
    let rowBg: Color
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
                        .foregroundColor(Color("AppTextPrimary"))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("AppTextHint"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(rowBg)  // ← было Color("AppSurface"), должно быть rowBg
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
    @ObservedObject private var l = LocalizationManager.shared
    
    private let styles = [
        ("cartoon", "🎨 Cartoon", "Яркие цвета, простые линии"),
        ("realistic", "📷 Realistic", "Реалистичные фото"),
        ("watercolor", "🖌️ Watercolor", "Акварельная живопись"),
        ("simple", "✨ Simple", "Простые иконки")
    ]

    var body: some View {
        return VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Иконка
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("AppTintPurple"))
                            .frame(width: 72, height: 72)
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "7C5CBF"))
                    }
                    .padding(.top, 32)

                    VStack(spacing: 8) {
                        Text(l.describeYourImage)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text(l.tellAIWhatYouWant)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextSecondary"))
                    }

                    // Текстовое поле
                    VStack(alignment: .trailing, spacing: 6) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color("AppSurface"))
                                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                                .frame(height: 120)

                            if prompt.isEmpty {
                                Text(l.enterDescription)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("AppTextHint"))
                                    .padding(14)
                            }

                            TextEditor(text: $prompt)
                                .font(.system(size: 15))
                                .foregroundColor(Color("AppTextPrimary"))
                                .padding(10)
                                .frame(height: 120)
                                .background(Color.clear)
                                .onChange(of: prompt) { _, new in
                                    if new.count > 150 {
                                        prompt = String(new.prefix(150))
                                    }
                                }
                        }

                        Text("\(prompt.count)/150 \(l.characters)")
                            .font(.system(size: 11))
                            .foregroundColor(Color("AppTextHint"))

                        
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Сообщение об ошибке или статус загрузки
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Color.red)
                    .multilineTextAlignment(.center)
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
                        Text(isLoading ? l.generating : l.generateImage)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "29B6F6"))
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
    @ObservedObject private var l = LocalizationManager.shared

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
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 20)
//                            .fill(Color("AppTintPurple"))
//                            .frame(width: 72, height: 72)
//                        Image(systemName: "photo.fill")
//                            .font(.system(size: 30))
//                            .foregroundColor(Color(hex: "7C5CBF"))
//                    }

                    VStack(spacing: 8) {
                        Text(l.imagePreview)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text(l.doYouLikeImage)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                    .padding(.top, 32)


                    // Превью изображения
                    Group {
                        if let uiImage = uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .cornerRadius(20)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("AppPlaceholderBg"))
                                .frame(width: 200, height: 200)
                                .overlay(ProgressView())
                        }
                    }

                    
                    // Кнопки
                    VStack(spacing: 12) {
                        Button(action: onSave) {
                            Text(LocalizationManager.shared.saveAndContinue)
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
                            Text(LocalizationManager.shared.regenerate)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)           // ← белый текст
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color(hex: "29B6F6")) // ← голубой, без рамки
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
//                                                .stroke(Color(hex: "F87171"), lineWidth: 2)
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
    @ObservedObject private var l = LocalizationManager.shared

    private var uiImage: UIImage? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 8) {
                        Text(l.nameYourCard)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text(l.whatDoesThisRepresent)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                    .padding(.top, 32)  // ← перенеси сюда

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
                                .fill(Color("AppPlaceholderBg"))
                                .frame(width: 120, height: 120)
                        }
                    }



                    // Поле ввода
                    VStack(alignment: .trailing, spacing: 6) {
                        TextField(l.enterCardName, text: $name)
                            .font(.system(size: 15))
                            .foregroundColor(Color("AppTextPrimary"))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("AppSurface"))
                                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                            )
                        Text("\(name.count)/30 \(l.characters)")
                            .font(.system(size: 11))
                            .foregroundColor(Color("AppTextHint"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Кнопка Continue
            Button(action: onContinue) {
                Text(LocalizationManager.shared.continueArrow)
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
    @ObservedObject private var l = LocalizationManager.shared

    private var displayCategories: [Category] {
        localCategories.isEmpty ? categories : localCategories
    }

    private var uiImage: UIImage? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        return VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Check иконка
                
                    

                    VStack(spacing: 8) {
                        Text(l.readyToSave)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text(l.yourCardLooksAmazing)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                    .padding(.top, 32)

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
                                .fill(Color("AppPlaceholderBg"))
                                .frame(width: 130, height: 130)
                        }

                        Text(cardName.isEmpty ? "music" : cardName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("AppTextPrimary"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("AppSurface"))
                                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            )
                    }

                    // Dropdown категории (обязательно)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(l.selectCategory)
                            .font(.system(size: 13))
                            .foregroundColor(Color("AppTextSecondary"))

                        if isLoadingCategories {
                            HStack {
                                ProgressView().scaleEffect(0.8)
                                Text(l.loadingCategories)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("AppTextHint"))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color("AppSurface")))
                        } else if displayCategories.isEmpty {
                            VStack(spacing: 8) {
                                Text(categoriesError ?? l.noCategoriesFound)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "F87171"))
                                Button(l.retry) { fetchCategories() }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "5BAECC"))
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("AppSurface"))
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
                                        Text(cat.localizedName(language: LocalizationManager.shared.currentLanguage))
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color("AppTextPrimary"))
                                    } else {
                                        Image(systemName: "square.grid.2x2")
                                            .foregroundColor(Color("AppTextHint"))
                                        Text(l.selectCategory)
                                            .font(.system(size: 15))
                                            .foregroundColor(Color("AppTextHint"))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color("AppTextHint"))
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color("AppSurface"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    selectedCategoryId != nil ? Color(hex: "5BAECC") : Color("AppBorderMed"),
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
                    
                    // Подсказка: если категория не выбрана
                    if selectedCategoryId == nil {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                            Text(l.noCategoryHint)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color("AppTextHint"))
                        .padding(.top, 4)
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
                    Text(isLoading ? l.saving : l.saveCardArrow)
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
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
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
                localCategories = try await CategoryService.shared.getCategories()
                isLoadingCategories = false
            } catch {
                categoriesError = error.localizedDescription
                isLoadingCategories = false
                print("[CardSaveStep] categories error: \(error)")
            }
        }
    }

    private func saveCard() {
        guard !cardName.isEmpty, let imgBase64 = imageBase64 else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Если категория не выбрана — используем "Unassigned" (Без категории)
                var categoryId = selectedCategoryId
                if categoryId == nil {
                    let allCats = localCategories.isEmpty
                        ? (try? await CategoryService.shared.getCategories()) ?? []
                        : localCategories
                    categoryId = allCats.first { cat in
                        cat.nameEn == "Unassigned" || cat.name == "Без категории"
                    }?.id
                }

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
        return "en"
    }
}

// MARK: - Card Success Screen

private struct CardSuccessScreen: View {
    let cardName: String
    let categoryName: String
    let imageBase64: String?
    let onCreateAnother: () -> Void
    let onGoToBoard: () -> Void
    @ObservedObject private var l = LocalizationManager.shared

    private var uiImage: UIImage? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
    var body: some View {
        return VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
 
                ZStack {
                      Circle()
                          .fill(Color("AppTintGreen"))
                          .frame(width: 110, height: 110)  // ← крупнее
                      Text("🎉")
                          .font(.system(size: 54))         // ← крупнее
                  }
                VStack(spacing: 8) {
                    Text(l.cardSaved)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(hex: "2A7A4A"))
                    Text(l.addedToLibrary)
                        .font(.system(size: 14))
                        .foregroundColor(Color("AppSuccessText"))
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
                            .fill(Color("AppPlaceholderBg"))
                            .frame(width: 56, height: 56)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(cardName.isEmpty ? "music" : cardName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text("\(LocalizationManager.shared.savedTo) \(categoryName.isEmpty ? LocalizationManager.shared.unassignedCategory : categoryName)")
                            .font(.system(size: 12))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("AppSurface"))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)  // ← небольшой отступ от текста

            }

            Spacer()

            // Кнопки
            VStack(spacing: 12) {
                Button(action: onCreateAnother) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text(l.createAnotherCard)
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
                    Text(l.goToBoard)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("AppSurface"))
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
    case generatingCover
    case coverPreview
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
    @State private var galleryImageBase64: String? = nil
    @State private var tempCreatedCategory: Category? = nil
    @State private var selectedCardIds: Set<Int> = []
    @State private var coverCardId: Int? = nil
    @State private var unassignedCards: [Card] = []
    @State private var createdCardCount = 0
    @State private var createdCategory: Category? = nil
    @State private var generatedCoverBase64: String? = nil
    @State private var generateTriggerCount = 0
    @ObservedObject private var l = LocalizationManager.shared

    private var progress: Double {
        switch step {
        case .nameCategory:    return 0.25
        case .generatingCover: return 0.50
        case .coverPreview:    return 0.65
        case .addCards:        return 0.80
        case .savingPreview:   return 1.0
        case .success:         return 1.0
        }
    }

    private var stepLabel: String {
        switch step {
        case .nameCategory:    return l.step1CatLabel
        case .generatingCover: return l.step2CatLabel
        case .coverPreview:    return l.step2CatLabel
        case .addCards:        return l.step3CatLabel
        case .savingPreview:   return l.step4CatLabel
        case .success:         return ""
        }
    }

    var body: some View {
        ZStack {
            Color("AppBg").ignoresSafeArea()

            VStack(spacing: 0) {
                if step != .success {
                    CreateFlowTopBar(
                        stepLabel: stepLabel,
                        progress: progress,
                        accentColor: Color(hex: "A78BFA"),
                        onBack: goBack,
                        onClose: {
                            deleteTempCategoryIfNeeded()
                            dismiss()
                        }
                    )
                }

                switch step {
                case .nameCategory:
                    CategoryNameStep(name: $categoryName) {
                        generateTriggerCount += 1
                        step = .generatingCover
                    }
                case .generatingCover:
                    CategoryGeneratingCoverStep(categoryName: categoryName)
                        .task(id: generateTriggerCount) {
                            await autoGenerateCover()
                        }
                case .coverPreview:
                    CategoryCoverPreviewStep(
                        imageBase64: generatedCoverBase64 ?? galleryImageBase64,
                        categoryName: categoryName,
                        onSave: { step = .addCards },
                        onRegenerate: {
                            galleryImageBase64 = nil
                            generatedCoverBase64 = nil
                            generateTriggerCount += 1
                            step = .generatingCover
                        },
                        onChooseGallery: { base64 in
                            galleryImageBase64 = base64
                            generatedCoverBase64 = nil
                            if let cat = tempCreatedCategory {
                                Task {
                                    if let updated = try? await CategoryService.shared.uploadCover(
                                        categoryId: cat.id, imageBase64: base64
                                    ) {
                                        tempCreatedCategory = updated
                                    }
                                }
                            }
                        }
                    )
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
                        coverCard: unassignedCards.first(where: { $0.id == coverCardId }),
                        galleryImageBase64: galleryImageBase64,
                        existingCategory: tempCreatedCategory
                    ) { count, category, coverBase64 in
                        createdCardCount = count
                        createdCategory = category
                        generatedCoverBase64 = coverBase64
                        step = .success
                    }
                case .success:
                    CategorySuccessScreen(
                        categoryName: categoryName,
                        cardCount: createdCardCount,
                        coverCard: unassignedCards.first(where: { $0.id == coverCardId }),
                        generatedCoverBase64: generatedCoverBase64
                    ) {
                        step = .nameCategory
                        categoryName = ""
                        galleryImageBase64 = nil
                        tempCreatedCategory = nil
                        selectedCardIds = []
                        coverCardId = nil
                        createdCardCount = 0
                        createdCategory = nil
                        generatedCoverBase64 = nil
                        generateTriggerCount = 0
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
                // Всегда свежие данные с API — кеш пропускаем
                let freshCategories = try await CategoryService.shared.getCategories()
                let unassignedCat = freshCategories.first { cat in
                    cat.nameEn == "Unassigned" || cat.name == "Без категории"
                }
                guard let unassignedCat else { return }
                unassignedCards = try await CardService.shared.getCards(categoryId: unassignedCat.id)
            } catch {
                // silent — user sees empty list, can still name & save category
            }
        }
    }

    private func goBack() {
        switch step {
        case .nameCategory:
            dismiss()
        case .generatingCover:
            deleteTempCategoryIfNeeded()
            step = .nameCategory
        case .coverPreview:
            galleryImageBase64 = nil
            generatedCoverBase64 = nil
            generateTriggerCount += 1
            step = .generatingCover
        case .addCards:
            step = .coverPreview
        case .savingPreview:
            step = .addCards
        case .success:
            break
        }
    }

    private func deleteTempCategoryIfNeeded() {
        guard let cat = tempCreatedCategory else { return }
        Task { try? await CategoryService.shared.deleteCategory(id: cat.id) }
        tempCreatedCategory = nil
        generatedCoverBase64 = nil
    }

    private func autoGenerateCover() async {
        do {
            if tempCreatedCategory == nil {
                let cat = try await CategoryService.shared.createCategory(
                    name: categoryName, nameKk: nil, nameEn: nil, icon: nil
                )
                tempCreatedCategory = cat
            }
            let updated = try await CategoryService.shared.generateCover(
                categoryId: tempCreatedCategory!.id, prompt: categoryName
            )
            tempCreatedCategory = updated
            generatedCoverBase64 = updated.coverImageBase64
        } catch {
            // On failure still advance so user can choose from gallery
        }
        step = .coverPreview
    }
}

// MARK: - Category Step 1: Name

private struct CategoryNameStep: View {
    @Binding var name: String
    let onContinue: () -> Void
    @ObservedObject private var l = LocalizationManager.shared

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
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
                        Text(l.categoryNameTitle)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text(l.giveUniqueName)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextSecondary"))
                    }

                    VStack(alignment: .trailing, spacing: 6) {
                        TextField(l.enterTheName, text: $name)
                            .font(.system(size: 15))
                            .foregroundColor(Color("AppTextPrimary"))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("AppSurface"))
                                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                            )
                        Text("\(name.count)/20 \(l.characters)")
                            .font(.system(size: 11))
                            .foregroundColor(Color("AppTextHint"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Button(action: onContinue) {
                Text(l.continueArrow)
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

// MARK: - Category Step 2: Generating Cover

private struct CategoryGeneratingCoverStep: View {
    let categoryName: String
    @ObservedObject private var l = LocalizationManager.shared

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color("AppTintPurple"))
                    .frame(width: 90, height: 90)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "A78BFA")))
                    .scaleEffect(1.4)
            }

            VStack(spacing: 10) {
                Text(l.generatingCoverFor)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("AppTextPrimary"))
                Text("\"\(categoryName)\"...")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "A78BFA"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Text(l.generatingWait)
                    .font(.system(size: 14))
                    .foregroundColor(Color("AppTextSecondary"))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


// MARK: - Category Cover Preview (was CategoryAICoverPreviewStep)

private struct CategoryCoverPreviewStep: View {
    let imageBase64: String?
    let categoryName: String
    let onSave: () -> Void
    let onRegenerate: () -> Void
    let onChooseGallery: (String) -> Void
    @State private var showLibrary = false
    @ObservedObject private var l = LocalizationManager.shared

    private var uiImage: UIImage? {
        guard let base64 = imageBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let img = uiImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 240, height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    } else {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color("AppPlaceholderBg"))
                            .frame(width: 240, height: 240)
                    }

                    Text(categoryName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("AppTextPrimary"))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            VStack(spacing: 12) {
                Button(action: onSave) {
                    Text(l.saveAndContinue)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "6DBF82")))
                }

                Button(action: onRegenerate) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 14, weight: .semibold))
                        Text(l.regenerate)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "A78BFA"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("AppSurface"))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "A78BFA"), lineWidth: 2))
                    )
                }

                Button { showLibrary = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 14, weight: .semibold))
                        Text(l.chooseGalleryEmoji)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "5BAECC"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("AppSurface"))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "5BAECC"), lineWidth: 2))
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showLibrary) {
            PhotoPickerView(sourceType: .photoLibrary) { img in
                let base64 = img.jpegData(compressionQuality: 0.8).map { $0.base64EncodedString() } ?? ""
                onChooseGallery(base64)
            }
        }
    }
}

// MARK: - Category Step 3: Add Cards

private struct CategoryAddCardsStep: View {
    let cards: [Card]
    @Binding var selectedCardIds: Set<Int>
    @Binding var coverCardId: Int?
    let onNext: () -> Void
    @ObservedObject private var l = LocalizationManager.shared

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        return VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(l.yourCards)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text(l.selectCardsHint)
                            .font(.system(size: 13))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                    .padding(.top, 20)

                    if cards.isEmpty {
                        Text(l.noCards)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextHint"))
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
                Text(selectedCardIds.isEmpty ? l.skipArrow : "\(l.addCards) (\(selectedCardIds.count)) →")
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
    @ObservedObject private var l = LocalizationManager.shared

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
                        .fill(Color("AppPlaceholderBg"))
                        .frame(height: 54)
                        .padding(.horizontal, 6)
                        .padding(.top, 6)
                }
                Text(card.localizedWord(language: LocalizationManager.shared.currentLanguage))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color("AppTextDark"))
                    .lineLimit(1)
                    .padding(.bottom, 6)
            }
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("AppSurface"))
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
    var galleryImageBase64: String? = nil
    var existingCategory: Category? = nil
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var generatedCoverImage: UIImage? = nil
    let onSave: (Int, Category, String?) -> Void
    @ObservedObject private var l = LocalizationManager.shared

    private var galleryThumbnail: UIImage? {
        guard let b64 = galleryImageBase64,
              let data = Data(base64Encoded: b64) else { return nil }
        return UIImage(data: data)
    }

    private var existingCoverImage: UIImage? {
        guard let b64 = existingCategory?.coverImageBase64,
              let data = Data(base64Encoded: b64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        return VStack(spacing: 0) {
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
                        Text(l.almostDone)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text(l.categoryLooksPerfect)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextSecondary"))
                    }

                    // Превью категории с обложкой
                    ZStack(alignment: .bottom) {
                        if let img = generatedCoverImage ?? existingCoverImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(18)
                                .padding(.horizontal, 40)
                        } else if let img = galleryThumbnail {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(18)
                                .padding(.horizontal, 40)
                        } else if let img = coverCard?.image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(18)
                                .padding(.horizontal, 40)
                        } else {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("AppTintPurple"))
                                .frame(height: 120)
                                .padding(.horizontal, 40)
                        }
                        Text(categoryName.isEmpty ? l.newCategory : categoryName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor((generatedCoverImage != nil || existingCoverImage != nil || galleryThumbnail != nil || coverCard?.image != nil) ? Color.white : Color("AppTextPrimary"))
                            .padding(.horizontal, 12)
                            .padding(.bottom, 10)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 1)
                    }

                    if !selectedCardIds.isEmpty {
                        Text("\(selectedCardIds.count) card\(selectedCardIds.count == 1 ? "" : "s") will be added")
                            .font(.system(size: 13))
                            .foregroundColor(Color("AppTextSecondary"))
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
                    Text(isLoading ? l.creating : l.createCategoryBtn)
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
                var category: Category
                if let existing = existingCategory {
                    // Категория уже была создана на шаге AI preview
                    category = existing
                } else {
                    category = try await CategoryService.shared.createCategory(
                        name: categoryName, nameKk: nil, nameEn: nil, icon: nil
                    )
                    // Загружаем обложку из галереи
                    if let galleryBase64 = galleryImageBase64, !galleryBase64.isEmpty {
                        if let updated = try? await CategoryService.shared.uploadCover(categoryId: category.id, imageBase64: galleryBase64) {
                            category = updated
                        }
                    // Загружаем обложку карточки-обложки
                    } else if let coverBase64 = coverCard?.imageBase64, !coverBase64.isEmpty {
                        if let updated = try? await CategoryService.shared.uploadCover(categoryId: category.id, imageBase64: coverBase64) {
                            category = updated
                        }
                    }
                }
                // Bulk переназначение выбранных карточек в новую категорию
                if !selectedCardIds.isEmpty {
                    try await CategoryService.shared.assignCards(
                        categoryId: category.id,
                        cardIds: Array(selectedCardIds)
                    )
                }
                await homeViewModel.refreshCategories()
                isLoading = false
                onSave(selectedCardIds.count, category, category.coverImageBase64)
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
    var generatedCoverBase64: String? = nil
    let onCreateAnother: () -> Void
    let onView: () -> Void
    @ObservedObject private var l = LocalizationManager.shared

    private var generatedCoverImage: UIImage? {
        guard let base64 = generatedCoverBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        return VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color("AppTintGreen"))
                        .frame(width: 90, height: 90)
                    Text("🎉")
                        .font(.system(size: 44))
                }

                VStack(spacing: 8) {
                    Text(l.categoryCreated)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(hex: "2A7A4A"))
                    Text(l.categoryReady)
                        .font(.system(size: 14))
                        .foregroundColor(Color("AppSuccessText"))
                }

                HStack(spacing: 12) {
                    if let img = coverCard?.image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if let img = generatedCoverImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("AppPlaceholderBg"))
                            .frame(width: 52, height: 52)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(categoryName.isEmpty ? "music" : categoryName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text("\(cardCount) card\(cardCount == 1 ? "" : "s")")
                            .font(.system(size: 12))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("AppSurface"))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onCreateAnother) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus").font(.system(size: 14, weight: .bold))
                        Text(l.createAnotherCategory)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "6DBF82")))
                }

                Button(action: onView) {
                    Text(l.viewCategory)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("AppSurface"))
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
                            .fill(Color("AppSurface"))
                            .frame(width: 34, height: 34)
                            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("AppTextPrimary"))
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
                            .fill(Color("AppSurface"))
                            .frame(width: 34, height: 34)
                            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color("AppTextSecondary"))
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
                        .fill(Color("AppBorderLight"))
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
                    .foregroundColor(isSelected ? Color(hex: "7C5CBF") : Color("AppTextPrimary"))
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? Color(hex: "9B7CE0") : Color("AppTextSecondary"))
                    .lineLimit(2)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color(hex: "F0E8FF") : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color(hex: "7C5CBF") : Color("AppBorderMed"), lineWidth: 1)
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
            Color("AppBg").ignoresSafeArea()
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
                .foregroundColor(Color("AppTextPrimary"))
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
                            .foregroundColor(Color("AppTextPrimary"))
                        Spacer()
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color("AppSurface"))
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
                            .foregroundColor(Color("AppTextPrimary"))
                        Spacer()
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color("AppSurface"))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)

            Spacer()

            Button(LocalizationManager.shared.cancel) { dismiss() }
                .foregroundColor(Color("AppTextHint"))
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
                    Text(LocalizationManager.shared.cardNameLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("AppTextSecondary"))
                    TextField(LocalizationManager.shared.cardExampleHint, text: $cardWord)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color("AppSurface")))
                }
                .padding(.horizontal, 20)

                // Категория
                if !categories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizationManager.shared.categoryLabel)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("AppTextSecondary"))
                        Button {
                            showCategoryPicker = true
                        } label: {
                            HStack(spacing: 10) {
                                if let selId = selectedCategoryId,
                                   let cat = categories.first(where: { $0.id == selId }) {
                                    Text(cat.icon ?? "📁").font(.system(size: 20))
                                    Text(cat.localizedName(language: LocalizationManager.shared.currentLanguage))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color("AppTextPrimary"))
                                } else {
                                    Image(systemName: "square.grid.2x2")
                                        .foregroundColor(Color("AppTextHint"))
                                    Text(LocalizationManager.shared.selectCategory)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color("AppTextHint"))
                                }
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color("AppTextHint"))
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("AppSurface"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                selectedCategoryId != nil ? Color(hex: "5BAECC") : Color("AppBorderMed"),
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
                            Text(LocalizationManager.shared.saveCard)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 18)
                        .fill(cardWord.trimmingCharacters(in: .whitespaces).isEmpty
                              ? Color("AppTextHint") : Color(hex: "34D399")))
                    .disabled(cardWord.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)

                    Button(LocalizationManager.shared.backBtn) { step = .pickSource }
                        .foregroundColor(Color("AppTextHint"))
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
            // Если категория не выбрана — используем системную "Сгенерированные"
            var categoryId = selectedCategoryId
            if categoryId == nil {
                let allCats = try await CategoryService.shared.getCategories()
                categoryId = allCats.first { cat in
                    cat.nameEn == "Unassigned" || cat.name == "Без категории"
                }?.id
            }
            let card = try await CardService.shared.saveCard(
                word: word,
                language: detectLang(word),
                translatedWord: word,
                imageBase64: base64,
                categoryId: categoryId
            )
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

    // Скрываем "Основы/Basics" и "Unassigned/Без категории" из списка
    private var visibleCategories: [Category] {
        categories.filter { cat in
            let isBasics = cat.isSystem && cat.nameEn == "Basics"
            let isUnassigned = cat.nameEn == "Unassigned" || cat.name == "Без категории"
            return !isBasics && !isUnassigned
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBg").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(visibleCategories) { cat in
                            Button {
                                selectedId = cat.id
                                selectedName = cat.localizedName(language: LocalizationManager.shared.currentLanguage)
                                dismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color("AppTintSkyBlue").opacity(0.4))
                                            .frame(width: 44, height: 44)
                                        Text(cat.icon ?? "📁")
                                            .font(.system(size: 22))
                                    }
                                    Text(cat.localizedName(language: LocalizationManager.shared.currentLanguage))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color("AppTextPrimary"))
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
                                        .fill(selectedId == cat.id ? Color("AppBg") : Color("AppSurface"))
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
            .navigationTitle(LocalizationManager.shared.selectCategory)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationManager.shared.cancel) { dismiss() }
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
