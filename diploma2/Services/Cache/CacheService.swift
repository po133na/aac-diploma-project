import SwiftData
import Foundation

@MainActor
final class CacheService {
    static let shared = CacheService()

    // Единый контейнер — используется и здесь и в UnimApp
    static let container: ModelContainer = {
        let schema = Schema([SDCard.self, SDCategory.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    private var context: ModelContext { CacheService.container.mainContext }

    private init() {}

    // MARK: - Categories

    func saveCategories(_ categories: [Category]) {
        for category in categories {
            let existing = fetchCategory(id: category.id)
            if let existing {
                existing.name     = category.name
                existing.nameKk   = category.nameKk
                existing.nameEn   = category.nameEn
                existing.icon     = category.icon
                existing.isSystem = category.isSystem
                existing.cachedAt = Date()
            } else {
                context.insert(SDCategory(from: category))
            }
        }
        try? context.save()
    }

    func loadCategories() -> [Category] {
        let items = (try? context.fetch(FetchDescriptor<SDCategory>())) ?? []
        return items.map { $0.toDomain() }
    }

    private func fetchCategory(id: Int) -> SDCategory? {
        var descriptor = FetchDescriptor<SDCategory>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    // MARK: - Cards

    func saveCards(_ cards: [Card]) {
        for card in cards {
            let existing = fetchCard(id: card.id)
            if let existing {
                existing.word           = card.word
                existing.language       = card.language
                existing.translatedWord = card.translatedWord
                existing.imageBase64    = card.imageBase64
                existing.isFavorite     = card.isFavorite
                existing.usageCount     = card.usageCount
                existing.categoryId     = card.categoryId
            } else {
                context.insert(SDCard(from: card))
            }
        }
        try? context.save()
    }

    func loadCards(categoryId: Int? = nil) -> [Card] {
        var descriptor: FetchDescriptor<SDCard>
        if let categoryId {
            descriptor = FetchDescriptor<SDCard>(predicate: #Predicate { $0.categoryId == categoryId })
        } else {
            descriptor = FetchDescriptor<SDCard>()
        }
        descriptor.sortBy = [SortDescriptor(\.usageCount, order: .reverse)]
        let items = (try? context.fetch(descriptor)) ?? []
        return items.map { $0.toDomain() }
    }

    private func fetchCard(id: Int) -> SDCard? {
        var descriptor = FetchDescriptor<SDCard>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
}
