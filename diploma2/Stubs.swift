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

    var isLanguageSelected: Bool {
        UserDefaults.standard.string(forKey: "app_language") != nil
    }

    // MARK: - Core lookup (loads from Localizable.strings files)
    func s(_ key: String) -> String {
        let lang = currentLanguage.rawValue
        if let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: lang),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String],
           let value = dict[key] {
            return value
        }
        // Fallback to English
        if let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: "en"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String],
           let value = dict[key] {
            return value
        }
        return key
    }

    // MARK: - Home
    var mySentence:        String { s("my_sentence") }
    var words:             String { s("words") }
    var clear:             String { s("clear") }
    var speak:             String { s("speak") }
    var tapWordsHint:      String { s("tap_words_hint") }
    var letsTitle:         String { s("lets_title") }
    var chooseCategory:    String { s("choose_category") }
    var recentCards:       String { s("recent_cards") }
    var viewAll:           String { s("view_all") }
    var tryAgain:          String { s("try_again") }
    var noCards:           String { s("no_cards") }
    var speakAgain:        String { s("speak_again") }
    var orTypeText:        String { s("or_type_text") }
    var typeToSpeak:       String { s("type_to_speak") }
    var systemCategory:    String { s("system_category") }
    var myCategory:        String { s("my_category") }
    var quickTip:          String { s("quick_tip") }
    var quickTipBody:      String { s("quick_tip_body") }
    var listen:            String { s("listen") }
    var yourSentence:      String { s("your_sentence") }

    // MARK: - Profile / Settings
    var activityOverview:  String { s("activity_overview") }
    var settings:          String { s("settings") }
    var thisWeek:          String { s("this_week") }
    var cardsUsed:         String { s("cards_used") }
    var dayStreak:         String { s("day_streak") }
    var totalCards:        String { s("total_cards") }
    var seeFullStats:      String { s("see_full_stats") }
    var communication:     String { s("communication") }
    var accessibility:     String { s("accessibility") }
    var supportAbout:      String { s("support_about") }
    var largeText:         String { s("large_text") }
    var darkTheme:         String { s("dark_theme") }
    var helpCenter:        String { s("help_center") }
    var privacyPolicy:     String { s("privacy_policy") }
    var version:           String { s("version") }
    var logOut:            String { s("log_out") }
    var logOutSubtitle:         String { s("log_out_subtitle") }
    var deleteAccountTitle:     String { s("delete_account_title") }
    var deleteAccountSubtitle:  String { s("delete_account_subtitle") }
    var deleteAccount:     String { s("delete_account") }
    var editProfile:       String { s("edit_profile") }
    var statistics:        String { s("statistics") }
    var mostUsedCards:     String { s("most_used_cards") }
    var mostUsedPhrases:   String { s("most_used_phrases") }
    var weeklyActivity:    String { s("weekly_activity") }
    var overview:          String { s("overview") }
    var uses:              String { s("uses") }
    var editProfileBtn:    String { s("edit_profile_btn") }
    var deleteAction:      String { s("delete_action") }
    var cannotUndo:        String { s("cannot_undo") }
    var totalCardsStat:    String { s("total_cards_stat") }
    var cardsThisWeek:     String { s("cards_this_week") }
    var currentStreak:     String { s("current_streak") }
    var totalCardUses:     String { s("total_card_uses") }
    var totalPhrases:      String { s("total_phrases") }
    var totalPhraseUses:   String { s("total_phrase_uses") }
    var cardDetail:        String { s("card_detail") }
    var editProfileComingSoon: String { s("edit_profile_coming_soon") }

    // MARK: - Card Manager
    var cardManager:                String { s("card_manager") }
    var cardsTotal:                 String { s("cards_total") }
    var createNewCard:              String { s("create_new_card") }
    var addCustomCard:              String { s("add_custom_card") }
    var addCustomCardSubtitle:      String { s("add_custom_card_subtitle") }
    var takePhoto:                  String { s("take_photo") }
    var chooseFromGallery:          String { s("choose_from_gallery") }
    var createNewCategory:          String { s("create_new_category") }
    var createNewCategorySubtitle:  String { s("create_new_category_subtitle") }
    var selectCategory:             String { s("select_category") }
    var saveCard:                   String { s("save_card") }
    var cardSaved:                  String { s("card_saved") }
    var addedToLibrary:             String { s("added_to_library") }
    var addAnImage:                 String { s("add_an_image") }
    var chooseHowToCreate:          String { s("choose_how_to_create") }
    var aiMagic:                    String { s("ai_magic") }
    var describeAndAI:              String { s("describe_and_ai") }
    var takeAPhotoCam:              String { s("take_a_photo_cam") }
    var useYourCamera:              String { s("use_your_camera") }
    var chooseGalleryEmoji:         String { s("choose_gallery_emoji") }
    var pickFromLibrary:            String { s("pick_from_library") }
    var describeYourImage:          String { s("describe_your_image") }
    var tellAIWhatYouWant:          String { s("tell_ai_what_you_want") }
    var enterDescription:           String { s("enter_description") }
    var generating:                 String { s("generating") }
    var generateImage:              String { s("generate_image") }
    var imagePreview:               String { s("image_preview") }
    var doYouLikeImage:             String { s("do_you_like_image") }
    var noImage:                    String { s("no_image") }
    var saveAndContinue:            String { s("save_and_continue") }
    var regenerate:                 String { s("regenerate") }
    var nameYourCard:               String { s("name_your_card") }
    var whatDoesThisRepresent:      String { s("what_does_this_represent") }
    var enterCardName:              String { s("enter_card_name") }
    var readyToSave:                String { s("ready_to_save") }
    var yourCardLooksAmazing:       String { s("your_card_looks_amazing") }
    var loadingCategories:          String { s("loading_categories") }
    var noCategoriesFound:          String { s("no_categories_found") }
    var retry:                      String { s("retry") }
    var saving:                     String { s("saving") }
    var saveCardArrow:              String { s("save_card_arrow") }
    var pleaseSelectCategory:       String { s("please_select_category") }
    var createAnotherCard:          String { s("create_another_card") }
    var goToBoard:                  String { s("go_to_board") }
    var stepOf:                     String { s("step_of") }
    var step1Label:                 String { s("step1_label") }
    var step2Label:                 String { s("step2_label") }
    var step3Label:                 String { s("step3_label") }
    var step4Label:                 String { s("step4_label") }
    var step5Label:                 String { s("step5_label") }
    var step1PhotoLabel:            String { s("step1_photo_label") }
    var step2PhotoLabel:            String { s("step2_photo_label") }
    var tutorialPlus:               String { s("tutorial_plus") }
    var tutorialSpeak:              String { s("tutorial_speak") }
    var tutorialLongPress:          String { s("tutorial_long_press") }
    var tutorialTap:                String { s("tutorial_tap") }
    var tutorialClose:              String { s("tutorial_close") }
    var tutorialStats:              String { s("tutorial_stats") }
    var tutorialLanguage:           String { s("tutorial_language") }
    var tutorialSkip:               String { s("tutorial_skip") }
    var categoryNameTitle:          String { s("category_name_title") }
    var giveUniqueName:             String { s("give_unique_name") }
    var enterTheName:               String { s("enter_the_name") }
    var yourCards:                  String { s("your_cards") }
    var selectCardsHint:            String { s("select_cards_hint") }
    var skipArrow:                  String { s("skip_arrow") }
    var categoryCreated:            String { s("category_created") }
    var categoryReady:              String { s("category_ready") }
    var step1CatLabel:              String { s("step1_cat_label") }
    var step2CatLabel:              String { s("step2_cat_label") }
    var step3CatLabel:              String { s("step3_cat_label") }
    var categoryCoverTitle:         String { s("category_cover_title") }
    var categoryCoverSubtitle:      String { s("category_cover_subtitle") }
    var creating:                   String { s("creating") }
    var createAnotherCategory:      String { s("create_another_category") }
    var viewCategory:               String { s("view_category") }
    var newCategory:                String { s("new_category") }
    var generateAICoverTitle:       String { s("generate_ai_cover_title") }
    var generateAICoverSubtitle:    String { s("generate_ai_cover_subtitle") }

    // MARK: - Gallery
    var galleryTitle:           String { s("gallery_title") }
    var allTab:                 String { s("all_tab") }
    var favoritesTab:           String { s("favorites_tab") }
    var categoriesTab:          String { s("categories_tab") }
    var noCardsGallery:         String { s("no_cards_gallery") }
    var createFirstCardHint:    String { s("create_first_card_hint") }
    var noFavorites:            String { s("no_favorites") }
    var addToFavoritesHint:     String { s("add_to_favorites_hint") }
    var noCategoriesGallery:    String { s("no_categories_gallery") }
    var createCategoryHint:     String { s("create_category_hint") }
    var cardsSuffix:            String { s("cards_suffix") }

    // MARK: - Auth
    var welcomeBack:            String { s("welcome_back") }
    var loginUnsuccessful:      String { s("login_unsuccessful") }
    var signInToContinue:       String { s("sign_in_to_continue") }
    var pleaseCheckCredentials: String { s("please_check_credentials") }
    var incorrectEmailPassword: String { s("incorrect_email_password") }
    var emailAddress:           String { s("email_address") }
    var emailPlaceholder:       String { s("email_placeholder") }
    var passwordPlaceholder:    String { s("password_placeholder") }
    var rememberMe:             String { s("remember_me") }
    var forgotPasswordQ:        String { s("forgot_password_q") }
    var signInArrow:            String { s("sign_in_arrow") }
    var tryAgainArrow:          String { s("try_again_arrow") }
    var or:                     String { s("or") }
    var dontHaveAccount:        String { s("dont_have_account") }
    var signUpHere:             String { s("sign_up_here") }
    var welcomeEmoji:           String { s("welcome_emoji") }
    var emailAlreadyTaken:      String { s("email_already_taken") }
    var letsGetToKnowYou:       String { s("lets_get_to_know_you") }
    var firstName:              String { s("first_name") }
    var enterNamePlaceholder:   String { s("enter_name_placeholder") }
    var lastName:               String { s("last_name") }
    var enterSurnamePlaceholder: String { s("enter_surname_placeholder") }
    var continueArrow:          String { s("continue_arrow") }
    var alreadyHaveAccount:     String { s("already_have_account") }
    var loginHere:              String { s("login_here") }
    var staySafe:               String { s("stay_safe") }
    var lookingGoodAlmost:      String { s("looking_good_almost") }
    var secureYourAccount:      String { s("secure_your_account") }
    var createPasswordLabel:    String { s("create_password_label") }
    var confirmPasswordLabel:   String { s("confirm_password_label") }
    var repeatPasswordPlaceholder: String { s("repeat_password_placeholder") }
    var almostDoneBanner:       String { s("almost_done_banner") }
    var registrationFailed:     String { s("registration_failed") }
    var creatingAccount:        String { s("creating_account") }
    var resetPasswordTitle:     String { s("reset_password_title") }
    var enterEmailReset:        String { s("enter_email_reset") }
    var errorTitle:             String { s("error_title") }
    var successTitle:           String { s("success_title") }
    var resetInstructions:      String { s("reset_instructions") }
    var sending:                String { s("sending") }
    var sendResetLink:          String { s("send_reset_link") }
    var backToLogin:            String { s("back_to_login") }
    var login:                  String { s("login_btn") }
    var register:               String { s("register_btn") }
    var email:                  String { s("email_label") }
    var password:               String { s("password_label") }
    var name:                   String { s("name_label") }
    var forgotPassword:         String { s("forgot_password_btn") }
    var cancel:                 String { s("cancel_btn") }
    var save:                   String { s("save_btn") }
    var done:                   String { s("done_btn") }
    var editBtn:                String { s("edit_btn") }
    var backBtn:                String { s("back_btn") }
    var homeTab:                String { s("home_tab") }
    var settingsTab:            String { s("settings_tab") }
    var emailUs:                String { s("email_us") }
    var versionLabel:           String { s("version_label") }
    var characters:             String { s("characters") }
    var cardNameLabel:          String { s("card_name_label") }
    var categoryLabel:          String { s("category_label") }
    var cardExampleHint:        String { s("card_example_hint") }
    var folderEmpty:            String { s("folder_empty") }
    var folderAddHint:          String { s("folder_add_hint") }
    var generatingCoverFor:     String { s("generating_cover_for") }
    var generatingWait:         String { s("generating_wait") }
    var passwordReqLength:      String { s("password_req_length") }
    var passwordReqNumber:      String { s("password_req_number") }
    var passwordReqUppercase:   String { s("password_req_uppercase") }
    var noCardsAvailable:       String { s("no_cards_available") }
    var createCardsFirst:       String { s("create_cards_first") }
    var dayMon:                 String { s("day_mon") }
    var dayTue:                 String { s("day_tue") }
    var dayWed:                 String { s("day_wed") }
    var dayThu:                 String { s("day_thu") }
    var dayFri:                 String { s("day_fri") }
    var daySat:                 String { s("day_sat") }
    var daySun:                 String { s("day_sun") }
    var continueBtn:            String { s("continue_btn") }

    // MARK: - Register Success
    var youreIn:                String { s("youre_in") }
    var accountCreated:         String { s("account_created") }

    // MARK: - Settings Labels
    var languageSetting:     String { s("language_setting") }
    var lightMode:           String { s("light_mode") }
    var darkMode:            String { s("dark_mode") }
    var noCategoryHint:      String { s("no_category_hint") }
    var savedTo:             String { s("saved_to") }
    var unassignedCategory:  String { s("unassigned_category") }
    var changePhoto:         String { s("change_photo") }
    var removePhotoBtn:      String { s("remove_photo_btn") }
    var removePhotoConfirm:  String { s("remove_photo_confirm") }

    // MARK: - Category / Card Actions
    var deleteCategoryBtn:          String { s("delete_category_btn") }
    var deleteCategorySubtitle:     String { s("delete_category_subtitle") }
    var renameCard:                 String { s("rename_card") }
    var cardNamePlaceholder:        String { s("card_name_placeholder") }
    var deleteCard:                 String { s("delete_card") }
    var deleteCardSubtitle:         String { s("delete_card_subtitle") }
    var addCards:                   String { s("add_cards") }
    var editCard:                   String { s("edit_card") }
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
                .foregroundColor(Color("AppTextPrimary"))
            Spacer()
            Button { onSpeak?() } label: {
                Image(systemName: "speaker.wave.2")
                    .foregroundColor(Color(hex: "5BAECC"))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("AppSurface"))
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
        case .secondary: return Color("AppTextHint")
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
                .foregroundColor(Color("AppTextHint"))
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("AppSurfaceSecondary"))
        )
    }
}

