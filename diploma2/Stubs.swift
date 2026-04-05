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

    var isLanguageSelected: Bool {
        UserDefaults.standard.string(forKey: "app_language") != nil
    }

    // MARK: - Home
    var mySentence:        String { t("Моё предложение",           kk: "Менің сөйлемім",         en: "My Sentence") }
    var words:             String { t("слов",                      kk: "сөз",                    en: "words") }
    var clear:             String { t("Очистить",                  kk: "Тазарту",                en: "Clear") }
    var speak:             String { t("Говорить",                  kk: "Айту",                   en: "Speak") }
    var tapWordsHint:      String { t("Нажми на слова...",         kk: "Сөз таңдаңыз...",        en: "Tap words to build...") }
    var letsTitle:         String { t("Давай поговорим!",          kk: "Сөйлесейік!",            en: "Let's Talk!") }
    var chooseCategory:    String { t("Выбери категорию",          kk: "Категория таңдаңыз",     en: "Choose a category") }
    var recentCards:       String { t("Недавние карточки",         kk: "Соңғы карталар",         en: "Recent Cards") }
    var viewAll:           String { t("Смотреть все >",            kk: "Барлығын қарау >",       en: "View All >") }
    var tryAgain:          String { t("Попробовать снова",         kk: "Қайталап көру",          en: "Try Again") }
    var noCards:           String { t("Нет карточек",              kk: "Карталар жоқ",           en: "No cards yet") }
    var speakAgain:        String { t("Озвучить снова",            kk: "Қайта айту",             en: "Speak Again") }
    var orTypeText:        String { t("или введи текст",           kk: "немесе мәтін енгізіңіз", en: "or type text") }
    var typeToSpeak:       String { t("Введи слово для озвучки...",kk: "Сөз жазыңыз...",         en: "Type word to speak...") }
    var systemCategory:    String { t("Системная категория",       kk: "Жүйелік санат",          en: "System category") }
    var myCategory:        String { t("Моя категория",             kk: "Менің санатым",          en: "My category") }
    var quickTip:          String { t("Совет",                     kk: "Кеңес",                  en: "Quick Tip") }
    var quickTipBody:      String { t("Нажимай на слова, чтобы добавить в предложение.", kk: "Сөйлемге қосу үшін сөзді басыңыз.", en: "Tap any word to add it to your sentence.") }
    var listen:            String { t("Слушать",                   kk: "Тыңдау",                 en: "Listen") }
    var yourSentence:      String { t("Ваше предложение",          kk: "Сіздің сөйлемiңiз",     en: "Your sentence") }

    // MARK: - Profile / Settings
    var activityOverview:  String { t("АКТИВНОСТЬ",                kk: "БЕЛСЕНДІЛІК",            en: "ACTIVITY OVERVIEW") }
    var settings:          String { t("НАСТРОЙКИ",                 kk: "ПАРАМЕТРЛЕР",            en: "SETTINGS") }
    var thisWeek:          String { t("На этой неделе",            kk: "Осы аптада",             en: "This week") }
    var cardsUsed:         String { t("карточек",                  kk: "карта",                  en: "cards used") }
    var dayStreak:         String { t("дней подряд",               kk: "күндік серия",           en: "day streak") }
    var totalCards:        String { t("всего карточек",            kk: "барлық карталар",        en: "total cards") }
    var seeFullStats:      String { t("Полная статистика ›",       kk: "Толық статистика ›",     en: "See full stats ›") }
    var communication:     String { t("Коммуникация",              kk: "Байланыс",               en: "Communication") }
    var accessibility:     String { t("Доступность",               kk: "Қолжетімділік",          en: "Accessibility") }
    var supportAbout:      String { t("Поддержка",                 kk: "Қолдау",                 en: "Support & About") }
    var largeText:         String { t("Крупный текст",             kk: "Үлкен мәтін",            en: "Large Text") }
    var darkTheme:         String { t("Тёмная тема",               kk: "Қара тақырып",           en: "Dark Theme") }
    var helpCenter:        String { t("Центр помощи",              kk: "Анықтама орталығы",      en: "Help Center") }
    var privacyPolicy:     String { t("Политика конфиденциальности", kk: "Құпиялылық саясаты",  en: "Privacy Policy") }
    var version:           String { t("Версия 1.0.0",              kk: "Нұсқа 1.0.0",            en: "Version 1.0.0") }
    var logOut:            String { t("Выйти",                     kk: "Шығу",                   en: "Log Out") }
    var deleteAccount:     String { t("Удалить аккаунт",           kk: "Аккаунтты жою",          en: "Delete Account") }
    var editProfile:       String { t("Редактировать",             kk: "Өңдеу",                  en: "Edit Profile") }
    var statistics:        String { t("Статистика",                kk: "Статистика",             en: "Statistics") }
    var mostUsedCards:     String { t("Часто используемые",        kk: "Жиі қолданылатын",       en: "Most Used Cards") }
    var mostUsedPhrases:   String { t("Частые фразы",              kk: "Жиі тіркестер",          en: "Most Used Phrases") }
    var weeklyActivity:    String { t("Активность за неделю",      kk: "Апталық белсенділік",    en: "Weekly Activity") }
    var overview:          String { t("Обзор",                     kk: "Шолу",                   en: "Overview") }
    var uses:              String { t("раз",                       kk: "рет",                    en: "uses") }

    // MARK: - Card Manager
    var cardManager:       String { t("Менеджер карточек",         kk: "Карта менеджері",        en: "Card Manager") }
    var createNewCard:     String { t("Создать карточку",          kk: "Жаңа карта жасау",       en: "Create New Card") }
    var addCustomCard:     String { t("Добавить свою карточку",    kk: "Өз картаңызды қосыңыз",  en: "Add a custom card") }
    var takePhoto:         String { t("Сфотографировать",          kk: "Сурет түсіру",           en: "Take a Photo") }
    var chooseFromGallery: String { t("Выбрать из галереи",        kk: "Галереядан таңдау",      en: "Choose from Gallery") }
    var createNewCategory: String { t("Создать категорию",         kk: "Жаңа санат жасау",       en: "Create New Category") }
    var selectCategory:    String { t("Выберите категорию",        kk: "Санат таңдаңыз",         en: "Select category") }
    var saveCard:          String { t("Сохранить карточку",        kk: "Картаны сақтау",         en: "Save Card") }
    var cardSaved:         String { t("Карточка сохранена!",       kk: "Карта сақталды!",        en: "Card saved!") }
    var addedToLibrary:    String { t("Добавлено в библиотеку.",   kk: "Кітапханаға қосылды.",   en: "Added to your library.") }

    // MARK: - Auth
    var login:             String { t("Войти",                     kk: "Кіру",                   en: "Log In") }
    var register:          String { t("Регистрация",               kk: "Тіркелу",                en: "Register") }
    var email:             String { t("Email",                     kk: "Email",                  en: "Email") }
    var password:          String { t("Пароль",                    kk: "Құпиясөз",               en: "Password") }
    var name:              String { t("Имя",                       kk: "Аты",                    en: "Name") }
    var forgotPassword:    String { t("Забыли пароль?",            kk: "Құпиясөзді ұмыттыңыз ба?", en: "Forgot password?") }
    var continueBtn:       String { t("Продолжить →",             kk: "Жалғастыру →",           en: "Continue →") }
    var cancel:            String { t("Отмена",                    kk: "Болдырмау",              en: "Cancel") }
    var save:              String { t("Сохранить",                 kk: "Сақтау",                 en: "Save") }
    var done:              String { t("Готово",                    kk: "Дайын",                  en: "Done") }
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
