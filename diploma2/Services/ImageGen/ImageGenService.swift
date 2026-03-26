//
//  ImageGenService.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

import Foundation

final class ImageGenService {
    static let shared = ImageGenService()
    private let client = APIClient.shared
    
    private init() {}
    
    /// Генерация изображения для слова
    /// - Parameters:
    ///   - word: слово на русском или казахском
    ///   - language: "ru" или "kk"
    ///   - categoryId: опциональный ID категории
    ///   - style: стиль изображения ("cartoon", "realistic", "watercolor", "simple")
    /// - Returns: сгенерированное изображение в base64 и слово на английском (translated_word)
    func generateImage(word: String, language: String, categoryId: Int? = nil, style: String = "cartoon") async throws -> CardGenerateResponse {
        let body: [String: Any] = [
            "word": word,
            "language": language,
            "category_id": categoryId ?? NSNull(),
            "style": style
        ]
        let response: CardGenerateResponse = try await client.request(
            path: "/cards/generate",
            method: "POST",
            body: body
        )
        return response
    }
}

// Модель ответа генерации (должна быть в Models.swift, но добавим на случай отсутствия)
struct CardGenerateResponse: Codable {
    let word: String
    let language: String
    let translated_word: String
    let image_base64: String
    let category_id: Int?
}

// Расширение для работы с NSNull в Encodable
extension NSNull: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}