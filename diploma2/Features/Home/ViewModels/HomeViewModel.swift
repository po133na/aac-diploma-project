// Features/Home/ViewModels/HomeViewModel.swift
import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Sentence builder
    @Published var selectedCards: [Card] = []
    @Published var showSpeakModal = false

    // MARK: - Реальные данные (бэкенд)
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category? = nil
    @Published var cardsInCategory: [Card] = []
    @Published var recentCards: [Card] = []

    // MARK: - Мок данные (пока бэкенд не подключён)
    @Published var selectedMockCategory: WordCategory? = nil

    // MARK: - State
    @Published var isLoadingCategories = false
    @Published var isLoadingCards = false
    @Published var isCreatingCard = false
    @Published var errorMessage: String?

    // MARK: - Services
    private let cardService     = CardService()
    private let categoryService = CategoryService()
    private let phraseService   = PhraseService()
    let ttsService              = TTSService()

    // MARK: - Computed

    var sentenceText: String {
        selectedCards.map { $0.word }.joined(separator: " ")
    }

    var wordCount: Int { selectedCards.count }

    // MARK: - Загрузка данных

    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadCategories() }
            group.addTask { await self.loadRecentCards() }
        }
    }

    func loadCategories() async {
        isLoadingCategories = true
        defer { isLoadingCategories = false }
        do {
            categories = try await categoryService.getCategories()
        } catch {
            // Если бэкенд недоступен — покажем мок данные
            categories = []
        }
    }
    
    func refreshCategories() async {
        await loadCategories()
    }

    func loadRecentCards() async {
        do {
            let all = try await cardService.getCards()
            recentCards = Array(all.prefix(6))
        } catch {
            recentCards = []
        }
    }

    func loadCards(for category: Category) async {
        isLoadingCards = true
        defer { isLoadingCards = false }
        do {
            cardsInCategory = try await cardService.getCards(categoryId: category.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sentence builder

    func addCard(_ card: Card) {
        selectedCards.append(card)
        Task { _ = try? await cardService.useCard(id: card.id) }
    }

    func removeCard(at index: Int) {
        guard index < selectedCards.count else { return }
        selectedCards.remove(at: index)
    }

    func clearSentence() {
        withAnimation(.spring(response: 0.3)) {
            selectedCards.removeAll()
        }
    }

    func speakSentence() {
        guard !selectedCards.isEmpty else { return }
        showSpeakModal = true
        Task {
            let lang = AppLanguage(
                rawValue: UserDefaults.standard.string(forKey: "preferred_language") ?? "ru"
            ) ?? .russian
            await ttsService.speak(text: sentenceText, language: lang)
        }
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

    // MARK: - Навигация (реальные категории)

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
            return card
        } catch {
            errorMessage = error.localizedDescription
            return nil
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
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
