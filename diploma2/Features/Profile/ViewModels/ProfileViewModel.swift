// Features/Profile/ViewModels/ProfileViewModel.swift
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var stats: UserStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var ttsEnabled: Bool {
        didSet { UserDefaults.standard.set(ttsEnabled, forKey: "tts_enabled") }
    }
    @Published var autoSpeak: Bool {
        didSet { UserDefaults.standard.set(autoSpeak, forKey: "auto_speak") }
    }
    @Published var largeText: Bool {
        didSet { UserDefaults.standard.set(largeText, forKey: "large_text") }
    }
    @Published var highContrast: Bool {
        didSet { UserDefaults.standard.set(highContrast, forKey: "high_contrast") }
    }

    private let statsService = StatsService()
    private let authService  = AuthService()

    init() {
        ttsEnabled   = UserDefaults.standard.object(forKey: "tts_enabled") as? Bool ?? true
        autoSpeak    = UserDefaults.standard.bool(forKey: "auto_speak")
        largeText    = UserDefaults.standard.bool(forKey: "large_text")
        highContrast = UserDefaults.standard.bool(forKey: "high_contrast")
    }

    func loadStats() async {
        isLoading = true
        defer { isLoading = false }
        stats = try? await statsService.getStats()
    }

    func changePassword(old: String, new: String) async throws {
        _ = try await authService.changePassword(old: old, new: new)
    }

    func updateProfile(username: String) async { /* TODO */ }
    func deleteAccount() async { /* TODO */ }
}

