//
//  APIEndPoints.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

enum APIEndpoint {
    // Auth
    case login(email: String, password: String)
    case register(name: String, email: String, password: String)
    case logout
    
    // User
    case getProfile
    case updateProfile(name: String, language: String)
    
    // Cards
    case getCards
    case getSavedCards
    case saveCard(card: CardCreate)           // POST /cards
    case deleteCard(cardId: String)           // DELETE /cards/{id}
    case toggleFavorite(cardId: String)       // PATCH /cards/{id}
    
    // Categories (бывшие Folders)
    case getCategories
    case createCategory(name: String, nameKk: String?, nameEn: String?, icon: String?)
    case deleteCategory(categoryId: String)
    
    // AI Features
    case generateImage(word: String, language: String, categoryId: Int?)  // POST /cards/generate
    case textToSpeech(text: String, language: String)                     // POST /tts
    
    var path: String {
        switch self {
        case .login:              return "/auth/login"
        case .register:           return "/auth/register"
        case .logout:             return "/auth/logout"
        case .getProfile:         return "/user/profile"
        case .updateProfile:      return "/user/profile"
        case .getCards:           return "/cards"
        case .getSavedCards:      return "/cards/saved"  // возможно, не используется
        case .saveCard:           return "/cards"
        case .deleteCard(let id): return "/cards/\(id)"
        case .toggleFavorite(let id): return "/cards/\(id)"
        case .getCategories:      return "/categories"
        case .createCategory:     return "/categories"
        case .deleteCategory(let id): return "/categories/\(id)"
        case .generateImage:      return "/cards/generate"
        case .textToSpeech:       return "/tts"
        }
    }
    
    var method: String {
        switch self {
        case .getProfile, .getCards, .getSavedCards, .getCategories: return "GET"
        case .deleteCard, .deleteCategory:                           return "DELETE"
        case .toggleFavorite:                                        return "PATCH"
        default:                                                     return "POST"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .register(let name, let email, let password):
            return ["name": name, "email": email, "password": password]
        case .generateImage(let word, let language, let categoryId):
            var dict: [String: Any] = ["word": word, "language": language]
            if let categoryId = categoryId {
                dict["category_id"] = categoryId
            }
            return dict
        case .textToSpeech(let text, let language):
            return ["text": text, "language": language]
        case .saveCard(let card):
            var dict: [String: Any] = ["word": card.word, "language": card.language]
            if let categoryId = card.categoryId {
                dict["category_id"] = categoryId
            }
            return dict
        case .createCategory(let name, let nameKk, let nameEn, let icon):
            var dict: [String: Any] = ["name": name]
            if let nameKk = nameKk { dict["name_kk"] = nameKk }
            if let nameEn = nameEn { dict["name_en"] = nameEn }
            if let icon = icon { dict["icon"] = icon }
            return dict
        case .toggleFavorite:
            return ["is_favorite": true]  // бэкенд ожидает CardUpdate
        default:
            return nil
        }
    }
}
