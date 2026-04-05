// AACWidget/AACWidget.swift
//
// SETUP (один раз в Xcode):
// 1. Оба таргета (diploma2 + AACWidget) → Signing & Capabilities → + App Groups
//    → добавить "group.com.diploma2.aac"
// 2. Файл WidgetDataManager.swift → File Inspector → Target Membership → включить AACWidget
//
import WidgetKit
import SwiftUI

// MARK: - Shared card model (зеркало WidgetCard из WidgetDataManager)

private struct WidgetCard: Codable, Identifiable {
    let word: String
    let usageCount: Int
    var id: String { word }
}

private func loadCards() -> [WidgetCard] {
    guard
        let defaults = UserDefaults(suiteName: "group.com.diploma2.aac"),
        let data = defaults.data(forKey: "widget_top_cards"),
        let items = try? JSONDecoder().decode([WidgetCard].self, from: data)
    else { return [] }
    return items
}

// MARK: - Timeline

struct AACEntry: TimelineEntry {
    let date: Date
    let cards: [WidgetCard]
}

struct AACProvider: TimelineProvider {
    func placeholder(in context: Context) -> AACEntry {
        AACEntry(date: Date(), cards: placeholderCards)
    }
    func getSnapshot(in context: Context, completion: @escaping (AACEntry) -> Void) {
        completion(AACEntry(date: Date(), cards: loadCards().isEmpty ? placeholderCards : loadCards()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<AACEntry>) -> Void) {
        let entry = AACEntry(date: Date(), cards: loadCards())
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private var placeholderCards: [WidgetCard] {[
        WidgetCard(word: "мама",  usageCount: 15),
        WidgetCard(word: "хочу",  usageCount: 12),
        WidgetCard(word: "пить",  usageCount: 9),
        WidgetCard(word: "есть",  usageCount: 7),
        WidgetCard(word: "домой", usageCount: 5),
        WidgetCard(word: "спать", usageCount: 4),
    ]}
}

// MARK: - Small widget (2×2) — топ 3 слова списком

private struct SmallWidgetView: View {
    let cards: [WidgetCard]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Заголовок
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "F5A623"))
                Text("Частые слова")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "6B8BAE"))
            }

            if cards.isEmpty {
                Spacer()
                Text("Открой приложение чтобы начать")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "9BB8CC"))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            } else {
                ForEach(cards.prefix(3)) { card in
                    Link(destination: URL(string: "aac://speak?word=\(card.word.urlEncoded)")!) {
                        HStack(spacing: 6) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "5BAECC"))
                            Text(card.word)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "1C3F6E"))
                                .lineLimit(1)
                            Spacer()
                            Text("\(card.usageCount)×")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "9BB8CC"))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "EAF6FB"))
                        )
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Medium widget (4×2) — 6 карточек сеткой

private struct MediumWidgetView: View {
    let cards: [WidgetCard]

    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "F5A623"))
                Text("Часто используемые слова")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "6B8BAE"))
                Spacer()
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "C97AB2"))
            }

            if cards.isEmpty {
                Text("Открой приложение чтобы начать")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "9BB8CC"))
            } else {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(cards.prefix(6)) { card in
                        Link(destination: URL(string: "aac://speak?word=\(card.word.urlEncoded)")!) {
                            VStack(spacing: 2) {
                                Text(card.word)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "1C3F6E"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Text("\(card.usageCount)×")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: "9BB8CC"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color(hex: "5BAECC"), lineWidth: 1.2)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "EAF6FB")))
                            )
                        }
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Entry view router

struct AACWidgetEntryView: View {
    let entry: AACEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:  SmallWidgetView(cards: entry.cards)
        default:            MediumWidgetView(cards: entry.cards)
        }
    }
}

// MARK: - Widget

struct AACWidget: Widget {
    let kind = "AACWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AACProvider()) { entry in
            AACWidgetEntryView(entry: entry)
                .containerBackground(Color(hex: "D6EEF5"), for: .widget)
        }
        .configurationDisplayName("Мои карточки")
        .description("Часто используемые слова — нажми чтобы озвучить")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Color hex (виджет — отдельный таргет, нужна своя копия)

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    AACWidget()
} timeline: {
    AACEntry(date: Date(), cards: [
        WidgetCard(word: "мама",  usageCount: 15),
        WidgetCard(word: "хочу",  usageCount: 12),
        WidgetCard(word: "пить",  usageCount: 9),
        WidgetCard(word: "есть",  usageCount: 7),
        WidgetCard(word: "домой", usageCount: 5),
        WidgetCard(word: "спать", usageCount: 4),
    ])
}
