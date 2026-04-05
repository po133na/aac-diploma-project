// Features/Home/Views/HomeView.swift
import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            Color(hex: "EAF4FB").ignoresSafeArea()

            VStack(spacing: 0) {
                SentenceBuilderBar(viewModel: viewModel)

                if let mockCat = viewModel.selectedMockCategory {
                    MockCategoryDetailView(category: mockCat, viewModel: viewModel)
                        .transition(.move(edge: .trailing))
                } else if let category = viewModel.selectedCategory {
                    RealCategoryDetailView(category: category, viewModel: viewModel)
                        .transition(.move(edge: .trailing))
                } else {
                    HomeContentView(viewModel: viewModel)
                        .transition(.move(edge: .leading))
                }
            }
        }
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

    private var isEmpty: Bool {
        viewModel.tokens.isEmpty &&
        viewModel.typedText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Верхняя строка: аватар + заголовок + Clear + Speak ──
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "F5D6EC"))
                        .frame(width: 40, height: 40)
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "C97AB2"))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(localization.t("Моё предложение", kk: "Менің сөйлемім", en: "My Sentence"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                    Text(localization.t(
                        "\(viewModel.wordCount) слов",
                        kk: "\(viewModel.wordCount) сөз",
                        en: "\(viewModel.wordCount) words"
                    ))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6B8BAE"))
                }

                Spacer()

                if !isEmpty {
                    Button { viewModel.clearSentence() } label: {
                        Text(localization.t("Очистить", kk: "Тазалау", en: "Clear"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                    .transition(.opacity)
                }

                Button { viewModel.speakSentence() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 14))
                        Text(localization.t("Говорить", kk: "Айту", en: "Speak"))
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(isEmpty ? Color(hex: "9BB8CC") : Color(hex: "5BAECC")))
                }
                .disabled(isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            .animation(.easeInOut(duration: 0.15), value: isEmpty)

            // ── Единая строка: токены по порядку + поле ввода ──
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    // Токены в порядке добавления
                    ForEach(viewModel.tokens) { token in
                        if token.isCard {
                            // Слово из карточки — с обводкой
                            WordChip(word: token.word) {
                                viewModel.removeToken(token)
                            }
                        } else {
                            // Зафиксированный текст — без обводки
                            Text(token.word)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "1C3F6E"))
                        }
                    }

                    // Поле для текущего ввода
                    TextField(
                        isEmpty
                            ? localization.t("Нажми на карточку или напиши...", kk: "Картаны басыңыз немесе жазыңыз...", en: "Tap a card or type here...")
                            : localization.t("ещё слово...", kk: "тағы сөз...", en: "add word..."),
                        text: $viewModel.typedText
                    )
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "1C3F6E"))
                    .focused($isTyping)
                    .submitLabel(.done)
                    .onSubmit { isTyping = false }
                    .frame(minWidth: 140)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
            .contentShape(Rectangle())
            .onTapGesture { isTyping = true }
        }
        .background(Color(hex: "D6EEF8").opacity(0.55))
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
                .foregroundColor(Color(hex: "1C3F6E"))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "6B8BAE"))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .strokeBorder(Color(hex: "5BAECC"), lineWidth: 1.5)
                .background(Capsule().fill(Color(hex: "EAF6FB")))
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
                        Circle().fill(Color(hex: "F5ECC5")).frame(width: 40, height: 40)
                        Text("✨").font(.system(size: 20))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localization.t("Давай поговорим!", kk: "Сөйлесейік!", en: "Let's Talk!"))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text(localization.t("Выбери категорию", kk: "Категория таңдаңыз", en: "Choose a category to start"))
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B8BAE"))
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
                        ForEach(viewModel.categories) { category in
                            RealCategoryRow(category: category) {
                                viewModel.selectCategory(category)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if !category.isSystem {
                                    Button(role: .destructive) {
                                        viewModel.deleteCategory(category)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "9BB8CC"))
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B8BAE"))
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

                if !viewModel.recentCards.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(localization.recentCards)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "1C3F6E"))
                            Spacer()
                            NavigationLink(destination: CardManagerView()) {
                                Text(localization.viewAll)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "F87171"))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)

                        let columns = [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                        ]
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(viewModel.recentCards.prefix(6)) { card in
                                RecentCardTile(card: card) {
                                    withAnimation(.spring(response: 0.3)) {
                                        viewModel.addCard(card)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
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

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: "A8C8F0"))
                        .frame(width: 54, height: 54)
                    Text(category.icon ?? "📁")
                        .font(.system(size: 26))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(category.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                    Text(category.isSystem ? "System category" : "My category")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6B8BAE"))
                }
                Spacer()
                ZStack {
                    Circle().fill(Color(hex: "A8C8F0").opacity(0.5)).frame(width: 30, height: 30)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "5BAECC"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
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
                        .foregroundColor(Color(hex: "1C3F6E"))
                    Text("\(category.words.count) words")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6B8BAE"))
                    Text(category.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6B8BAE"))
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
                    .fill(Color.white)
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
                            Circle().fill(Color.white).frame(width: 36, height: 36)
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "1C3F6E"))
                        }
                    }
                    Spacer()
                    Text("✨ \(category.name)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "1C3F6E"))
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
                            Circle().fill(Color.white).frame(width: 36, height: 36)
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "1C3F6E"))
                        }
                    }
                    Spacer()
                    Text("\(category.icon ?? "✨") \(category.name)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 36, height: 36)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                if viewModel.isLoadingCards {
                    ProgressView().padding(.top, 40)
                } else if viewModel.cardsInCategory.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "9BB8CC"))
                        Text("No cards yet")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.cardsInCategory) { card in
                            RealCardTile(card: card) {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.addCard(card)
                                }
                            }
                            .contextMenu {
                                if card.userId != nil {
                                    Button(role: .destructive) {
                                        viewModel.deleteCard(card)
                                    } label: {
                                        Label("Delete card", systemImage: "trash")
                                    }
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
}

// MARK: - Real Card Tile

struct RealCardTile: View {
    let card: Card
    let onTap: () -> Void
    @State private var isPressed = false
    @State private var uiImage: UIImage? = nil

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Group {
                    if let image = uiImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "C5D8F5").opacity(0.4))
                    }
                }
                .frame(height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 8)
                .padding(.top, 8)

                Text(card.word)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "2C3E50"))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: "C5D8F5").opacity(0.2))
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
                    .foregroundColor(Color(hex: "2C3E50"))
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
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Color(hex: "5BAECC")).frame(width: 32, height: 32)
                Image(systemName: "lightbulb.fill").font(.system(size: 14)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Quick Tip")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "1C3F6E"))
                Text("Tap on any word to add it to your sentence. You can use the same word multiple times!")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6B8BAE"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(hex: "E8F5FF"))
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
                            .fill(Color(hex: "C5D8F5").opacity(0.4))
                    }
                }
                .frame(height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 8)
                .padding(.top, 8)

                Text(card.word)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "2C3E50"))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: "C5D8F5").opacity(0.2))
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

private func detectManualLanguage(_ text: String) -> AppLanguage {
    let kazakhSpecific = CharacterSet(charactersIn: "әғқңөұүһӘҒҚҢӨҰҮҺ")
    for scalar in text.unicodeScalars {
        if kazakhSpecific.contains(scalar) { return .kazakh }
    }
    for scalar in text.unicodeScalars {
        let v = scalar.value
        if v >= 0x0400 && v <= 0x04FF { return .russian }
    }
    return .english
}
