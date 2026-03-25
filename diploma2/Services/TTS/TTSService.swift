//
//  TTSService.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

import AVFoundation
import Foundation

@MainActor
final class TTSService: ObservableObject {
    static let shared = TTSService()
    
    private let synthesizer = AVSpeechSynthesizer()
    private let client = APIClient.shared
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    /// Озвучивание текста через бэкенд TTS
    /// - Parameters:
    ///   - text: текст для озвучки
    ///   - language: код языка ("ru", "kk", "en")
    func speak(text: String, language: String) async {
        do {
            let response: TTSResponse = try await client.request(
                path: "/tts",
                method: "POST",
                body: ["text": text, "language": language]
            )
            // Декодируем base64 аудио
            guard let audioData = Data(base64Encoded: response.audioBase64) else {
                throw NSError(domain: "TTS", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid base64 audio"])
            }
            try await playAudio(data: audioData)
        } catch {
            print("Онлайн TTS не сработал: \(error). Используем офлайн AVFoundation.")
            // Fallback на AVFoundation
            speakLocally(text: text, language: language)
        }
    }
    
    /// Офлайн TTS через AVFoundation (только для ru, en, kk?)
    private func speakLocally(text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.45
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
    
    /// Воспроизведение аудио из данных
    private func playAudio(data: Data) async throws {
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer?.play()
        // Ждём окончания воспроизведения
        while let player = audioPlayer, player.isPlaying {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 сек
        }
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
    }
}

struct TTSResponse: Codable {
    let audioBase64: String
    
    enum CodingKeys: String, CodingKey {
        case audioBase64 = "audio_base64"
    }
}