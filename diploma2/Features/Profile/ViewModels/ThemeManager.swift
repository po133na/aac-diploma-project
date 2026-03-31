//
//  Profile/ViewModels/ThemeManager.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 26.03.2026.
//

import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var isLargeText: Bool {
        didSet {
            UserDefaults.standard.set(isLargeText, forKey: "large_text")
            updateFontSizes()
        }
    }
    
    @Published var isHighContrast: Bool {
        didSet {
            UserDefaults.standard.set(isHighContrast, forKey: "high_contrast")
            updateColors()
        }
    }
    
    @Published var fontSizeScale: CGFloat = 1.0
    @Published var currentColors: ThemeColors = .standard
    
    private var cancellables = Set<AnyCancellable>()
    // Добавь в ThemeManager
    var colorScheme: ColorScheme? {
        isHighContrast ? .light : nil
    }

    var currentTheme: ThemeColors {
        currentColors  // просто алиас
    }
    init() {
        self.isLargeText = UserDefaults.standard.bool(forKey: "large_text")
        self.isHighContrast = UserDefaults.standard.bool(forKey: "high_contrast")
        
        updateFontSizes()
        updateColors()
        
        // Подписываемся на изменения настроек
        $isLargeText
            .sink { [weak self] _ in
                self?.updateFontSizes()
            }
            .store(in: &cancellables)
        
        $isHighContrast
            .sink { [weak self] _ in
                self?.updateColors()
            }
            .store(in: &cancellables)
    }
    
    private func updateFontSizes() {
        fontSizeScale = isLargeText ? 1.2 : 1.0
        // Можно добавить уведомление о изменении размера шрифта
        NotificationCenter.default.post(name: .fontSizeChanged, object: nil)
    }
    
    private func updateColors() {
        currentColors = isHighContrast ? .highContrast : .standard
        // Можно добавить уведомление о изменении темы
        NotificationCenter.default.post(name: .themeChanged, object: nil)
    }
    
    // Методы для применения стилей
    func scaledFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size * fontSizeScale, weight: weight)
    }
    
    func color(_ colorKey: ThemeColorKey) -> Color {
        return currentColors.color(for: colorKey)
    }
}

// Расширение для Notification.Name
extension Notification.Name {
    static let fontSizeChanged = Notification.Name("fontSizeChanged")
    static let themeChanged = Notification.Name("themeChanged")
}

// Цветовые схемы
struct ThemeColors {
    let primary: Color
    let secondary: Color
    let background: Color
    let cardBackground: Color
    let textPrimary: Color
    let textSecondary: Color
    let accent: Color
    let error: Color
    let success: Color
    let surface: Color   // = cardBackground



    
    static let standard = ThemeColors(
        primary: Color(hex: "5BAECC"),
        secondary: Color(hex: "87BDD8"),
        background: Color(hex: "D6EEF5"),
        cardBackground: .white,
        textPrimary: Color(hex: "1C3F6E"),
        textSecondary: Color(hex: "6B8BAE"),
        accent: Color(hex: "F5A623"),
        error: Color(hex: "F87171"),
        success: Color(hex: "10B981"),
        surface: .white
    )
    
    static let highContrast = ThemeColors(
        primary: Color(hex: "0066CC"),
        secondary: Color(hex: "004C99"),
        background: Color(hex: "FFFFFF"),
        cardBackground: Color(hex: "F0F0F0"),
        textPrimary: .black,
        textSecondary: Color(hex: "333333"),
        accent: Color(hex: "FF6600"),
        error: Color(hex: "CC0000"),
        success: Color(hex: "008800"),
        surface: Color(hex: "F0F0F0")
    )
    
    func color(for key: ThemeColorKey) -> Color {
        switch key {
        case .primary: return primary
        case .secondary: return secondary
        case .background: return background
        case .cardBackground: return cardBackground
        case .textPrimary: return textPrimary
        case .textSecondary: return textSecondary
        case .accent: return accent
        case .error: return error
        case .success: return success
        case .surface: return surface

        }
    }
}

enum ThemeColorKey {
    case primary, secondary, background, cardBackground
    case textPrimary, textSecondary, accent, error, success
    case surface
}

// View Modifier для применения темы
struct ThemeModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .environmentObject(themeManager)
    }
}

extension View {
    func withTheme() -> some View {
        self.modifier(ThemeModifier())
    }
}
