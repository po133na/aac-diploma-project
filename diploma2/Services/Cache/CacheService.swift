import SwiftData
import Foundation

@MainActor
final class CacheService {
    static let shared = CacheService()

    // Единый контейнер — используется и здесь и в UnimApp
    static let container: ModelContainer = {
        let schema = Schema([SDCard.self, SDCategory.self, SDPhrase.self])
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
                existing.name             = category.name
                existing.nameKk           = category.nameKk
                existing.nameEn           = category.nameEn
                existing.icon             = category.icon
                existing.coverImageBase64 = category.coverImageBase64
                existing.isSystem         = category.isSystem
                existing.updatedAt        = category.updatedAt
                existing.cachedAt         = Date()
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

    func deleteCategory(id: Int) {
        if let existing = fetchCategory(id: id) {
            context.delete(existing)
            try? context.save()
        }
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
                existing.updatedAt      = card.updatedAt
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

    func deleteCard(id: Int) {
        if let existing = fetchCard(id: id) {
            context.delete(existing)
            try? context.save()
        }
    }

    private func fetchCard(id: Int) -> SDCard? {
        var descriptor = FetchDescriptor<SDCard>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    // MARK: - Phrases

    func savePhrases(_ phrases: [Phrase]) {
        for phrase in phrases {
            let existing = fetchPhrase(id: phrase.id)
            if let existing {
                existing.name       = phrase.name
                existing.cardIdsRaw = phrase.cardIds.map(String.init).joined(separator: ",")
                existing.usageCount = phrase.usageCount
                existing.updatedAt  = phrase.updatedAt
            } else {
                context.insert(SDPhrase(from: phrase))
            }
        }
        try? context.save()
    }

    func loadPhrases() -> [Phrase] {
        let descriptor = FetchDescriptor<SDPhrase>(
            sortBy: [SortDescriptor(\.usageCount, order: .reverse)]
        )
        let items = (try? context.fetch(descriptor)) ?? []
        return items.map { $0.toDomain() }
    }

    func deletePhrase(id: Int) {
        if let existing = fetchPhrase(id: id) {
            context.delete(existing)
            try? context.save()
        }
    }

    private func fetchPhrase(id: Int) -> SDPhrase? {
        var descriptor = FetchDescriptor<SDPhrase>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    // MARK: - Bulk delete (for sync deleted[] list)

    func applyDeletions(_ deletions: [DeletedItemResponse]) {
        for item in deletions {
            switch item.entityType {
            case "card":     deleteCard(id: item.entityId)
            case "category": deleteCategory(id: item.entityId)
            case "phrase":   deletePhrase(id: item.entityId)
            default: break
            }
        }
    }
}
