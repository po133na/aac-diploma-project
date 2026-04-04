//
//  Stubs.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 18.03.2026.
//
// Stubs.swift
import Foundation
import SwiftUI
import SwiftData

// MARK: - LocalizationManager
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: AppLanguage {
        didSet { UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language") }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? ""
        currentLanguage = AppLanguage(rawValue: saved) ?? .russian
    }

    func t(_ ru: String, kk: String, en: String) -> String {
        switch currentLanguage {
        case .russian:  return ru
        case .kazakh:   return kk
        case .english:  return en
        }
    }

    // Первый запуск — язык не выбран
    var isLanguageSelected: Bool {
        UserDefaults.standard.string(forKey: "app_language") != nil
    }
}

// MARK: - AppRouter
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
}

// MARK: - PushNotificationManager
final class PushNotificationManager {
    static let shared = PushNotificationManager()
    func requestAuthorization() {}
}

// MARK: - ThemeType
enum ThemeType: String, CaseIterable {
    case light = "Light"
    case dark  = "Dark"
    var displayName: String { rawValue }
}

// MARK: - AACCard
struct AACCard: View {
    let card: Card
    var onTap: (() -> Void)? = nil
    var onSpeak: (() -> Void)? = nil
    var onFavorite: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(card.word)                       // ← было card.text, теперь card.word
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "1C3F6E"))
            Spacer()
            Button { onSpeak?() } label: {
                Image(systemName: "speaker.wave.2")
                    .foregroundColor(Color(hex: "5BAECC"))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - AACButtonStyle
enum AACButtonStyle {
    case primary, danger, secondary
    var color: Color {
        switch self {
        case .primary:   return Color(hex: "5BAECC")
        case .danger:    return Color(hex: "F87171")
        case .secondary: return Color(hex: "9BB8CC")
        }
    }
}

// MARK: - AACButton
struct AACButton: View {
    let title: String
    var icon: String? = nil
    var style: AACButtonStyle = .primary
    var color: Color? = nil
    let action: () -> Void

    private var buttonColor: Color { color ?? style.color }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(RoundedRectangle(cornerRadius: 14).fill(buttonColor))
        }
    }
}

// MARK: - AACTextField
struct AACTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String = "magnifyingglass"

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "9BB8CC"))
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "EEF5F9"))
        )
    }
}

// MARK: - Localization Keys
struct Gallery      { static var localized: String { "Gallery" } }
struct Favorites    { static var localized: String { "Favourites" } }
struct Folders      { static var localized: String { "Folders" } }
struct RecentCards  { static var localized: String { "Recent Cards" } }
struct CreateFolder { static var localized: String { "Create Folder" } }
struct Profile      { static var localized: String { "Profile" } }
struct Logout       { static var localized: String { "Logout" } }
struct Theme        { static var localized: String { "Theme" } }
struct Notifications { static var localized: String { "Notifications" } }
struct Done         { static var localized: String { "Done" } }
struct Language     { static var localized: String { "Language" } }
struct Settings     { static var localized: String { "Settings" } }
