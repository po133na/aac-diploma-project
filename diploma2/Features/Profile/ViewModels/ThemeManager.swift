//
//  Profile/ViewModels/ThemeManager.swift
//  diploma2
//

import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var isLargeText: Bool {
        didSet { UserDefaults.standard.set(isLargeText, forKey: "large_text") }
    }

    /// isHighContrast used internally; UI label is "Dark Theme"
    @Published var isHighContrast: Bool {
        didSet { UserDefaults.standard.set(isHighContrast, forKey: "high_contrast") }
    }

    private init() {
        self.isLargeText    = UserDefaults.standard.bool(forKey: "large_text")
        self.isHighContrast = UserDefaults.standard.bool(forKey: "high_contrast")
    }
}

// View Modifier для применения темы
struct ThemeModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager

    func body(content: Content) -> some View {
        content.environmentObject(themeManager)
    }
}

extension View {
    func withTheme() -> some View {
        self.modifier(ThemeModifier())
    }
}
