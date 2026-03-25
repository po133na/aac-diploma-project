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
    @State private var showCreateCard     = false
    @State private var showCreateCategory = false

    // Мок карточки — заменить на реальные данные
    let recentCards: [(word: String, color: Color)] = [
        ("Eat",    Color(hex: "D4C5F5")),
        ("Listen", Color(hex: "C5F5D8")),
        ("You",    Color(hex: "C5E8F5")),
        ("Eat",    Color(hex: "F5C5D8")),
        ("Listen", Color(hex: "C5F5D8")),
        ("You",    Color(hex: "D4C5F5")),
    ]

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
                            Text("\(recentCards.count) cards total")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "6B8BAE"))
                        }
                        Spacer()
                        // Балансирующий элемент
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
                        Button("View All >") { /* TODO */ }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "F87171"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // Грид карточек
                    let columns = [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                    ]
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(recentCards.indices, id: \.self) { i in
                            MiniCardView(
                                word: recentCards[i].word,
                                color: recentCards[i].color
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

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
        .sheet(isPresented: $showCreateCard) {
            CreateCardFlow()
        }
        .sheet(isPresented: $showCreateCategory) {
            CreateCategoryFlow()
        }
    }
}

// MARK: - Mini Card View

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
    @State private var step: CreateCardStep = .imageSource
    @State private var useAI = true
    @State private var imagePrompt = ""
    @State private var cardName = ""
    @State private var selectedCategory = ""
    @State private var generatedImageBase64: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

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
                categoryId: nil
            )
            generatedImageBase64 = response.image_base64
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
                        onClose: { dismiss() }
                    )
                }

                // ── Контент ──
                switch step {
                case .imageSource:
                    CardImageSourceStep(useAI: $useAI) {
                        step = .describeImage
                    }
                case .describeImage:
                    CardDescribeStep(
                        prompt: $imagePrompt,
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
                    CardNameStep(name: $cardName) {
                        step = .saveCard
                    }
                case .saveCard:
                    CardSaveStep(
                        cardName: cardName,
                        selectedCategory: $selectedCategory
                    ) {
                        step = .success
                    }
                case .success:
                    CardSuccessScreen(cardName: cardName) {
                        // Create another
                        step = .imageSource
                        imagePrompt = ""
                        cardName = ""
                    } onGoToBoard: {
                        dismiss()
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
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

    private func goBack() {
        switch step {
        case .imageSource:   dismiss()
        case .describeImage: step = .imageSource
        case .previewImage:  step = .describeImage
        case .nameCard:      step = .previewImage
        case .saveCard:      step = .nameCard
        case .success:       break
        }
    }
}

// MARK: - Step 1: Image Source

private struct CardImageSourceStep: View {
    @Binding var useAI: Bool
    let onNext: () -> Void

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
                    onNext()
                }

                // Camera / Gallery
                ImageSourceRow(
                    icon: "camera.fill",
                    iconBg: Color(hex: "5BAECC"),
                    iconFg: .white,
                    title: "Camera / Gallery 📷",
                    subtitle: "Take a photo or choose existing",
                    borderColor: Color(hex: "C5E8F5")
                ) {
                    useAI = false
                    onNext()
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
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let generateAction: () async -> Bool
    let onSuccess: () -> Void

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
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Превью изображения (заглушка)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "C5D8F5"))
                        .frame(width: 120, height: 120)
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
    @Binding var selectedCategory: String
    let onSave: () -> Void

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

                    // Превью карточки
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "C5D8F5"))
                            .frame(width: 130, height: 130)

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

                    // Dropdown категории
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add to category (optional)")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B8BAE"))

                        HStack {
                            Text(selectedCategory.isEmpty ? "" : selectedCategory)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "1C3F6E"))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color(hex: "9BB8CC"))
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(hex: "D0E5F0"), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Save Card кнопка
            Button(action: onSave) {
                Text("Save Card →")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "6DBF82"))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Card Success Screen

private struct CardSuccessScreen: View {
    let cardName: String
    let onCreateAnother: () -> Void
    let onGoToBoard: () -> Void

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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "C5D8F5"))
                        .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(cardName.isEmpty ? "music" : cardName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Saved to: General")
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
    @State private var step: CreateCategoryStep = .nameCategory
    @State private var categoryName = ""
    @State private var selectedCardIds: Set<UUID> = []

    private let mockCards: [(word: String, color: Color)] = [
        ("Eat",    Color(hex: "D4C5F5")),
        ("Listen", Color(hex: "C5F5D8")),
        ("You",    Color(hex: "C5E8F5")),
        ("Eat",    Color(hex: "F5C5D8")),
        ("Listen", Color(hex: "C5F5D8")),
        ("You",    Color(hex: "D4C5F5")),
    ]

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
        case .addCards:      return "STEP 3: ADD CARDS (OPTIONAL)"
        case .savingPreview: return "STEP 1: SAVE CATEGORY"
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
                        cards: mockCards,
                        selectedCount: selectedCardIds.count
                    ) {
                        step = .savingPreview
                    }
                case .savingPreview:
                    CategorySaveStep(categoryName: categoryName) {
                        step = .success
                    }
                case .success:
                    CategorySuccessScreen(categoryName: categoryName) {
                        step = .nameCategory
                        categoryName = ""
                        selectedCardIds = []
                    } onView: {
                        dismiss()
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
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
    let cards: [(word: String, color: Color)]
    let selectedCount: Int
    let onNext: () -> Void

    @State private var selected: Set<Int> = []

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
                        Text("Unassigned cards")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Give your category a unique name")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                    .padding(.top, 20)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(cards.indices, id: \.self) { i in
                            SelectableCardView(
                                word: cards[i].word,
                                color: cards[i].color,
                                isSelected: selected.contains(i)
                            ) {
                                if selected.contains(i) {
                                    selected.remove(i)
                                } else {
                                    selected.insert(i)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Button(action: onNext) {
                Text(selected.isEmpty ? "Skip →" : "Add \(selected.count) Cards →")
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

private struct SelectableCardView: View {
    let word: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? Color(hex: "A78BFA") : Color.clear,
                                    lineWidth: 2
                                )
                        )
                )

                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "A78BFA"))
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Save Step

private struct CategorySaveStep: View {
    let categoryName: String
    let onSave: () -> Void

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

                    // Превью категории
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(hex: "C5E8F5"))
                        .frame(height: 100)
                        .overlay(
                            Text("Yes")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "1C3F6E"))
                                .padding(.bottom, 8),
                            alignment: .bottom
                        )
                        .padding(.horizontal, 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Button(action: onSave) {
                Text("Create Category")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "6DBF82"))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Category Success

private struct CategorySuccessScreen: View {
    let categoryName: String
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
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "C5D8F5"))
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(categoryName.isEmpty ? "music" : categoryName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("2 cards")
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

#Preview {
    CardManagerView()
}
