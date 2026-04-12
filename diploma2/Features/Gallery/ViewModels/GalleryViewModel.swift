import Foundation

@MainActor
final class GalleryViewModel: ObservableObject {

    @Published var categories: [Category] = []
    @Published var favoriteCards: [Card] = []
    @Published var recentCards: [Card] = []
    @Published var savedPhrases: [Phrase] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Services
    private let cardService      = CardService.shared
    private let categoryService  = CategoryService.shared
    private let cache            = CacheService.shared
    private let network          = NetworkMonitor.shared

    func loadData() async {
        // Сразу показываем локальный кеш
        let cachedAll = cache.loadCards()
        favoriteCards = cachedAll.filter { $0.isFavorite }
        recentCards   = Array(cachedAll.prefix(20))
        categories    = cache.loadCategories()
        savedPhrases  = cache.loadPhrases()

        guard network.isConnected else { return }

        isLoading = true
        defer { isLoading = false }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadCategories() }
            group.addTask { await self.loadFavorites() }
            group.addTask { await self.loadRecent() }
            group.addTask { await self.loadPhrases() }
        }
    }

    private func loadCategories() async {
        do {
            categories = try await categoryService.getCategories()
            cache.saveCategories(categories)
        }
        catch {
            print("[GalleryViewModel] loadCategories error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    private func loadFavorites() async {
        do {
            let all = try await cardService.getCards()
            favoriteCards = all.filter { $0.isFavorite }
            cache.saveCards(all)
        } catch {
            print("[GalleryViewModel] loadFavorites error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    private func loadRecent() async {
        do {
            let all = try await cardService.getCards()
            recentCards = Array(all.prefix(20))
        } catch {
            print("[GalleryViewModel] loadRecent error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    private func loadPhrases() async {
        do {
            savedPhrases = try await PhraseService().getPhrases()
            cache.savePhrases(savedPhrases)
        } catch {
            print("[GalleryViewModel] loadPhrases error: \(error)")
        }
    }

    func toggleFavorite(_ card: Card) {
        Task {
            do {
                let updated = try await cardService.toggleFavorite(card: card)
                if let idx = favoriteCards.firstIndex(where: { $0.id == updated.id }) {
                    if updated.isFavorite {
                        favoriteCards[idx] = updated
                    } else {
                        favoriteCards.remove(at: idx)
                    }
                } else if updated.isFavorite {
                    favoriteCards.insert(updated, at: 0)
                }
                if let idx = recentCards.firstIndex(where: { $0.id == updated.id }) {
                    recentCards[idx] = updated
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func deletePhrase(_ phrase: Phrase) {
        savedPhrases.removeAll { $0.id == phrase.id }
    }

    func createFolder(name: String, emoji: String?) {
        Task {
            do {
                let category = try await categoryService.createCategory(
                    name: name,
                    nameKk: nil,
                    nameEn: nil,
                    icon: emoji
                )
                categories.append(category)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func speakCard(_ card: Card) {
        Task {
            let lang = LocalizationManager.shared.currentLanguage
            await TTSService.shared.speak(text: card.localizedWord(language: lang), language: lang)
        }
    }
}
