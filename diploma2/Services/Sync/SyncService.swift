import Foundation

/// Отвечает за синхронизацию локального SwiftData-хранилища с сервером.
/// Вызывается при запуске приложения и при восстановлении сети.
final class SyncService {
    static let shared = SyncService()
    private init() {}

    private let client = APIClient.shared
    private let lastSyncedAtKey = "lastSyncedAt"

    var lastSyncedAt: Date? {
        get { UserDefaults.standard.object(forKey: lastSyncedAtKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastSyncedAtKey) }
    }

    // MARK: - Синк

    /// Скачивает всё изменённое с момента `lastSyncedAt` и обновляет SwiftData.
    /// Сетевой запрос выполняется в фоне, кэш-операции — на MainActor.
    func sync() async {
        let since = lastSyncedAt ?? Date(timeIntervalSince1970: 946684800) // 2000-01-01

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let sinceStr = formatter.string(from: since)

        do {
            // Сетевой запрос — в фоне (не блокирует main thread)
            let response: SyncResponse = try await client.request(
                path: "/sync",
                queryItems: [URLQueryItem(name: "since", value: sinceStr)]
            )
            // Кэш-операции требуют MainActor, но выполняются одним блоком
            await MainActor.run {
                let cache = CacheService.shared
                cache.saveCards(response.cards)
                cache.saveCategories(response.categories)
                cache.savePhrases(response.phrases)
                cache.applyDeletions(response.deleted)
            }
            lastSyncedAt = response.syncedAt
        } catch {
            print("[SyncService] sync failed: \(error)")
        }
    }
}
