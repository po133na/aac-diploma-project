// Features/Profile/ViewModels/ProfileViewModel.swift
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var stats: UserStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var largeText: Bool {
        didSet {
            UserDefaults.standard.set(largeText, forKey: "large_text")
            ThemeManager.shared.isLargeText = largeText
        }
    }
    @Published var darkTheme: Bool {
        didSet {
            UserDefaults.standard.set(darkTheme, forKey: "high_contrast")
            ThemeManager.shared.isHighContrast = darkTheme
        }
    }

    private let statsService = StatsService()
    private let authService  = AuthService()

    init() {
        largeText = UserDefaults.standard.bool(forKey: "large_text")
        darkTheme = UserDefaults.standard.bool(forKey: "high_contrast")

        ThemeManager.shared.isLargeText    = largeText
        ThemeManager.shared.isHighContrast = darkTheme
    }

    // Словарь [cardId: Card] для локализованных названий в статистике.
    // Бэкенд не возвращает word_ru/word_kk/word_en в top_cards → берём из кэша.
    @Published var topCardDetails: [Int: Card] = [:]

    func loadStats() async {
        isLoading = true
        defer { isLoading = false }
        if let loaded = try? await statsService.getStats() {
            stats = loaded
            let widgetCards = loaded.topCards.map { WidgetCard(word: $0.word, usageCount: $0.usageCount) }
            WidgetDataManager.shared.save(cards: widgetCards)
            // Обогащаем топ-карточки переводами из локального кэша
            enrichTopCards(ids: loaded.topCards.map { $0.id })
        }
    }

    func enrichTopCards(ids: [Int] = []) {
        let targetIds = ids.isEmpty ? (stats?.topCards.map { $0.id } ?? []) : ids
        guard !targetIds.isEmpty else { return }
        let idSet = Set(targetIds)
        let cached = CacheService.shared.loadCards()
        // uniquingKeysWith защищает от дублирующихся ID в кэше (SwiftData гарантирует уникальность,
        // но защита нужна на случай миграции или повреждения базы)
        topCardDetails = Dictionary(
            cached.filter { idSet.contains($0.id) }.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    func changePassword(old: String, new: String) async throws {
        _ = try await authService.changePassword(old: old, new: new)
    }

    func updateProfile(username: String) async { /* TODO */ }
    func deleteAccount() async { /* TODO */ }
}
