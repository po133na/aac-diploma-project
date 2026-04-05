// Features/Home/ViewModels/HomeViewModel.swift
import Foundation
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Sentence builder
    @Published var tokens: [SentenceToken] = []
    @Published var typedText: String = ""   // текст который юзер сейчас вводит

    /// Все карточки в токенах (для tracking usage / phrase saving)
    var selectedCards: [Card] {
        tokens.compactMap { if case .card(let c, _) = $0 { return c } else { return nil } }
    }

    // MARK: - Данные
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category? = nil
    @Published var cardsInCategory: [Card] = []
    @Published var recentCards: [Card] = []
    @Published var selectedMockCategory: WordCategory? = nil

    // MARK: - State
    @Published var isLoadingCategories = false
    @Published var isLoadingCards = false
    @Published var isCreatingCard = false
    @Published var errorMessage: String?
    @Published var isOffline = false

    // MARK: - Services
    private let cardService     = CardService.shared
    private let categoryService = CategoryService.shared
    private let phraseService   = PhraseService()
    private let cache           = CacheService.shared
    private let network         = NetworkMonitor.shared
    private let syncService     = SyncService.shared
    let ttsService              = TTSService.shared

    // MARK: - Pending usage queue
    private let pendingUsageKey = "pending_card_usage"
    private var pendingCardIds: [Int] {
        get { UserDefaults.standard.array(forKey: pendingUsageKey) as? [Int] ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: pendingUsageKey) }
    }
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        // Когда интернет появляется — синкаем данные и отправляем очереди
        network.connectionRestored
            .sink { [weak self] in
                Task {
                    await self?.flushPendingUsage()
                    await PendingActionQueue.shared.flush()
                    await self?.syncService.sync()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Computed

    var sentenceText: String {
        let parts = tokens.map(\.word) + (typedText.trimmingCharacters(in: .whitespaces).isEmpty ? [] : [typedText.trimmingCharacters(in: .whitespaces)])
        return parts.joined(separator: " ")
    }
    var wordCount: Int { selectedCards.count }

    // MARK: - Загрузка данных

    func loadInitialData() async {
        // 1. Сразу показываем кеш (не ждём сеть)
        let cachedCategories = cache.loadCategories()
        if !cachedCategories.isEmpty { categories = cachedCategories }
        let cachedCards = cache.loadCards()
        if !cachedCards.isEmpty { recentCards = Array(cachedCards.prefix(6)) }

        // 2. В фоне: синкаем с сервером если есть сеть
        if network.isConnected {
            Task {
                await syncService.sync()
                await loadCategories()
                await loadRecentCards()
            }
        }
    }

    func loadCategories() async {
        isLoadingCategories = true
        defer { isLoadingCategories = false }

        // Офлайн — сразу берём кеш
        if !network.isConnected {
            isOffline = true
            let cached = cache.loadCategories()
            if !cached.isEmpty { categories = cached }
            return
        }

        isOffline = false
        do {
            let loaded = try await categoryService.getCategories()
            categories = loaded
            errorMessage = nil
            cache.saveCategories(loaded)
        } catch {
            // Сеть есть но запрос упал — берём кеш как fallback
            let cached = cache.loadCategories()
            if !cached.isEmpty {
                categories = cached
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }

    func refreshCategories() async { await loadCategories() }

    func loadRecentCards() async {
        if !network.isConnected {
            recentCards = Array(cache.loadCards().prefix(6))
            return
        }
        do {
            let all = try await cardService.getCards()
            recentCards = Array(all.prefix(6))
            cache.saveCards(all)
        } catch {
            recentCards = Array(cache.loadCards().prefix(6))
        }
    }

    func loadCards(for category: Category) async {
        isLoadingCards = true
        defer { isLoadingCards = false }

        if !network.isConnected {
            cardsInCategory = cache.loadCards(categoryId: category.id)
            return
        }

        do {
            let loaded = try await cardService.getCards(categoryId: category.id)
            cardsInCategory = loaded
            cache.saveCards(loaded)
        } catch {
            // Fallback на кеш
            let cached = cache.loadCards(categoryId: category.id)
            if !cached.isEmpty {
                cardsInCategory = cached
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Sentence builder

    func addCard(_ card: Card) {
        // Фиксируем текущий typed текст как токен перед карточкой
        let trimmed = typedText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            tokens.append(.typed(trimmed, UUID()))
            typedText = ""
        }
        tokens.append(.card(card, UUID()))
        if UserDefaults.standard.bool(forKey: "auto_speak") {
            Task { await ttsService.speak(text: card.word, language: detectLanguage(card.word)) }
        }
        if network.isConnected {
            Task { _ = try? await cardService.useCard(id: card.id) }
        } else {
            pendingCardIds.append(card.id)
        }
    }

    private func flushPendingUsage() async {
        let ids = pendingCardIds
        guard !ids.isEmpty else { return }
        pendingCardIds = []
        for id in ids {
            _ = try? await cardService.useCard(id: id)
        }
    }

    func removeToken(_ token: SentenceToken) {
        tokens.removeAll { $0.id == token.id }
    }

    func clearSentence() {
        withAnimation(.spring(response: 0.3)) {
            tokens.removeAll()
            typedText = ""
        }
    }

    func speakSentence() {
        let text = sentenceText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        Task {
            let lang = detectLanguage(text)
            await ttsService.speak(text: text, language: lang)
        }
    }

    private func detectLanguage(_ text: String) -> AppLanguage {
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

    func savePhraseAs(name: String) async {
        let cardIds = selectedCards.map { $0.id }
        guard !cardIds.isEmpty else { return }
        do {
            _ = try await phraseService.createPhrase(name: name, cardIds: cardIds)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Навигация

    func selectCategory(_ category: Category) {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedCategory = category
            selectedMockCategory = nil
        }
        Task { await loadCards(for: category) }
    }

    func goBack() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedCategory = nil
            selectedMockCategory = nil
            cardsInCategory = []
        }
    }

    // MARK: - Создание карточки (AI)

    func createCard(word: String, language: AppLanguage, categoryId: Int? = nil) async -> Card? {
        isCreatingCard = true
        errorMessage = nil
        defer { isCreatingCard = false }
        do {
            let card = try await cardService.createCard(
                word: word,
                language: language.cardLanguage,
                categoryId: categoryId
            )
            recentCards.insert(card, at: 0)
            if recentCards.count > 6 { recentCards = Array(recentCards.prefix(6)) }
            cache.saveCards([card])
            return card
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - Edit / Delete cards

    func deleteCard(_ card: Card) {
        Task {
            do {
                try await cardService.deleteCard(id: card.id)
                cardsInCategory.removeAll { $0.id == card.id }
                recentCards.removeAll { $0.id == card.id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func updateCard(_ card: Card, word: String? = nil, categoryId: Int? = nil) async {
        do {
            let updated = try await cardService.updateCard(
                id: card.id,
                isFavorite: nil,
                categoryId: categoryId
            )
            if let idx = cardsInCategory.firstIndex(where: { $0.id == updated.id }) {
                cardsInCategory[idx] = updated
            }
            if let idx = recentCards.firstIndex(where: { $0.id == updated.id }) {
                recentCards[idx] = updated
            }
            cache.saveCards([updated])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Edit / Delete categories

    func deleteCategory(_ category: Category) {
        Task {
            do {
                try await categoryService.deleteCategory(id: category.id)
                categories.removeAll { $0.id == category.id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Избранное

    func toggleFavorite(_ card: Card) {
        Task {
            do {
                let updated = try await cardService.toggleFavorite(card: card)
                if let idx = cardsInCategory.firstIndex(where: { $0.id == updated.id }) {
                    cardsInCategory[idx] = updated
                }
                if let idx = recentCards.firstIndex(where: { $0.id == updated.id }) {
                    recentCards[idx] = updated
                }
                cache.saveCards([updated])
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
