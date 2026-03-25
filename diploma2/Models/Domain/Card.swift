////
////  Card.swift
////  diploma2
////
////  Created by Symbat Bayanbayeva on 17.03.2026.
////
//import Foundation
//
//struct Card: Identifiable, Codable, Equatable {
//    let id: String
//    var text: String
//    var imageURL: String?
//    var localImagePath: String?
//    var audioURL: String?
//    var isSaved: Bool
//    var folderId: String?
//    var createdAt: Date
//    var source: CardSource
//
//    static let mock = Card(
//        id: "1", text: "Hello", imageURL: nil,
//        localImagePath: nil, audioURL: nil,
//        isSaved: false, folderId: nil,
//        createdAt: Date(), source: .manual
//    )
//}
//
//enum CardSource: String, Codable {
//    case generated, photo, manual
//}
