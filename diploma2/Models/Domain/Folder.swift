////
////  Folder.swift
////  diploma2
////
////  Created by Symbat Bayanbayeva on 17.03.2026.
////
//import Foundation
//
//struct Folder: Identifiable, Codable, Equatable {
//    let id: String
//    var name: String
//    var emoji: String?
//    var colorHex: String?
//    var cardCount: Int
//    var cardIds: [String]
//    var createdAt: Date
//
//    // Для GalleryView
//    var iconName: String { "folder.fill" }
//    var color: String   { colorHex ?? "5BAECC" }
//
//    static let mock = Folder(
//        id: "1", name: "My Folder", emoji: "📁",
//        colorHex: nil, cardCount: 0, cardIds: [],
//        createdAt: Date()
//    )
//    static let mockFavorites = Folder(
//        id: "favorites", name: "Favourites", emoji: "⭐️",
//        colorHex: nil, cardCount: 0, cardIds: [],
//        createdAt: Date()
//    )
//}
