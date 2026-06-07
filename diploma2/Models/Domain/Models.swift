//
//  Models.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 20.03.2026.
//

import Foundation
import SwiftUI

// MARK: - User

struct User: Identifiable, Codable, Equatable {
    let id: Int                         // бэкенд: Int
    var email: String
    var username: String                // бэкенд: username (First + Last склеенные)
    var createdAt: Date

    var name: String { username }       // алиас для UI

    enum CodingKeys: String, CodingKey {
        case id, email, username
        case createdAt = "created_at"
    }
}

// MARK: - Token

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType   = "token_type"
    }
}

// MARK: - Category (бэкенд называет Category, не Folder)

struct Category: Identifiable, Codable, Equatable {
    let id: Int
    var name: String                    // русское название
    var nameKk: String?                 // казахское
    var nameEn: String?                 // английское
    var icon: String?                   // emoji
    var coverImageBase64: String?       // обложка категории (base64)
    var userId: Int?                    // nil = системная
    var createdAt: Date
    var updatedAt: Date?

    var isSystem: Bool { userId == nil }

    // Локализованное название по языку
    func localizedName(language: AppLanguage) -> String {
        switch language {
        case .kazakh:  return nameKk ?? name
        case .english: return nameEn ?? name
        case .russian: return name
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, icon
        case nameKk          = "name_kk"
        case nameEn          = "name_en"
        case coverImageBase64 = "cover_image_base64"
        case userId          = "user_id"
        case createdAt       = "created_at"
        case updatedAt       = "updated_at"
    }
}

struct CategoryListResponse: Codable {
    let categories: [Category]
    let total: Int
}

struct CategoryCreate: Codable {
    let name: String
    let nameKk: String?
    let nameEn: String?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case name, icon
        case nameKk = "name_kk"
        case nameEn = "name_en"
    }
}

// MARK: - Card

struct Card: Identifiable, Codable, Equatable {
    let id: Int
    var word: String
    var wordRu: String?                 // русское название (новое поле бэка)
    var wordKk: String?                 // казахское название
    var wordEn: String?                 // английское название
    var language: String                // "ru" | "kk" | "en"
    var translatedWord: String          // перевод на английский (для промпта)
    var imageBase64: String             // base64 PNG
    var isFavorite: Bool
    var usageCount: Int
    var categoryId: Int?
    var userId: Int?
    var createdAt: Date
    var updatedAt: Date?

    // Декодируем base64 в UIImage
    var image: UIImage? {
        guard let data = Data(base64Encoded: imageBase64) else { return nil }
        return UIImage(data: data)
    }

    // Локализованное слово
    func localizedWord(language: AppLanguage) -> String {
        switch language {
        case .russian: return wordRu ?? word
        case .kazakh:  return wordKk ?? word
        case .english: return wordEn ?? word
        }
    }

    // Слово И язык для TTS: если перевод на язык UI существует → используем его.
    // Если нет — возвращаем оригинальное слово с оригинальным языком карточки.
    // Это гарантирует что казахская карточка без перевода произносится казахским голосом
    // даже при русском интерфейсе.
    func ttsInfo(uiLanguage: AppLanguage) -> (text: String, language: AppLanguage) {
        switch uiLanguage {
        case .russian:
            if let ru = wordRu { return (ru, .russian) }
        case .kazakh:
            if let kk = wordKk { return (kk, .kazakh) }
        case .english:
            if let en = wordEn { return (en, .english) }
        }
        let cardLang = AppLanguage(rawValue: language) ?? uiLanguage
        return (word, cardLang)
    }

    enum CodingKeys: String, CodingKey {
        case id, word, language
        case wordRu         = "word_ru"
        case wordKk         = "word_kk"
        case wordEn         = "word_en"
        case translatedWord = "translated_word"
        case imageBase64    = "image_base64"
        case isFavorite     = "is_favorite"
        case usageCount     = "usage_count"
        case categoryId     = "category_id"
        case userId         = "user_id"
        case createdAt      = "created_at"
        case updatedAt      = "updated_at"
    }

    // Кастомный init: image_base64 может прийти null для системных карточек
    init(from decoder: Decoder) throws {
        let c        = try decoder.container(keyedBy: CodingKeys.self)
        id           = try c.decode(Int.self,    forKey: .id)
        word         = try c.decode(String.self, forKey: .word)
        wordRu       = try c.decodeIfPresent(String.self, forKey: .wordRu)
        wordKk       = try c.decodeIfPresent(String.self, forKey: .wordKk)
        wordEn       = try c.decodeIfPresent(String.self, forKey: .wordEn)
        language     = try c.decode(String.self, forKey: .language)
        translatedWord = (try? c.decode(String.self, forKey: .translatedWord)) ?? ""
        imageBase64  = (try? c.decode(String.self, forKey: .imageBase64)) ?? ""
        isFavorite   = (try? c.decode(Bool.self,   forKey: .isFavorite))   ?? false
        usageCount   = (try? c.decode(Int.self,    forKey: .usageCount))   ?? 0
        categoryId   = try c.decodeIfPresent(Int.self, forKey: .categoryId)
        userId       = try c.decodeIfPresent(Int.self, forKey: .userId)
        createdAt    = (try? c.decode(Date.self, forKey: .createdAt)) ?? Date()
        updatedAt    = try c.decodeIfPresent(Date.self, forKey: .updatedAt)
    }

    // Явный memberwise init (нужен т.к. добавили custom decoder)
    init(id: Int, word: String, wordRu: String? = nil, wordKk: String? = nil,
         wordEn: String? = nil, language: String, translatedWord: String,
         imageBase64: String, isFavorite: Bool, usageCount: Int = 0,
         categoryId: Int? = nil, userId: Int? = nil,
         createdAt: Date = Date(), updatedAt: Date? = nil) {
        self.id            = id
        self.word          = word
        self.wordRu        = wordRu
        self.wordKk        = wordKk
        self.wordEn        = wordEn
        self.language      = language
        self.translatedWord = translatedWord
        self.imageBase64   = imageBase64
        self.isFavorite    = isFavorite
        self.usageCount    = usageCount
        self.categoryId    = categoryId
        self.userId        = userId
        self.createdAt     = createdAt
        self.updatedAt     = updatedAt
    }
}

struct CardListResponse: Codable {
    let cards: [Card]
    let total: Int
}

struct CardCreate: Codable {
    let word: String
    let language: String      // "ru" | "kk"
    let categoryId: Int?
    let style: String?        // "cartoon", "realistic", "watercolor", "simple"

    enum CodingKeys: String, CodingKey {
        case word, language, style
        case categoryId = "category_id"
    }
}

struct CardSaveBody: Codable {
    let word: String
    let language: String
    let translatedWord: String
    let imageBase64: String
    let categoryId: Int?

    enum CodingKeys: String, CodingKey {
        case word, language
        case translatedWord = "translated_word"
        case imageBase64 = "image_base64"
        case categoryId = "category_id"
    }
}

struct CardUpdate: Codable {
    var word: String?
    var isFavorite: Bool?
    var categoryId: Int?

    enum CodingKeys: String, CodingKey {
        case word
        case isFavorite = "is_favorite"
        case categoryId = "category_id"
    }
}

// MARK: - Phrase (сохранённая фраза из карточек)

struct Phrase: Identifiable, Codable, Equatable {
    let id: Int
    var name: String
    var cardIds: [Int]
    var userId: Int
    var usageCount: Int
    var createdAt: Date
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name
        case cardIds    = "card_ids"
        case userId     = "user_id"
        case usageCount = "usage_count"
        case createdAt  = "created_at"
        case updatedAt  = "updated_at"
    }
}

struct PhraseWithCards: Identifiable, Codable {
    let id: Int
    var name: String
    var cards: [Card]
    var usageCount: Int
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, cards
        case usageCount = "usage_count"
        case createdAt  = "created_at"
    }
}

struct PhraseListResponse: Codable {
    let phrases: [Phrase]
    let total: Int
}

struct PhraseCreate: Codable {
    let name: String
    let cardIds: [Int]

    enum CodingKeys: String, CodingKey {
        case name
        case cardIds = "card_ids"
    }
}

// MARK: - TTS

//struct TTSResponse: Codable {
//    let audioBase64: String
//    let format: String
//
//    enum CodingKeys: String, CodingKey {
//        case audioBase64 = "audio_base64"
//        case format
//    }
//}

// MARK: - Stats

struct UserStats: Codable {
    let totalCards: Int
    let totalPhrases: Int
    let totalCardUses: Int
    let totalPhraseUses: Int
    let topCards: [TopCard]
    let topPhrases: [TopPhrase]
    let memberSince: Date
    let thisWeekCards: Int
    let currentStreak: Int
    let weeklyData: [Double]?   // 7 значений для бар-чарта (опционально)

    enum CodingKeys: String, CodingKey {
        case totalCards = "total_cards"
        case totalPhrases = "total_phrases"
        case totalCardUses = "total_card_uses"
        case totalPhraseUses = "total_phrase_uses"
        case topCards = "top_cards"
        case topPhrases = "top_phrases"
        case memberSince = "member_since"
        case thisWeekCards = "this_week_cards"
        case currentStreak = "current_streak"
        case weeklyData = "weekly_data"
    }
}

struct TopCard: Codable {
    let id: Int
    let word: String
    let wordRu: String?
    let wordKk: String?
    let wordEn: String?
    let usageCount: Int

    func localizedWord(language: AppLanguage) -> String {
        switch language {
        case .russian: return wordRu ?? word
        case .kazakh:  return wordKk ?? word
        case .english: return wordEn ?? word
        }
    }

    func ttsInfo(uiLanguage: AppLanguage) -> (text: String, language: AppLanguage) {
        switch uiLanguage {
        case .russian:
            if let ru = wordRu { return (ru, .russian) }
        case .kazakh:
            if let kk = wordKk { return (kk, .kazakh) }
        case .english:
            if let en = wordEn { return (en, .english) }
        }
        return (word, uiLanguage)
    }

    enum CodingKeys: String, CodingKey {
        case id, word
        case wordRu     = "word_ru"
        case wordKk     = "word_kk"
        case wordEn     = "word_en"
        case usageCount = "usage_count"
    }
}

struct TopPhrase: Codable {
    let id: Int
    let name: String
    let usageCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case usageCount = "usage_count"
    }
}

// MARK: - AppLanguage

enum AppLanguage: String, Codable, CaseIterable {
    case kazakh  = "kk"
    case russian = "ru"
    case english = "en"

    var displayName: String {
        switch self {
        case .kazakh:  return "Қазақша"
        case .russian: return "Русский"
        case .english: return "English"
        }
    }

    var flag: String {
        switch self {
        case .kazakh:  return "🇰🇿"
        case .russian: return "🇷🇺"
        case .english: return "🇬🇧"
        }
    }

    // Язык для создания карточек (бэкенд не поддерживает "en")
    var cardLanguage: String {
        switch self {
        case .kazakh:  return "kk"
        case .russian: return "ru"
        case .english: return "en"
        }
    }
}

// MARK: - MessageResponse

struct MessageResponse: Codable {
    let message: String
}

// MARK: - Sync (офлайн режим)

struct DeletedItemResponse: Codable {
    let entityType: String   // "card", "category", "phrase"
    let entityId: Int
    let deletedAt: Date

    enum CodingKeys: String, CodingKey {
        case entityType = "entity_type"
        case entityId   = "entity_id"
        case deletedAt  = "deleted_at"
    }
}

struct SyncResponse: Codable {
    let cards: [Card]
    let categories: [Category]
    let phrases: [Phrase]
    let deleted: [DeletedItemResponse]
    let syncedAt: Date   // iOS сохраняет как новый since

    enum CodingKeys: String, CodingKey {
        case cards, categories, phrases, deleted
        case syncedAt = "synced_at"
    }
}
