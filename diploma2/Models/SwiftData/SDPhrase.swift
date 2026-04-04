import SwiftData
import Foundation

@Model
final class SDPhrase {
    @Attribute(.unique) var id: Int
    var name: String
    /// card IDs stored as comma-separated string
    var cardIdsRaw: String
    var usageCount: Int
    var createdAt: Date
    var updatedAt: Date?

    var cardIds: [Int] {
        cardIdsRaw.split(separator: ",").compactMap { Int($0) }
    }

    init(from phrase: Phrase) {
        self.id          = phrase.id
        self.name        = phrase.name
        self.cardIdsRaw  = phrase.cardIds.map(String.init).joined(separator: ",")
        self.usageCount  = phrase.usageCount
        self.createdAt   = phrase.createdAt
        self.updatedAt   = phrase.updatedAt
    }

    func toDomain() -> Phrase {
        Phrase(
            id:         id,
            name:       name,
            cardIds:    cardIds,
            userId:     -1,
            usageCount: usageCount,
            createdAt:  createdAt,
            updatedAt:  updatedAt
        )
    }
}
