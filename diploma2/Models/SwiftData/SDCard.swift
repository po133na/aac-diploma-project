import SwiftData
import Foundation

@Model
final class SDCard {
    @Attribute(.unique) var id: Int
    var word: String
    var language: String
    var translatedWord: String
    var imageBase64: String
    var isFavorite: Bool
    var usageCount: Int
    var categoryId: Int?
    var createdAt: Date

    init(from card: Card) {
        self.id            = card.id
        self.word          = card.word
        self.language      = card.language
        self.translatedWord = card.translatedWord
        self.imageBase64   = card.imageBase64
        self.isFavorite    = card.isFavorite
        self.usageCount    = card.usageCount
        self.categoryId    = card.categoryId
        self.createdAt     = card.createdAt
    }

    func toDomain() -> Card {
        Card(
            id:            id,
            word:          word,
            language:      language,
            translatedWord: translatedWord,
            imageBase64:   imageBase64,
            isFavorite:    isFavorite,
            usageCount:    usageCount,
            categoryId:    categoryId,
            userId:        nil,
            createdAt:     createdAt
        )
    }
}
