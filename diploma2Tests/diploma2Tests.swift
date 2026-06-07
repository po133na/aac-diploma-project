import Testing
@testable import diploma2

struct diploma2Tests {

    // MARK: - Card.ttsInfo(uiLanguage:) tests

    private func makeCard(
        id: Int = 1,
        word: String,
        wordRu: String? = nil,
        wordKk: String? = nil,
        wordEn: String? = nil,
        language: String
    ) -> Card {
        Card(id: id, word: word, wordRu: wordRu, wordKk: wordKk, wordEn: wordEn,
             language: language, translatedWord: "", imageBase64: "", isFavorite: false)
    }

    // Баг 1: карточка создана на казахском, нет перевода на русский →
    // UI русский → TTS должен быть казахским голосом
    @Test("Kazakh card with no Russian translation uses Kazakh TTS on Russian UI")
    func kazakhCardNoRussianTranslation_russianUI_useKazakhTTS() {
        let card = makeCard(word: "алма", wordKk: "алма", language: "kk")
        let (text, lang) = card.ttsInfo(uiLanguage: .russian)
        #expect(lang == .kazakh)
        #expect(text == "алма")
    }

    // Баг 2: карточка из Основ со всеми переводами →
    // UI русский → TTS должен быть русским голосом
    @Test("Basics card with Russian translation uses Russian TTS on Russian UI")
    func basicsCard_russianUI_usesRussianTTS() {
        let card = makeCard(word: "apple", wordRu: "яблоко", wordKk: "алма", wordEn: "apple", language: "en")
        let (text, lang) = card.ttsInfo(uiLanguage: .russian)
        #expect(lang == .russian)
        #expect(text == "яблоко")
    }

    // Баг 3: карточка из Основ → UI казахский → TTS казахским голосом
    @Test("Basics card uses Kazakh TTS on Kazakh UI")
    func basicsCard_kazakhUI_usesKazakhTTS() {
        let card = makeCard(word: "apple", wordRu: "яблоко", wordKk: "алма", wordEn: "apple", language: "en")
        let (text, lang) = card.ttsInfo(uiLanguage: .kazakh)
        #expect(lang == .kazakh)
        #expect(text == "алма")
    }

    // UI английский → TTS английским голосом
    @Test("Basics card uses English TTS on English UI")
    func basicsCard_englishUI_usesEnglishTTS() {
        let card = makeCard(word: "apple", wordRu: "яблоко", wordKk: "алма", wordEn: "apple", language: "en")
        let (text, lang) = card.ttsInfo(uiLanguage: .english)
        #expect(lang == .english)
        #expect(text == "apple")
    }

    // Карточка создана на русском, нет казахского перевода →
    // UI казахский → TTS русским (оригинал карточки)
    @Test("Russian card with no Kazakh translation falls back to card language on Kazakh UI")
    func russianCard_noKazakhTranslation_kazakhUI_usesRussianTTS() {
        let card = makeCard(word: "яблоко", wordRu: "яблоко", language: "ru")
        let (text, lang) = card.ttsInfo(uiLanguage: .kazakh)
        #expect(lang == .russian)
        #expect(text == "яблоко")
    }
}
