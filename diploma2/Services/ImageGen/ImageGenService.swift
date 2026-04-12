//
//  ImageGenService.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

import Foundation
private struct ImageGenRequest: Encodable {
    let word: String
    let language: String
    let categoryId: Int?
    let style: String
    
    enum CodingKeys: String, CodingKey {
        case word, language, style
        case categoryId = "category_id"
    }
}

final class ImageGenService {
    static let shared = ImageGenService()
    private let client = APIClient.shared
    
    private init() {}
    
    func generateImage(
        word: String,
        language: String,
        categoryId: Int? = nil,
        style: String = "cartoon"
    ) async throws -> Card {
        let body = ImageGenRequest(
            word: word,
            language: language,
            categoryId: categoryId,
            style: style
        )
        return try await client.request(
            path: "/cards/generate",
            method: "POST",
            body: body,
            timeout: 180  // AI-генерация может занимать до 60–120 сек
        )
    }
}

// Расширение для работы с NSNull в Encodable
extension NSNull: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
