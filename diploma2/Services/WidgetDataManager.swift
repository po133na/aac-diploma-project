// Services/WidgetDataManager.swift
// Shared between main app and AACWidget extension via App Group.
//
// App Group ID — must match in both targets' Signing & Capabilities:
//   group.com.diploma2.aac
//
import Foundation
import WidgetKit

struct WidgetCard: Codable, Identifiable {
    let word: String
    let usageCount: Int
    var id: String { word }
}

final class WidgetDataManager {
    static let shared = WidgetDataManager()
    private init() {}

    private let appGroupID = "group.com.bayanbayevasm.diploma2"
    private let key = "widget_top_cards"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    func save(cards: [WidgetCard]) {
        if let data = try? JSONEncoder().encode(Array(cards.prefix(6))) {
            defaults?.set(data, forKey: key)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    func load() -> [WidgetCard] {
        guard
            let data = defaults?.data(forKey: key),
            let items = try? JSONDecoder().decode([WidgetCard].self, from: data)
        else { return [] }
        return items
    }
}
