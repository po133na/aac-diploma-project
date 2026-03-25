////
////  CardService.swift
////  diploma2
////
////  Created by Symbat Bayanbayeva on 17.03.2026.
////
//
//import Foundation
//
//final class CardService {
//    static let shared = CardService()
//    private let client = APIClient.shared
//    
//    private init() {}
//    
//    // MARK: - Cards
//    
//    func fetchCards() async throws -> [Card] {
//        let response: CardListResponse = try await client.request(
//            path: "/cards",
//            method: "GET"
//        )
//        return response.cards
//    }
//    
//    func saveCard(_ card: CardCreate) async throws -> Card {
//        let response: Card = try await client.request(
//            path: "/cards",
//            method: "POST",
//            body: card
//        )
//        return response
//    }
//    
//    func deleteCard(id: Int) async throws {
//        let _: EmptyResponse = try await client.request(
//            path: "/cards/\(id)",
//            method: "DELETE"
//        )
//    }
//    
//    func toggleFavorite(id: Int) async throws -> Card {
//        let response: Card = try await client.request(
//            path: "/cards/\(id)",
//            method: "PATCH",
//            body: ["is_favorite": true]  // бэкенд ожидает CardUpdate
//        )
//        return response
//    }
//    
//    // MARK: - Categories
//    
//    func fetchCategories() async throws -> [Category] {
//        let response: CategoryListResponse = try await client.request(
//            path: "/categories",
//            method: "GET"
//        )
//        return response.categories
//    }
//    
//    func createCategory(name: String, nameKk: String?, nameEn: String?, icon: String?) async throws -> Category {
//        let body: [String: Any] = [
//            "name": name,
//            "name_kk": nameKk ?? NSNull(),
//            "name_en": nameEn ?? NSNull(),
//            "icon": icon ?? NSNull()
//        ]
//        // APIClient ожидает Encodable, поэтому используем Dictionary
//        let response: Category = try await client.request(
//            path: "/categories",
//            method: "POST",
//            body: body
//        )
//        return response
//    }
//    
//    func deleteCategory(id: Int) async throws {
//        let _: EmptyResponse = try await client.request(
//            path: "/categories/\(id)",
//            method: "DELETE"
//        )
//    }
//}
//
//// MARK: - Helper extension for Dictionary as Encodable
//
//extension Dictionary: Encodable where Key: Encodable, Value: Encodable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: DynamicCodingKey.self)
//        for (key, value) in self {
//            let codingKey = DynamicCodingKey(stringValue: "\(key)")!
//            try container.encode(value, forKey: codingKey)
//        }
//    }
//}
//
//private struct DynamicCodingKey: CodingKey {
//    var stringValue: String
//    var intValue: Int?
//    
//    init?(stringValue: String) {
//        self.stringValue = stringValue
//        self.intValue = nil
//    }
//    
//    init?(intValue: Int) {
//        self.stringValue = "\(intValue)"
//        self.intValue = intValue
//    }
//}
