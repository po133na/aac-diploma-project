import SwiftUI
import Foundation

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        if !localization.isLanguageSelected {
            LanguageSelectView {
                // язык уже сохранён внутри LanguageSelectView
            }
        } else if authViewModel.isAuthenticated {
            MainTabView()
        } else {
            AuthRootView()
        }
    }
}
