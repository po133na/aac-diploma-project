//
//  Services.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 20.03.2026.
//

// Services.swift

import Foundation

final class CardService {
    static let shared = CardService()  // ← добавить
    private init() {}                  // ← добавить

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
    func createCard(word: String, language: String, categoryId: Int? = nil, style: String = "cartoon") async throws -> Card {
        let body = CardCreate(word: word, language: language, categoryId: categoryId, style: style)
        return try await client.request(path: "/cards", method: "POST", body: body)
    }

    // Сохранить уже сгенерированную карточку (без повторной генерации)
    func saveCard(word: String, language: String, translatedWord: String, imageBase64: String, categoryId: Int?) async throws -> Card {
        let body = CardSaveBody(word: word, language: language, translatedWord: translatedWord, imageBase64: imageBase64, categoryId: categoryId)
        return try await client.request(path: "/cards/save", method: "POST", body: body)
    }

    // Получить карточку по ID
    func getCard(id: Int) async throws -> Card {
        return try await client.request(path: "/cards/\(id)")
    }

    // Обновить карточку (слово, избранное, категория)
    func updateCard(id: Int, word: String? = nil, isFavorite: Bool? = nil, categoryId: Int? = nil) async throws -> Card {
        let body = CardUpdate(word: word, isFavorite: isFavorite, categoryId: categoryId)
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

    // Генерация и сохранение в "Unassigned" категорию (POST /cards/generate)
    func generateCard(word: String, language: String, categoryId: Int? = nil) async throws -> Card {
        let body = CardCreate(word: word, language: language, categoryId: categoryId, style: nil)
        return try await client.request(path: "/cards/generate", method: "POST", body: body)
    }

    // Перегенерация изображения карточки по тому же слову
    func regenerateCard(id: Int) async throws -> Card {
        return try await client.request(path: "/cards/\(id)/regenerate", method: "POST")
    }
}

// MARK: - CategoryService

final class CategoryService {
    static let shared = CategoryService()  // ← добавить
    private init() {}
    
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

    // Загрузить обложку из галереи/камеры
    func uploadCover(categoryId: Int, imageBase64: String) async throws -> Category {
        struct Body: Encodable { let image_base64: String }
        return try await client.request(
            path: "/categories/\(categoryId)/cover",
            method: "POST",
            body: Body(image_base64: imageBase64)
        )
    }

    // Сгенерировать обложку через AI
    func generateCover(categoryId: Int, prompt: String? = nil) async throws -> Category {
        struct Body: Encodable { let prompt: String? }
        return try await client.request(
            path: "/categories/\(categoryId)/cover/generate",
            method: "POST",
            body: Body(prompt: prompt)
        )
    }

    // Bulk переназначение карточек в категорию
    func assignCards(categoryId: Int, cardIds: [Int]) async throws {
        struct Body: Encodable { let card_ids: [Int] }
        let bodyData = try JSONEncoder().encode(Body(card_ids: cardIds))
        try await client.requestVoidWithBody(
            path: "/categories/\(categoryId)/cards",
            method: "POST",
            bodyData: bodyData
        )
    }
}

//// MARK: - PhraseService
//
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
//
//// MARK: - TTSService
//
import AVFoundation

@MainActor
final class TTSService: ObservableObject {
    static let shared = TTSService()
    private init() {}

    private let client = APIClient.shared
    private var audioPlayer: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()

    private let voiceLocales: [AppLanguage: [String]] = [
        .russian: ["ru-RU", "ru"],
        .kazakh:  ["kk-KZ", "kk", "ru-RU"],
        .english: ["en-US", "en-GB", "en"]
    ]

    @Published var isSpeaking = false

    // Карточка по ID — пробует POST /tts/card/{id}?language=, fallback на speakLocally
    func speakCard(id: Int, language: AppLanguage, fallbackText: String) async {
        let trimmed = fallbackText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        stop()
        isSpeaking = true
        defer { isSpeaking = false }

        if id > 0 {
            do {
                let response: TTSResponse = try await client.request(
                    path: "/tts/card/\(id)",
                    method: "POST",
                    queryItems: [.init(name: "language", value: language.rawValue)],
                    timeout: 5
                )
                playAudioBase64(response.audioBase64)
                return
            } catch {}
        }
        speakLocally(text: trimmed, language: language)
    }

    // Одиночное слово/текст — пробует API (5 сек), fallback на AVSpeechSynthesizer
    func speak(text: String, language: AppLanguage) async {
        let text = text.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        stop()
        isSpeaking = true
        defer { isSpeaking = false }

        do {
            let body = TTSRequestBody(text: text, language: language.rawValue)
            let response: TTSResponse = try await client.request(
                path: "/tts",
                method: "POST",
                body: body,
                timeout: 5
            )
            playAudioBase64(response.audioBase64)
        } catch {
            speakLocally(text: text, language: language)
        }
    }

    // Предложение из карточек — сразу AVSpeechSynthesizer (мгновенно, без сети)
    func speakWords(words: [String], language: AppLanguage) {
        guard !words.isEmpty else { return }
        stop()
        speakLocally(text: words.joined(separator: " "), language: language)
    }

    // Предложение с пословным языком — каждый токен в своей озвучке
    func speakTokens(_ pairs: [(text: String, language: AppLanguage)]) {
        let filtered = pairs.filter { !$0.text.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !filtered.isEmpty else { return }
        stop()
        for pair in filtered {
            let utterance = AVSpeechUtterance(string: pair.text.trimmingCharacters(in: .whitespaces))
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
            utterance.volume = 1.0
            let candidates = voiceLocales[pair.language] ?? ["en-US"]
            utterance.voice = candidates.lazy
                .compactMap { AVSpeechSynthesisVoice(language: $0) }
                .first
            synthesizer.speak(utterance)
        }
    }

    // Фраза по ID — пробует API (5 сек), fallback на локальный
    func speakPhrase(id: Int, language: AppLanguage) async {
        isSpeaking = true
        defer { isSpeaking = false }
        do {
            let response: TTSResponse = try await client.request(
                path: "/phrases/\(id)/speak",
                method: "POST",
                queryItems: [.init(name: "language", value: language.rawValue)],
                timeout: 5
            )
            playAudioBase64(response.audioBase64)
        } catch { }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        isSpeaking = false
    }

    // MARK: - Private

    private func playAudioBase64(_ base64: String) {
        guard let data = Data(base64Encoded: base64) else {
            print("[TTS] Invalid base64 audio data")
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("[TTS] AVAudioPlayer error: \(error)")
        }
    }

    private func speakLocally(text: String, language: AppLanguage) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        utterance.volume = 1.0
        let candidates = voiceLocales[language] ?? ["en-US"]
        utterance.voice = candidates.lazy
            .compactMap { AVSpeechSynthesisVoice(language: $0) }
            .first
        synthesizer.speak(utterance)
    }
}

private struct TTSRequestBody: Encodable {
    let text: String
    let language: String
}

struct TTSResponse: Codable {
    let audioBase64: String
    
    enum CodingKeys: String, CodingKey {
        case audioBase64 = "audio_base64"
    }
}

// MARK: - StatsService

final class StatsService {
    private let client = APIClient.shared

    func getStats() async throws -> UserStats {
        return try await client.request(path: "/user/statistics")
    }
}


