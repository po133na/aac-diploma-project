////
////  User.swift
////  diploma2
////
////  Created by Symbat Bayanbayeva on 17.03.2026.
////
//import Foundation
//
//struct User: Identifiable, Codable, Equatable {
//    let id: String
//    var name: String
//    var email: String
//    var avatarURL: String?
//    var preferredLanguage: AppLanguage
//    var createdAt: Date
//
//    // Для ProfileView
//    var username: String { name }
//}
//
//enum AppLanguage: String, Codable, CaseIterable {
//    case kazakh  = "kk"
//    case russian = "ru"
//    case english = "en"
//
//    var displayName: String {
//        switch self {
//        case .kazakh:  return "Қазақша"
//        case .russian: return "Русский"
//        case .english: return "English"
//        }
//    }
//}
