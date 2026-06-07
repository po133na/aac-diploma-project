// Features/Home/Views/HomeView.swift
import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject private var viewModel: HomeViewModel

    // ── Popup states (at HomeView level for full-screen overlay) ──
    @State private var cardForMenu: Card? = nil
    @State private var cardForPreview: Card? = nil
    @State private var isRenamingCard = false
    @State private var newCardName = ""
    @State private var showDeleteCardConfirm = false
    @State private var showDeleteCategoryConfirm = false

    var body: some View {
        ZStack {
            Color("AppBg").ignoresSafeArea()

            VStack(spacing: 0) {
                SentenceBuilderBar(viewModel: viewModel)

                if let mockCat = viewModel.selectedMockCategory {
                    MockCategoryDetailView(category: mockCat, viewModel: viewModel)
                        .transition(.move(edge: .trailing))
                } else if let category = viewModel.selectedCategory {
                    RealCategoryDetailView(
                        category: category,
                        viewModel: viewModel,
                        onCardMinusTap: { card in
                            newCardName = card.word
                            isRenamingCard = false
                            cardForMenu = card
                        },
                        onDeleteCategoryTap: {
                            showDeleteCategoryConfirm = true
                        },
                        onCardLongPress: { card in
                            cardForPreview = card
                        }
                    )
                    .transition(.move(edge: .trailing))
                } else {
                    HomeContentView(viewModel: viewModel)
                        .transition(.move(edge: .leading))
                }
            }

            // ── Card preview popup (long press) ──
            if let card = cardForPreview {
                CardPreviewPopup(card: card) {
                    cardForPreview = nil
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            // ── Card action popup ──
            if let card = cardForMenu {
                CardActionPopup(
                    card: card,
                    isRenaming: $isRenamingCard,
                    newName: $newCardName,
                    onClose: {
                        cardForMenu = nil
                        isRenamingCard = false
                    },
                    onDeleteTap: {
                        cardForMenu = nil
                        showDeleteCardConfirm = true
                    },
                    onRename: { name in
                        cardForMenu = nil
                        isRenamingCard = false
                        Task { await viewModel.updateCard(card, word: name) }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))

            }

            // ── Delete card confirmation ──
            if showDeleteCardConfirm {
                let cardWord = newCardName
                let l = LocalizationManager.shared
                DeleteConfirmModal(
                    title: "\(l.deleteCard) \"\(cardWord)?\"",
                    subtitle: l.deleteCardSubtitle,
                    buttonTitle: l.deleteCard,
                    onCancel: { showDeleteCardConfirm = false },
                    onConfirm: {
                        showDeleteCardConfirm = false
                        if let card = viewModel.cardsInCategory.first(where: { $0.word == cardWord }) {
                            viewModel.deleteCard(card)
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            // ── Delete category confirmation ──
            if showDeleteCategoryConfirm, let category = viewModel.selectedCategory {
                let l = LocalizationManager.shared
                DeleteConfirmModal(
                    title: "\(l.deleteCategoryBtn) \"\(category.localizedName(language: l.currentLanguage))?\"",
                    subtitle: l.deleteCategorySubtitle,
                    buttonTitle: l.deleteCategoryBtn,
                    onCancel: { showDeleteCategoryConfirm = false },
                    onConfirm: {
                        showDeleteCategoryConfirm = false
                        viewModel.deleteCategory(category)
                        viewModel.goBack()
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: cardForMenu?.id)
        .animation(.easeInOut(duration: 0.2), value: cardForPreview?.id)
        .animation(.easeInOut(duration: 0.2), value: showDeleteCardConfirm)
        .animation(.easeInOut(duration: 0.2), value: showDeleteCategoryConfirm)
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedCategory?.id)
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedMockCategory?.id)
        .onAppear {
            Task { await viewModel.loadInitialData() }
        }
    }
}
// MARK: - Sentence Builder Bar
struct SentenceBuilderBar: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var localization: LocalizationManager
    @FocusState private var isTyping: Bool
    @State private var showSpeakSheet = false

    private var isEmpty: Bool {
        viewModel.tokens.isEmpty &&
        viewModel.typedText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Верхняя строка ──
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "F5D6EC"))
                        .frame(width: 40, height: 40)
                    Text("💭").font(.system(size: 20))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(localization.mySentence)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(viewModel.wordCount) \(localization.words)")
                        .font(.system(size: 12))
                        .foregroundColor(Color("AppTextSecondary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: 140)
                Spacer(minLength: 4)
                Button { viewModel.clearSentence() } label: {
                    Text(localization.clear)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("AppTextHint"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Button {
                    TutorialManager.shared.advance(from: .speakButton)
                    showSpeakSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 12))
                        Text(localization.speak)
                            .font(.system(size: 13, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(isEmpty ? Color("AppTextHint") : Color(hex: "5BAECC")))
                }
                .disabled(isEmpty)
                .tutorialAnchor(.speakButton)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            .animation(.easeInOut(duration: 0.15), value: isEmpty)

            // ── Поле с токенами (FlowLayout, переносы) ──
            ScrollView(.vertical, showsIndicators: false) {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.tokens) { token in
                        WordChip(word: token.localizedWord(language: localization.currentLanguage)) {
                            viewModel.removeToken(token)
                        }
                    }
                    // Inline TextField после токенов
                    TextField(
                        isEmpty
                            ? localization.tapWordsHint
                            : localization.orTypeText,
                        text: $viewModel.typedText
                    )
                    .font(.system(size: 15))
                    .foregroundColor(Color("AppTextPrimary"))
                    .focused($isTyping)
                    .submitLabel(.done)
                    .onSubmit { isTyping = false }
                    .frame(minWidth: 140, minHeight: 32)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .frame(minHeight: 72, maxHeight: 96)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
            .contentShape(Rectangle())
            .onTapGesture { isTyping = true }
        }
        .background(Color(hex: "D6EEF8").opacity(0.55))
        .sheet(isPresented: $showSpeakSheet, onDismiss: {
            // Если модал закрыли свайпом (не кнопкой X), advance всё равно продвигает туториал
            TutorialManager.shared.advance(from: .closeButton)
        }) {
            ListenModalView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}
// MARK: - Listen Modal
struct ListenModalView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localization: LocalizationManager
    @ObservedObject private var tutorial = TutorialManager.shared

    private var showCloseHint: Bool {
        tutorial.isActive && tutorial.currentStep == .closeButton
    }

    private var allWords: [String] {
        var words = viewModel.tokens.map { $0.localizedWord(language: localization.currentLanguage) }
        let typed = viewModel.typedText.trimmingCharacters(in: .whitespaces)
        if !typed.isEmpty { words.append(typed) }
        return words
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color("AppBg").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {


                // ── Заголовок ──
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "5BAECC"))
                            .frame(width: 52, height: 52)
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localization.listen)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text(localization.yourSentence)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                // ── Белый блок с токенами ──
                if !allWords.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        FlowLayout(spacing: 8) {
                            ForEach(allWords, id: \.self) { word in
                                Text(word)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color("AppTextPrimary"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: "5BAECC").opacity(0.15))
                                    )
                            }
                        }
                        .padding(.bottom, 4)
                    }
                    .frame(maxHeight: 160)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("AppSurface"))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                }

                Spacer()

                // ── Кнопка Speak Again ──
                Button {
                    viewModel.speakSentence()
                } label: {
                    Text(localization.speakAgain)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(hex: "5BAECC"))
                        )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }

            // ── Кнопка закрытия + подсветка туториала ──
            VStack(alignment: .trailing, spacing: 6) {
                ZStack {
                    // Подсветка для туториала
                    if showCloseHint {
                        Circle()
                            .fill(Color(hex: "5BAECC").opacity(0.18))
                            .frame(width: 56, height: 56)
                    }
                    Button {
                        TutorialManager.shared.advance(from: .closeButton)
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color("AppSurface"))
                                .frame(width: 36, height: 36)
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                    }
                    // Регистрируем фрейм чтобы next() мог найти этот шаг
                    .tutorialAnchor(.closeButton)
                }

                // Подсказка-тултип под кнопкой X
                if showCloseHint {
                    Text(LocalizationManager.shared.tutorialClose)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("AppTextPrimary"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color("AppSurface"))
                                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 3)
                        )
                }
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
        }
        .onAppear { viewModel.speakSentence() }
    }
}
// MARK: - Word Chip (слово из карточки — с обводкой)

struct WordChip: View {
    let word: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(word)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("AppTextPrimary"))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .strokeBorder(Color(hex: "5BAECC"), lineWidth: 1.5)
                .background(Capsule().fill(Color("AppWordChipBg")))
        )
    }
}

// MARK: - Home Content

struct HomeContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color("AppTintYellow")).frame(width: 40, height: 40)
                        Text("✨").font(.system(size: 20))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localization.letsTitle)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))
                        Text(localization.chooseCategory)
                            .font(.system(size: 13))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 14)

                if viewModel.isLoadingCategories {
                    ProgressView().padding(.top, 40)
                } else if !viewModel.categories.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                            RealCategoryRow(
                                category: category,
                                onTap: {
                                    if category.nameEn == "Basics" {
                                        TutorialManager.shared.advance(from: .basicCategory)
                                    }
                                    viewModel.selectCategory(category)
                                },
                                onDelete: { viewModel.deleteCategory(category) }
                            )
                            .if(category.nameEn == "Basics") { $0
                                .tutorialAnchor(.basicCategory)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 36))
                            .foregroundColor(Color("AppTextHint"))
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(Color("AppTextSecondary"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button(localization.tryAgain) {
                            Task { await viewModel.loadCategories() }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color(hex: "5BAECC")))
                    }
                    .padding(.top, 40)
                } else {
                    ProgressView().padding(.top, 40)
                }

                Spacer().frame(height: 100)
            }
        }
        .refreshable {
            await viewModel.loadInitialData()
        }
    }
}

// MARK: - Real Category Row

struct RealCategoryRow: View {
    let category: Category
    let onTap: () -> Void
    var onDelete: (() -> Void)? = nil

    @ObservedObject private var l = LocalizationManager.shared

    private var displayName: String {
        category.localizedName(language: l.currentLanguage)
    }

    private var coverImage: UIImage? {
        guard let base64 = category.coverImageBase64,
              !base64.isEmpty,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("AppTintSkyBlue"))
                        .frame(width: 54, height: 54)
                    if let img = coverImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 54, height: 54)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else {
                        Text(category.icon ?? "📁")
                            .font(.system(size: 26))
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("AppTextPrimary"))
                    Text(category.isSystem ? l.systemCategory : l.myCategory)
                        .font(.system(size: 12))
                        .foregroundColor(Color("AppTextSecondary"))
                }
                Spacer()
                ZStack {
                    Circle().fill(Color("AppTintSkyBlue").opacity(0.5)).frame(width: 30, height: 30)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "5BAECC"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
// MARK: - Mock Category Row

struct MockCategoryRow: View {
    let category: WordCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(category.color)
                    .frame(width: 54, height: 54)
                VStack(alignment: .leading, spacing: 3) {
                    Text(category.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("AppTextPrimary"))
                    Text("\(category.words.count) words")
                        .font(.system(size: 12))
                        .foregroundColor(Color("AppTextSecondary"))
                    Text(category.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color("AppTextSecondary"))
                }
                Spacer()
                ZStack {
                    Circle().fill(category.color.opacity(0.5)).frame(width: 30, height: 30)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "5BAECC"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mock Category Detail

struct MockCategoryDetailView: View {
    let category: WordCategory
    @ObservedObject var viewModel: HomeViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack {
                    Button { viewModel.goBack() } label: {
                        ZStack {
                            Circle().fill(Color("AppSurface")).frame(width: 36, height: 36)
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color("AppTextPrimary"))
                        }
                    }
                    Spacer()
                    Text("✨ \(category.name)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("AppTextPrimary"))
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 36, height: 36)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(category.words) { word in
                        WordCardView(word: word) {
                            withAnimation(.spring(response: 0.3)) {
                                let card = Card(
                                    id: 0,
                                    word: word.word,
                                    language: "ru",
                                    translatedWord: word.word,
                                    imageBase64: "",
                                    isFavorite: false,
                                    usageCount: 0,
                                    categoryId: nil,
                                    userId: nil,
                                    createdAt: Date()
                                )
                                viewModel.addCard(card)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                QuickTipBanner()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Real Category Detail

struct RealCategoryDetailView: View {
    let category: Category
    @ObservedObject var viewModel: HomeViewModel
    var onCardMinusTap: ((Card) -> Void)? = nil
    var onDeleteCategoryTap: (() -> Void)? = nil
    var onCardLongPress: ((Card) -> Void)? = nil

    @State private var isEditing = false
    @State private var showAddCards = false  // ← добавить
    @ObservedObject private var l = LocalizationManager.shared
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // хедер без изменений...
                HStack {
                    Button { viewModel.goBack() } label: {
                        ZStack {
                            Circle().fill(Color("AppSurface")).frame(width: 36, height: 36)
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color("AppTextPrimary"))
                        }
                    }
                    Spacer()
                    Text("\(category.icon ?? "✨") \(category.localizedName(language: l.currentLanguage))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("AppTextPrimary"))
                    Spacer()
                    if !(category.isSystem && category.nameEn == "Basics") {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { isEditing.toggle() }
                        } label: {
                            Text(isEditing ? l.done : l.editBtn)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isEditing ? .white : Color("AppTextPrimary"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(isEditing ? Color(hex: "F87171") : Color("AppSurface"))
                                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Circle().fill(Color.clear).frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                if isEditing && category.nameEn != "Unassigned" {
                    Button { onDeleteCategoryTap?() } label: {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.3)).frame(width: 30, height: 30)
                                Image(systemName: "trash.fill").font(.system(size: 13)).foregroundColor(.white)
                            }
                            Text("\(l.deleteCategoryBtn) \"\(category.localizedName(language: l.currentLanguage))\"")
                                .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                            Spacer()
                            Image(systemName: "arrow.right").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: "F87171")))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16).padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if viewModel.isLoadingCards {
                    ProgressView().padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {

                        // ── Кнопка Add Cards (только в режиме edit, не для Unassigned) ──
                        if isEditing && category.nameEn != "Unassigned" {
                            Button { showAddCards = true } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(Color(hex: "5BAECC"))
                                    Text(l.addCards)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color(hex: "5BAECC"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .strokeBorder(
                                            Color(hex: "5BAECC"),
                                            style: StrokeStyle(lineWidth: 2, dash: [6])
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(Color("AppWordChipBg"))
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .transition(.scale.combined(with: .opacity))
                        }

                        ForEach(Array(viewModel.cardsInCategory.enumerated()), id: \.element.id) { index, card in
                            RealCardTile(
                                card: card,
                                isEditing: isEditing,
                                onTap: {
                                    if !isEditing {
                                        TutorialManager.shared.advance(from: .tapCard)
                                        withAnimation(.spring(response: 0.3)) { viewModel.addCard(card) }
                                    }
                                },
                                onMinusTap: { onCardMinusTap?(card) },
                                onLongPress: { onCardLongPress?(card) }
                            )
                            .if(index == 0) { $0.tutorialAnchor(.tapCard) }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    if !viewModel.cardsInCategory.isEmpty {
                        QuickTipBanner()
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                    } else if !isEditing {
                        VStack(spacing: 12) {
                            Image(systemName: "rectangle.stack")
                                .font(.system(size: 50))
                                .foregroundColor(Color("AppTextHint"))
                            Text(l.noCards)
                                .font(.system(size: 16))
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                        .padding(.top, 60)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isEditing)
        .sheet(isPresented: $showAddCards) {
            AddCardsToCategory(category: category, viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
// MARK: - Card Action Popup

private struct CardActionPopup: View {
    let card: Card
    @Binding var isRenaming: Bool
    @Binding var newName: String
    let onClose: () -> Void
    let onDeleteTap: () -> Void
    let onRename: (String) -> Void

    @FocusState private var nameFocused: Bool
    @State private var uiImage: UIImage? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {
                // Крестик
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        ZStack {
                            Circle()
                                .fill(Color("AppCloseButtonBg"))
                                .frame(width: 30, height: 30)
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color("AppCloseButtonIcon"))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

                if isRenaming {
                    // ── Режим переименования ──
                    VStack(spacing: 16) {
                        VStack(spacing: 6) {
                            Group {
                                if let img = uiImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "F5D6EC"))
                                }
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                            Text(card.word)
                                .font(.system(size: 13))
                                .foregroundColor(Color("AppTextSecondary"))
                        }

                        TextField("Card name...", text: $newName)
                            .font(.system(size: 16))
                            .foregroundColor(Color("AppTextPrimary"))
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("AppButtonSecondaryBg"))
                            )
                            .focused($nameFocused)
                            .onAppear { nameFocused = true }

                        Button {
                            let t = newName.trimmingCharacters(in: .whitespaces)
                            guard !t.isEmpty else { return }
                            onRename(t)
                        } label: {
                            Text("Save Card")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Capsule().fill(Color(hex: "5BAECC")))
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(newName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                } else {
                    // ── Кнопки Rename / Delete ──
                    VStack(spacing: 10) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) { isRenaming = true }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "EAF4FB"))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "pencil")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "5BAECC"))
                                }
                                Text(LocalizationManager.shared.renameCard)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color("AppTextPrimary"))
                                Spacer()
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color("AppButtonSecondaryBg")))
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: onDeleteTap) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "FEE2E2"))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "F87171"))
                                }
                                Text(LocalizationManager.shared.deleteCard)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "F87171"))
                                Spacer()
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color("AppButtonSecondaryBg")))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
            )
            .padding(.horizontal, 32)
        }
        .task {
            let base64 = card.imageBase64
            uiImage = await Task.detached(priority: .userInitiated) {
                guard let data = Data(base64Encoded: base64) else { return UIImage?.none }
                return UIImage(data: data)
            }.value
        }
    }
}

// MARK: - Card Preview Popup (long press)

private struct CardPreviewPopup: View {
    let card: Card
    let onClose: () -> Void

    @State private var uiImage: UIImage? = nil
    @State private var isSpeaking = false
    @ObservedObject private var l = LocalizationManager.shared

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 0) {
                // X кнопка
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        ZStack {
                            Circle()
                                .fill(Color("AppCloseButtonBg"))
                                .frame(width: 32, height: 32)
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("AppCloseButtonIcon"))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Картинка
                Group {
                    if let img = uiImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("AppPlaceholderBg"))
                            .frame(width: 200, height: 200)
                            .overlay(ProgressView())
                    }
                }

                // Название
                Text(card.localizedWord(language: l.currentLanguage))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Кнопка Speak
                Button {
                    isSpeaking = true
                    let uiLang = LocalizationManager.shared.currentLanguage
                    let (word, ttsLang) = card.ttsInfo(uiLanguage: uiLang)
                    Task {
                        await TTSService.shared.speakCard(id: card.id, language: ttsLang, fallbackText: word)
                        isSpeaking = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isSpeaking ? "waveform" : "speaker.wave.2.fill")
                            .font(.system(size: 16))
                        Text(l.speak)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(isSpeaking ? Color(hex: "5BAECC").opacity(0.7) : Color(hex: "5BAECC"))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
            )
            .padding(.horizontal, 20)
        }
        .task {
            let base64 = card.imageBase64
            uiImage = await Task.detached(priority: .userInitiated) {
                guard let data = Data(base64Encoded: base64) else { return UIImage?.none }
                return UIImage(data: data)
            }.value
        }
    }
}

// MARK: - Real Card Tile

struct RealCardTile: View {
    let card: Card
    var isEditing: Bool = false
    let onTap: () -> Void
    var onMinusTap: (() -> Void)? = nil
    var onLongPress: (() -> Void)? = nil
    @State private var isPressed = false
    @State private var uiImage: UIImage? = nil
    @ObservedObject private var l = LocalizationManager.shared

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                VStack(spacing: 0) {
                    Group {
                        if let image = uiImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("AppPlaceholderBg").opacity(0.4))
                        }
                    }
                    .frame(height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                    Text(card.localizedWord(language: l.currentLanguage))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("AppTextDark"))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }
                .frame(height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color("AppPlaceholderBg").opacity(0.2))
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                )
                .scaleEffect(isPressed ? 0.94 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                    .onEnded   { _ in withAnimation(.easeInOut(duration: 0.15)) { isPressed = false } }
            )

            // ── Красный минус (только в режиме edit) ──
            if isEditing {
                Button(action: { onMinusTap?() }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "C0392B"))
                            .frame(width: 24, height: 24)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x: 4, y: -4)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    if !isEditing { onLongPress?() }
                }
        )
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
// MARK: - Word Card View (mock)

struct WordCardView: View {
    let word: WordCard
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(word.color.opacity(0.3))
                    .frame(height: 60)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                Text(word.word)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("AppTextDark"))
                    .padding(.bottom, 10)
                    .padding(.top, 4)
            }
            .frame(height: 110)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(word.color.opacity(0.2))
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.94 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                .onEnded   { _ in withAnimation(.easeInOut(duration: 0.15)) { isPressed = false } }
        )
    }
}

// MARK: - Quick Tip Banner

struct QuickTipBanner: View {
    @ObservedObject private var l = LocalizationManager.shared

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Color(hex: "5BAECC")).frame(width: 32, height: 32)
                Image(systemName: "lightbulb.fill").font(.system(size: 14)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(l.quickTip)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("AppTextPrimary"))
                Text(l.quickTipBody)
                    .font(.system(size: 12))
                    .foregroundColor(Color("AppTextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("AppTintBlue"))
        )
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxW = proposal.width ?? 0
        var x: CGFloat = 0; var y: CGFloat = 0; var rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > maxW, x > 0 { x = 0; y += rowH + spacing; rowH = 0 }
            x += s.width + spacing; rowH = max(rowH, s.height)
        }
        return CGSize(width: maxW, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX; var y = bounds.minY; var rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: .unspecified); x += s.width + spacing; rowH = max(rowH, s.height)
        }
    }
}

// MARK: - Recent Card Tile

struct RecentCardTile: View {
    let card: Card
    let onTap: () -> Void
    @State private var isPressed = false
    @State private var uiImage: UIImage? = nil
    @ObservedObject private var l = LocalizationManager.shared

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Group {
                    if let uiImage = uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("AppPlaceholderBg").opacity(0.4))
                    }
                }
                .frame(height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 8)
                .padding(.top, 8)

                Text(card.localizedWord(language: l.currentLanguage))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("AppTextDark"))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color("AppPlaceholderBg").opacity(0.2))
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.94 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                .onEnded   { _ in withAnimation(.easeInOut(duration: 0.15)) { isPressed = false } }
        )
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


struct DeleteConfirmModal: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 20) {
                // Крестик
                HStack {
                    Spacer()
                    Button(action: onCancel) {
                        ZStack {
                            Circle()
                                .fill(Color("AppCloseButtonBg"))
                                .frame(width: 30, height: 30)
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color("AppCloseButtonIcon"))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // Иконка
                ZStack {
                    Circle()
                        .fill(Color(hex: "FECACA"))
                        .frame(width: 64, height: 64)
                    Image(systemName: "trash.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "F87171"))
                }

                // Текст
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("AppTextPrimary"))
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6B8BAE"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                // Кнопка подтверждения
                Button(action: onConfirm) {
                    Text(buttonTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color(hex: "F87171"))
                        )
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
            )
            .padding(.horizontal, 32)
        }
        .ignoresSafeArea()
    }
}


// MARK: - Add Cards To Category Sheet

struct AddCardsToCategory: View {
    let category: Category
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var allCards: [Card] = []
    @State private var selectedIds: Set<Int> = []
    @State private var isLoading = true
    @State private var isSaving = false

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    // Карточки которых ещё нет в категории
    private var availableCards: [Card] {
        let existingIds = Set(viewModel.cardsInCategory.map { $0.id })
        return allCards.filter { !existingIds.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Хедер
            HStack {
                Button { dismiss() } label: {
                    Text(LocalizationManager.shared.cancel)
                        .foregroundColor(Color("AppTextSecondary"))
                        .font(.system(size: 15))
                }
                Spacer()
                Text(LocalizationManager.shared.addCards)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("AppTextPrimary"))
                Spacer()
                Button {
                    guard !selectedIds.isEmpty else { dismiss(); return }
                    isSaving = true
                    Task {
                        for cardId in selectedIds {
                            _ = try? await CardService.shared.updateCard(id: cardId, categoryId: category.id)
                        }
                        await viewModel.loadCards(for: category)
                        isSaving = false
                        dismiss()
                    }
                } label: {
                    if isSaving {
                        ProgressView().scaleEffect(0.8)
                    } else {
                        Text(selectedIds.isEmpty ? LocalizationManager.shared.done : "\(LocalizationManager.shared.addCards) (\(selectedIds.count))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(selectedIds.isEmpty ? Color("AppTextHint") : Color(hex: "5BAECC"))
                    }
                }
                .disabled(isSaving)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if availableCards.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 40))
                        .foregroundColor(Color("AppTextHint"))
                    Text(LocalizationManager.shared.noCardsAvailable)
                        .font(.system(size: 16))
                        .foregroundColor(Color("AppTextSecondary"))
                    Text(LocalizationManager.shared.createCardsFirst)
                        .font(.system(size: 13))
                        .foregroundColor(Color("AppTextHint"))
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select cards to add to \"\(category.localizedName(language: LocalizationManager.shared.currentLanguage))\"")
                            .font(.system(size: 13))
                            .foregroundColor(Color("AppTextSecondary"))
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(availableCards) { card in
                                SelectableCardTile(
                                    card: card,
                                    isSelected: selectedIds.contains(card.id)
                                ) {
                                    if selectedIds.contains(card.id) {
                                        selectedIds.remove(card.id)
                                    } else {
                                        selectedIds.insert(card.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .background(Color("AppBg").ignoresSafeArea())
        .task {
            let categories = (try? await CategoryService.shared.getCategories()) ?? []
            if let unassigned = categories.first(where: { $0.nameEn == "Unassigned" || $0.name == "Без категории" }) {
                allCards = (try? await CardService.shared.getCards(categoryId: unassigned.id)) ?? []
            }
            isLoading = false
        }
    }
}

// MARK: - Selectable Card Tile

private struct SelectableCardTile: View {
    let card: Card
    let isSelected: Bool
    let onTap: () -> Void
    @State private var uiImage: UIImage? = nil
    @ObservedObject private var l = LocalizationManager.shared

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                VStack(spacing: 0) {
                    Group {
                        if let img = uiImage {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("AppPlaceholderBg").opacity(0.4))
                        }
                    }
                    .frame(height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 8).padding(.top, 8)

                    Text(card.localizedWord(language: l.currentLanguage))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("AppTextDark"))
                        .lineLimit(2).multilineTextAlignment(.center)
                        .padding(.horizontal, 4).padding(.vertical, 8)
                }
                .frame(height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color("AppSurface"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isSelected ? Color(hex: "5BAECC") : Color.clear, lineWidth: 2.5)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())

            if isSelected {
                ZStack {
                    Circle().fill(Color(hex: "5BAECC")).frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: -4)
            }
        }
        .task(id: card.id) {
            guard uiImage == nil else { return }
            let base64 = card.imageBase64
            uiImage = await Task.detached(priority: .userInitiated) {
                guard let data = Data(base64Encoded: base64) else { return UIImage?.none }
                return UIImage(data: data)
            }.value
        }
    }
}
