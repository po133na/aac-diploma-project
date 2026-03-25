//
//  ThemeManager.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//
import SwiftUI

struct AppTheme {
    let background: Color
    let surface: Color
    let cardBackground: Color   // ← добавили
    let textPrimary: Color
    let textSecondary: Color
    let primary: Color
    let type: ThemeType        // ← добавили


    static let light = AppTheme(
        background: Color(hex: "F8F9FF"),
        surface: Color.white,
        cardBackground: Color.white,
        textPrimary: Color(hex: "1C3F6E"),
        textSecondary: Color(hex: "6B8BAE"),
        primary: Color(hex: "5BAECC"),
        type: .light
    )
    static let dark = AppTheme(
        background: Color(hex: "1E1E2E"),
        surface: Color(hex: "2A2A3E"),
        cardBackground: Color(hex: "2A2A3E"),
        textPrimary: Color.white,
        textSecondary: Color(hex: "9CA3AF"),
        primary: Color(hex: "5BAECC"),
        type: .dark
    )
}

final class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode") }
    }
    var currentTheme: AppTheme { isDarkMode ? .dark : .light }
    var colorScheme: ColorScheme { isDarkMode ? .dark : .light }
    init() { self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode") }
}
