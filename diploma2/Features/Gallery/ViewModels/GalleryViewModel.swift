// Features/Gallery/ViewModels/GalleryViewModel.swift
import Foundation

@MainActor
final class GalleryViewModel: ObservableObject {

    @Published var categories: [Category] = []
    @Published var favoriteCards: [Card] = []
    @Published var recentCards: [Card] = []
    @Published var savedPhrases: [Phrase] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let cardService     = CardService()
    private let categoryService = CategoryService()
    private let phraseService   = PhraseService()

    func loadData() async {
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
        do { categories = try await categoryService.getCategories() }
        catch { }
    }

    private func loadFavorites() async {
        do { favoriteCards = try await cardService.getCards(favoritesOnly: true) }
        catch { }
    }

    private func loadRecent() async {
        do {
            let all = try await cardService.getCards()
            recentCards = Array(all.prefix(20))
        } catch { }
    }

    private func loadPhrases() async {
        do { savedPhrases = try await phraseService.getPhrases() }
        catch { }
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
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func deletePhrase(_ phrase: Phrase) {
        Task {
            do {
                try await phraseService.deletePhrase(id: phrase.id)
                savedPhrases.removeAll { $0.id == phrase.id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func createFolder(name: String, emoji: String?) {
        Task {
            do {
                let category = try await categoryService.createCategory(name: name, icon: emoji)
                categories.append(category)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func speakCard(_ card: Card) {
        Task {
            let lang = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "preferred_language") ?? "ru") ?? .russian
            await TTSService().speak(text: card.word, language: lang)
        }
    }
}
