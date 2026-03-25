//
//  Services.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 20.03.2026.
//

// Services/CardService.swift

import Foundation

final class CardService {
    private let client = APIClient.shared

    // Получить карточки (с фильтрами)
    func getCards(
        categoryId: Int? = nil,
        favoritesOnly: Bool = false,
        search: String? = nil
    ) async throws -> [Card] {
        var queryItems: [URLQueryItem] = []
        if let categoryId { queryItems.append(.init(name: "category_id", value: "\(categoryId)")) }
        if favoritesOnly   { queryItems.append(.init(name: "favorites_only", value: "true")) }
        if let search      { queryItems.append(.init(name: "search", value: search)) }

        let response: CardListResponse = try await client.request(
            path: "/cards",
            queryItems: queryItems.isEmpty ? nil : queryItems
        )
        return response.cards
    }

    // Создать карточку (AI генерация)
    func createCard(word: String, language: String, categoryId: Int? = nil) async throws -> Card {
        let body = CardCreate(word: word, language: language, categoryId: categoryId)
        return try await client.request(path: "/cards", method: "POST", body: body)
    }

    // Получить карточку по ID
    func getCard(id: Int) async throws -> Card {
        return try await client.request(path: "/cards/\(id)")
    }

    // Обновить карточку (избранное, категория)
    func updateCard(id: Int, isFavorite: Bool? = nil, categoryId: Int? = nil) async throws -> Card {
        let body = CardUpdate(isFavorite: isFavorite, categoryId: categoryId)
        return try await client.request(path: "/cards/\(id)", method: "PATCH", body: body)
    }

    // Добавить/убрать из избранного
    func toggleFavorite(card: Card) async throws -> Card {
        return try await updateCard(id: card.id, isFavorite: !card.isFavorite)
    }

    // Использовать карточку (счётчик +1)
    func useCard(id: Int) async throws -> Card {
        return try await client.request(path: "/cards/\(id)/use", method: "POST")
    }

    // Удалить карточку
    func deleteCard(id: Int) async throws {
        try await client.requestVoid(path: "/cards/\(id)", method: "DELETE")
    }
}

// MARK: - CategoryService

final class CategoryService {
    private let client = APIClient.shared

    // Получить все категории (системные + пользовательские)
    func getCategories() async throws -> [Category] {
        let response: CategoryListResponse = try await client.request(path: "/categories")
        return response.categories
    }

    // Создать пользовательскую категорию
    func createCategory(name: String, nameKk: String? = nil, nameEn: String? = nil, icon: String? = nil) async throws -> Category {
        let body = CategoryCreate(name: name, nameKk: nameKk, nameEn: nameEn, icon: icon)
        return try await client.request(path: "/categories", method: "POST", body: body)
    }

    // Удалить категорию
    func deleteCategory(id: Int) async throws {
        try await client.requestVoid(path: "/categories/\(id)", method: "DELETE")
    }
}

// MARK: - PhraseService

final class PhraseService {
    private let client = APIClient.shared

    // Получить все фразы
    func getPhrases() async throws -> [Phrase] {
        let response: PhraseListResponse = try await client.request(path: "/phrases")
        return response.phrases
    }

    // Получить фразу с полными карточками
    func getPhrase(id: Int) async throws -> PhraseWithCards {
        return try await client.request(path: "/phrases/\(id)")
    }

    // Сохранить фразу из текущих слов
    func createPhrase(name: String, cardIds: [Int]) async throws -> Phrase {
        let body = PhraseCreate(name: name, cardIds: cardIds)
        return try await client.request(path: "/phrases", method: "POST", body: body)
    }

    // Использовать фразу (счётчик +1)
    func usePhrase(id: Int) async throws -> Phrase {
        return try await client.request(path: "/phrases/\(id)/use", method: "POST")
    }

    // Озвучить всю фразу
    func speakPhrase(id: Int, language: AppLanguage) async throws -> TTSResponse {
        return try await client.request(
            path: "/phrases/\(id)/speak",
            method: "POST",
            queryItems: [.init(name: "language", value: language.rawValue)]
        )
    }

    // Удалить фразу
    func deletePhrase(id: Int) async throws {
        try await client.requestVoid(path: "/phrases/\(id)", method: "DELETE")
    }
}

// MARK: - TTSService

import AVFoundation

@MainActor
final class TTSService: ObservableObject {
    private let client = APIClient.shared
    private var audioPlayer: AVAudioPlayer?

    // Офлайн-синтезатор (fallback)
    private let synthesizer = AVSpeechSynthesizer()

    @Published var isSpeaking = false

    // Основной метод — пробует API, fallback на AVFoundation
    func speak(text: String, language: AppLanguage) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSpeaking = true
        defer { isSpeaking = false }

        do {
            // Пробуем API
            let body = TTSRequestBody(text: text, language: language.rawValue)
            let response: TTSResponse = try await client.request(
                path: "/tts",
                method: "POST",
                body: body
            )
            await playAudioBase64(response.audioBase64)
        } catch {
            // Fallback: AVFoundation (офлайн)
            speakLocally(text: text, language: language)
        }
    }

    // Озвучить фразу через phraseId
    func speakPhrase(id: Int, language: AppLanguage) async {
        isSpeaking = true
        defer { isSpeaking = false }

        do {
            let response: TTSResponse = try await client.request(
                path: "/phrases/\(id)/speak",
                method: "POST",
                queryItems: [.init(name: "language", value: language.rawValue)]
            )
            await playAudioBase64(response.audioBase64)
        } catch {
            // Fallback
        }
    }

    func stop() {
        audioPlayer?.stop()
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    // MARK: Private

    private func playAudioBase64(_ base64: String) async {
        guard let data = Data(base64Encoded: base64) else { return }
        do {
            // Настройка аудио сессии
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.play()
        } catch {
            print("Audio play error: \(error)")
        }
    }

    private func speakLocally(text: String, language: AppLanguage) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        utterance.rate = 0.45
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
}

private struct TTSRequestBody: Encodable {
    let text: String
    let language: String
}

// MARK: - StatsService (когда бэкендер добавит /user/stats)

final class StatsService {
    private let client = APIClient.shared

    func getStats() async throws -> UserStats {
        // TODO: раскомментировать когда бэкендер добавит endpoint
        // return try await client.request(path: "/user/stats")

        // Пока возвращаем мок
        return UserStats(
            cardsThisWeek: 0,
            totalCards: 0,
            currentStreak: 0,
            weeklyData: [0.3, 0.5, 0.4, 0.7, 0.6, 0.85, 1.0]
        )
    }
}
