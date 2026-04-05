// Services/WidgetDataManager.swift
// Shared between main app and AACWidget extension via App Group.
//
// App Group ID — must match in both targets' Signing & Capabilities:
//   group.com.diploma2.aac
//
import Foundation
import WidgetKit

struct WidgetCard: Codable {
    let word: String
    let usageCount: Int
}

final class WidgetDataManager {
    static let shared = WidgetDataManager()
    private init() {}

    private let appGroupID = "group.com.diploma2.aac"
    private let key = "widget_top_cards"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    /// Вызывать после загрузки статистики (ProfileViewModel.loadStats)
    func save(topCards: [TopCard]) {
        let items = topCards.prefix(6).map { WidgetCard(word: $0.word, usageCount: $0.usageCount) }
        if let data = try? JSONEncoder().encode(items) {
            defaults?.set(data, forKey: key)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Вызывается из виджета
    func load() -> [WidgetCard] {
        guard
            let data = defaults?.data(forKey: key),
            let items = try? JSONDecoder().decode([WidgetCard].self, from: data)
        else { return [] }
        return items
    }
}
