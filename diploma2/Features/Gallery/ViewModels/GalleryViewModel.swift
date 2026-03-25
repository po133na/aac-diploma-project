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

    private let cardService = CardService.shared

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadCategories() }
            group.addTask { await self.loadFavorites() }
            group.addTask { await self.loadRecent() }
            // group.addTask { await self.loadPhrases() } // временно отключено
        }
    }

    private func loadCategories() async {
        do { categories = try await cardService.fetchCategories() }
        catch {
            print("[GalleryViewModel] loadCategories error: \(error)")
            errorMessage = "Не удалось загрузить категории: \(error.localizedDescription)"
        }
    }

    private func loadFavorites() async {
        do {
            let all = try await cardService.fetchCards()
            favoriteCards = all.filter { $0.isFavorite }
        } catch {
            print("[GalleryViewModel] loadFavorites error: \(error)")
            errorMessage = "Не удалось загрузить карточки: \(error.localizedDescription)"
        }
    }

    private func loadRecent() async {
        do {
            let all = try await cardService.fetchCards()
            recentCards = Array(all.prefix(20))
        } catch {
            print("[GalleryViewModel] loadRecent error: \(error)")
            errorMessage = "Не удалось загрузить карточки: \(error.localizedDescription)"
        }
    }

    private func loadPhrases() async {
        // временно оставляем пустым, пока не реализован PhraseService
        savedPhrases = []
    }

    func toggleFavorite(_ card: Card) {
        Task {
            do {
                let updated = try await cardService.toggleFavorite(id: card.id)
                // Обновляем массивы
                if let idx = favoriteCards.firstIndex(where: { $0.id == updated.id }) {
                    if updated.isFavorite {
                        favoriteCards[idx] = updated
                    } else {
                        favoriteCards.remove(at: idx)
                    }
                } else if updated.isFavorite {
                    favoriteCards.insert(updated, at: 0)
                }
                // Обновляем recentCards
                if let idx = recentCards.firstIndex(where: { $0.id == updated.id }) {
                    recentCards[idx] = updated
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func deletePhrase(_ phrase: Phrase) {
        Task {
            do {
                // Пока не реализовано
                savedPhrases.removeAll { $0.id == phrase.id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func createFolder(name: String, emoji: String?) {
        Task {
            do {
                let category = try await cardService.createCategory(
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
            let lang = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "preferred_language") ?? "ru") ?? .russian
            await TTSService.shared.speak(text: card.word, language: lang.rawValue)
        }
    }
}
