// Features/Profile/ViewModels/ProfileViewModel.swift
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var stats: UserStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var largeText: Bool {
        didSet {
            UserDefaults.standard.set(largeText, forKey: "large_text")
            ThemeManager.shared.isLargeText = largeText
        }
    }
    @Published var darkTheme: Bool {
        didSet {
            UserDefaults.standard.set(darkTheme, forKey: "high_contrast")
            ThemeManager.shared.isHighContrast = darkTheme
        }
    }

    private let statsService = StatsService()
    private let authService  = AuthService()

    init() {
        largeText = UserDefaults.standard.bool(forKey: "large_text")
        darkTheme = UserDefaults.standard.bool(forKey: "high_contrast")

        ThemeManager.shared.isLargeText    = largeText
        ThemeManager.shared.isHighContrast = darkTheme
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
