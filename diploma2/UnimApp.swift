//
//  UnimApp.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

import SwiftUI
import SwiftData

@main
struct SpeakEasyApp: App {
    @StateObject private var appRouter    = AppRouter()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appRouter)
                .environmentObject(themeManager)
                .environmentObject(authViewModel)
                .preferredColorScheme(themeManager.colorScheme)
        }
        .modelContainer(for: [SDCard.self])   // SDFolder и SDUser удалены — используем API
    }
}
