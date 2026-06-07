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
    @StateObject private var appRouter     = AppRouter()
    @StateObject private var themeManager  = ThemeManager.shared
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var network       = NetworkMonitor.shared
    @StateObject private var localization  = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appRouter)
                .environmentObject(themeManager)
                .environmentObject(authViewModel)
                .environmentObject(network)
                .environmentObject(localization)
                .preferredColorScheme(themeManager.isHighContrast ? .dark : nil)
                .environment(\.sizeCategory, themeManager.isLargeText ? .extraExtraLarge : .large)
                .overlay(alignment: .top) {
                    if !network.isConnected {
                        OfflineBanner()
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: network.isConnected)
                    }
                }
                .task {
                    if authViewModel.isAuthenticated && network.isConnected {
                        Task.detached(priority: .background) {
                            await SyncService.shared.sync()
                        }
                    }
                }
                // Deep link из виджета: aac://speak?word=хочу
                .onOpenURL { url in
                    guard
                        url.scheme == "aac",
                        url.host == "speak",
                        let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                        let word = components.queryItems?.first(where: { $0.name == "word" })?.value,
                        !word.isEmpty
                    else { return }
                    Task { await TTSService.shared.speak(text: word, language: LocalizationManager.shared.currentLanguage) }
                }
        }
        .modelContainer(CacheService.container)
    }
}

// MARK: - Offline Banner

private struct OfflineBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 13, weight: .semibold))
            Text("Offline — showing cached content")
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(hex: "F87171").ignoresSafeArea(edges: .top))
        .frame(maxWidth: .infinity)
    }
}
