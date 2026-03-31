// Features/Home/Views/HomeView.swift
import SwiftUI

// MARK: - Home View (корневой)

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            Color(hex: "EAF4FB").ignoresSafeArea()

            VStack(spacing: 0) {
                // Топ панель с построителем предложений
                SentenceBuilderBar(viewModel: viewModel)

                // Контент
                if let mockCat = viewModel.selectedMockCategory {
                    // Мок-категория (офлайн / бэкенд недоступен)
                    MockCategoryDetailView(category: mockCat, viewModel: viewModel)
                        .transition(.move(edge: .trailing))
                } else if let category = viewModel.selectedCategory {
                    // Реальная категория из бэкенда
                    RealCategoryDetailView(category: category, viewModel: viewModel)
                        .transition(.move(edge: .trailing))
                } else {
                    // Главный список
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
        .sheet(isPresented: $viewModel.showSpeakModal) {
            SpeakModalView(viewModel: viewModel)
                .presentationDetents([.fraction(0.55)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Sentence Builder Bar

struct SentenceBuilderBar: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 0) {

            // Заголовок строки
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "C5E8F5"))
                        .frame(width: 36, height: 36)
                    Image(systemName: "face.smiling")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "5BAECC"))
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("My Sentence")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                    Text("\(viewModel.wordCount) words")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "6B8BAE"))
                }

                Spacer()

                if !viewModel.selectedCards.isEmpty {
                    Button {
                        viewModel.clearSentence()
                    } label: {
                        Text("Clear")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "6B8BAE"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.white.opacity(0.8)))
                    }
                }

                Button {
                    viewModel.speakSentence()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 13))
                        Text("Speak")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color(hex: "5BAECC")))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)

            // Область чипов
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.7))
                    .frame(height: 52)

                if viewModel.selectedCards.isEmpty {
                    Text("Tap words to build your sentence...")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "9BB8CC"))
                        .padding(.horizontal, 14)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(viewModel.selectedCards.indices, id: \.self) { idx in
                                CardChip(word: viewModel.selectedCards[idx].word) {
                                    viewModel.removeCard(at: idx)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color(hex: "D6EEF8").opacity(0.6))
    }
}

// MARK: - Card Chip

struct CardChip: View {
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
                    .foregroundColor(Color(hex: "5BAECC"))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color(hex: "C5E8F5")))
    }
}

// MARK: - Home Content (список категорий)

struct HomeContentView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Заголовок
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color(hex: "F5ECC5")).frame(width: 40, height: 40)
                        Text("✨").font(.system(size: 20))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Let's Talk!")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        Text("Choose a category to start")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 14)

                // Список категорий
                if viewModel.isLoadingCategories {
                    ProgressView().padding(.top, 40)
                } else if viewModel.categories.isEmpty {
                    // Мок данные — бэкенд недоступен
                    VStack(spacing: 10) {
                        ForEach(WordCategory.sampleData) { category in
                            MockCategoryRow(category: category) {
                                viewModel.selectedMockCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    // Реальные категории из бэкенда
                    VStack(spacing: 10) {
                        ForEach(viewModel.categories) { category in
                            RealCategoryRow(category: category) {
                                viewModel.selectCategory(category)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Recent Cards (сгенерированные карточки)
                if !viewModel.recentCards.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Cards")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "1C3F6E"))
                            Spacer()
                            NavigationLink(destination: CardManagerView()) {
                                Text("View All >")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "F87171"))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        
                        // Грид карточек
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
    }
}

// MARK: - Mock Category Row (WordCategory — мок)

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

// MARK: - Real Category Row (Category из бэкенда)

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

// MARK: - Mock Category Detail (WordCard — мок)

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
                // Хедер
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

                // Грид мок-слов
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(category.words) { word in
                        WordCardView(word: word) {
                            withAnimation(.spring(response: 0.3)) {
                                // Конвертируем WordCard → Card
                                let card = Card(
                                    id: 0,
                                    word: word.word,
                                    language: "ru",
                                    translatedWord: word.word,
                                    imageBase64: "",
                                    isFavorite: false,
                                    usageCount: 0,
                                    categoryId: nil,
                                    userId: 0,
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

// MARK: - Real Category Detail (Card из бэкенда)

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

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Group {
                    if let image = card.image {
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
    }
}

// MARK: - Word Card View (для мок-данных)

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

// MARK: - Speak Modal

struct SpeakModalView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(hex: "EAF4FB").ignoresSafeArea()

            VStack(spacing: 20) {
                // Хедер
                HStack {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Color(hex: "5BAECC")).frame(width: 44, height: 44)
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 18)).foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Listen")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "1C3F6E"))
                            Text("Your sentence")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "6B8BAE"))
                        }
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        ZStack {
                            Circle().fill(Color.white).frame(width: 34, height: 34)
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "6B8BAE"))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                // Слова в модалке
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)

                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.selectedCards.indices, id: \.self) { idx in
                            Text(viewModel.selectedCards[idx].word)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: "1C3F6E"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color(hex: "C5E8F5").opacity(0.7)))
                        }
                    }
                    .padding(12)
                }
                .padding(.horizontal, 20)

                // Speak Again
                Button { viewModel.speakSentence() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill").font(.system(size: 16))
                        Text("Speak Again").font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(hex: "5BAECC"))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
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
    
    private var uiImage: UIImage? {
        let base64 = card.imageBase64
        guard let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
        return UIImage(data: data)
    }

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
    }
}

#Preview {
    HomeView()
}
