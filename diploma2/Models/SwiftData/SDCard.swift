//
//  SDCard.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

import SwiftData
import Foundation

@Model
final class SDCard {
    @Attribute(.unique) var id: Int
    var word: String
    var imageBase64: String
    var isFavorite: Bool
    var usageCount: Int
    var categoryId: Int?
    var createdAt: Date

    init(from card: Card) {
        self.id          = card.id
        self.word        = card.word
        self.imageBase64 = card.imageBase64
        self.isFavorite  = card.isFavorite
        self.usageCount  = card.usageCount
        self.categoryId  = card.categoryId
        self.createdAt   = card.createdAt
    }

    func toDomain() -> Card {
        Card(
            id:             id,
            word:           word,
            language:       "ru",
            translatedWord: word,
            imageBase64:    imageBase64,
            isFavorite:     isFavorite,
            usageCount:     usageCount,
            categoryId:     categoryId,
            userId:         0,
            createdAt:      createdAt
        )
    }
}
