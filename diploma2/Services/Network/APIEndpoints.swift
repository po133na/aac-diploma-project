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
    case saveCard(cardId: String)
    case deleteCard(cardId: String)
    
    // Folders
    case getFolders
    case createFolder(name: String, emoji: String?)
    case deleteFolder(folderId: String)
    
    // AI Features
    case generateImage(prompt: String)
    case textToSpeech(text: String, language: String)
    
    var path: String {
        switch self {
        case .login:              return "/auth/login"
        case .register:           return "/auth/register"
        case .logout:             return "/auth/logout"
        case .getProfile:         return "/user/profile"
        case .updateProfile:      return "/user/profile"
        case .getCards:           return "/cards"
        case .getSavedCards:      return "/cards/saved"
        case .saveCard(let id):   return "/cards/\(id)/save"
        case .deleteCard(let id): return "/cards/\(id)"
        case .getFolders:         return "/folders"
        case .createFolder:       return "/folders"
        case .deleteFolder(let id): return "/folders/\(id)"
        case .generateImage:      return "/ai/image"
        case .textToSpeech:       return "/ai/tts"
        }
    }
    
    var method: String {
        switch self {
        case .getProfile, .getCards, .getSavedCards, .getFolders: return "GET"
        case .deleteCard, .deleteFolder:                           return "DELETE"
        case .saveCard, .updateProfile:                           return "PATCH"
        default:                                                   return "POST"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .register(let name, let email, let password):
            return ["name": name, "email": email, "password": password]
        case .generateImage(let prompt):
            return ["prompt": prompt]
        case .textToSpeech(let text, let language):
            return ["text": text, "language": language]
        case .createFolder(let name, let emoji):
            return ["name": name, "emoji": emoji ?? ""]
        default:
            return nil
        }
    }
}
