////
////  TTSService.swift
////  diploma2
////
////  Created by Symbat Bayanbayeva on 17.03.2026.
////
//
//import AVFoundation
//
//@MainActor
//final class TTSService: ObservableObject {
//    private let synthesizer = AVSpeechSynthesizer()
//    
//    // Онлайн TTS через бэкенд
//    func speak(text: String, language: AppLanguage) async {
//        do {
//            // Попытка использовать API TTS
//            let response = try await APIClient.shared.request(
//                .textToSpeech(text: text, language: language.rawValue),
//                responseType: TTSResponse.self
//            )
//            // Воспроизведение аудио из URL
//            await playAudioFromURL(response.audioURL)
//        } catch {
//            // Fallback: AVFoundation (офлайн)
//            speakLocally(text: text, language: language)
//        }
//    }
//    
//    // Офлайн TTS через AVFoundation
//    private func speakLocally(text: String, language: AppLanguage) {
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
//        utterance.rate = 0.45
//        utterance.volume = 1.0
//        synthesizer.speak(utterance)
//    }
//    
//    func stopSpeaking() {
//        synthesizer.stopSpeaking(at: .immediate)
//    }
//    
//    private func playAudioFromURL(_ urlString: String) async { /* TODO */ }
//}
//
//struct TTSResponse: Codable {
//    let audioURL: String
//}
