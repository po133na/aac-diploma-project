
// Features/Profile/Views/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var viewModel = ProfileViewModel()

    @State private var showDeleteConfirm = false
    @State private var expandedSection: SettingsSection? = nil

    var body: some View {
        NavigationStack{
            ZStack {
                Color("AppBgAlt").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // ── Аватар + имя + email + Edit profile ──
                        ProfileHeaderSection()
                            .padding(.top, 28)
                            .padding(.bottom, 24)

                        // ── Activity Overview ──
                        SectionHeader(icon: "chart.bar.fill", title: localization.activityOverview)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                        ActivityCard(viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)

                        // ── Settings ──
                        SectionHeader(icon: "gearshape.fill", title: localization.settings)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                        // ── Language Picker ──
                        LanguagePickerCard()
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)

                        SettingsAccordionCard(expandedSection: $expandedSection, viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)

                        // ── Log Out ──
                        ActionRow(
                            icon: "rectangle.portrait.and.arrow.right.fill",
                            iconBg: Color(hex: "5BAECC"),
                            title: localization.logOut,
                            titleColor: Color("AppTextPrimary")
                        ) {
                            authViewModel.logout()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                        // ── Delete Account ──
                        ActionRow(
                            icon: "trash.fill",
                            iconBg: Color(hex: "F87171"),
                            title: localization.deleteAccount,
                            titleColor: Color(hex: "F87171")
                        ) {
                            showDeleteConfirm = true
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 110)
                    }
                }
            }
        }

        .confirmationDialog(
            localization.deleteAccount,
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(localization.deleteAction, role: .destructive) {
                // TODO: удаление аккаунта
            }
            Button(localization.cancel, role: .cancel) {}
        } message: {
            Text(localization.cannotUndo)
        }
        .onAppear {
            Task { await viewModel.loadStats() }
        }
    }
}

// MARK: - Profile Header

private struct ProfileHeaderSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    private var initials: String {
        let parts = (authViewModel.currentUser?.name ?? "LL")
            .split(separator: " ").prefix(2)
            .map { String($0.prefix(1)).uppercased() }
        return parts.joined()
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(hex: "87BDD8").opacity(0.55))
                    .frame(width: 88, height: 88)
                    .overlay(
                        Text(initials)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color(hex: "2C5F7A"))
                    )

                NavigationLink(destination: EditProfileSheet()) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "5BAECC"))
                            .frame(width: 26, height: 26)
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 2, y: 2)
            }

            Text(authViewModel.currentUser?.name ?? "Labuba Labuba")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("AppTextPrimary"))

            Text(authViewModel.currentUser?.email ?? "your@email.com")
                .font(.system(size: 14))
                .foregroundColor(Color("AppTextSecondary"))

            NavigationLink(destination: EditProfileSheet()) {
                Text(LocalizationManager.shared.editProfileBtn)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("AppTextPrimary"))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color("AppSurface"))
                            .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
                    )
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("AppTextSecondary"))
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("AppTextSecondary"))
                .tracking(0.8)
            Spacer()
        }
    }
}

// MARK: - Activity Card

private struct ActivityCard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: ProfileViewModel
    
    private var cardsUsed: Int {
        viewModel.stats?.thisWeekCards ?? 0
    }
    
    private var streak: Int {
        viewModel.stats?.currentStreak ?? 0
    }
    
    private var barData: [CGFloat] {
        guard let weeklyData = viewModel.stats?.weeklyData, !weeklyData.isEmpty else {
            return [0.3, 0.5, 0.4, 0.7, 0.6, 0.85, 1.0] // fallback
        }
        let maxValue = weeklyData.max() ?? 1.0
        return weeklyData.map { CGFloat($0 / max(maxValue, 1.0)) }
    }
    
    private var totalCards: Int {
        viewModel.stats?.totalCards ?? 0
    }

    var body: some View {
        let l = LocalizationManager.shared
        VStack(alignment: .leading, spacing: 12) {
            Text(l.thisWeek)
                .font(.system(size: 14))
                .foregroundColor(Color("AppTextSecondary"))

            HStack(alignment: .bottom) {
                // Число + подпись
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(cardsUsed)")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Color("AppTextPrimary"))
                    Text(l.cardsUsed)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "5BAECC"))
                        .padding(.bottom, 4)
                }

                Spacer()

                // Мини-бар чарт
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(barData.indices, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i == barData.count - 1
                                  ? Color(hex: "5BAECC")
                                  : Color(hex: "C5D8E8"))
                            .frame(width: 8, height: 40 * barData[i])
                    }
                }
                .frame(height: 40)
            }

            // Streak и Total Cards
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "F5A623"))
                        .frame(width: 8, height: 8)
                    Text("\(streak) \(l.dayStreak)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("AppTextSecondary"))
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "A78BFA"))
                        .frame(width: 8, height: 8)
                    Text("\(totalCards) \(l.totalCards)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("AppTextSecondary"))
                }
            }

            Divider()
                .background(Color("AppBorderLight"))

            NavigationLink(destination: FullStatsView(stats: viewModel.stats)) {
                Text(l.seeFullStats)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "5BAECC"))
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(Color(hex: "5BAECC"))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface"))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Language Picker Card

private struct LanguagePickerCard: View {
    @EnvironmentObject var localization: LocalizationManager

    private let options: [(AppLanguage, String, String)] = [
        (.russian,  "🇷🇺", "Русский"),
        (.kazakh,   "🇰🇿", "Қазақша"),
        (.english,  "🇬🇧", "English"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { idx, item in
                let (lang, flag, name) = item
                let isSelected = localization.currentLanguage == lang

                Button {
                    localization.currentLanguage = lang
                } label: {
                    HStack(spacing: 12) {
                        Text(flag).font(.system(size: 22))
                        Text(name)
                            .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(Color("AppTextPrimary"))
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "5BAECC"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                .buttonStyle(PlainButtonStyle())

                if idx < options.count - 1 {
                    Divider().padding(.leading, 54)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface"))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Settings Accordion

enum SettingsSection: Identifiable, CaseIterable {
    case accessibility, support

    var id: Self { self }

    func localizedTitle(_ l: LocalizationManager) -> String {
        switch self {
        case .accessibility: return l.accessibility
        case .support:       return l.supportAbout
        }
    }

    var icon: String {
        switch self {
        case .accessibility:  return "figure.roll"
        case .support:        return "questionmark.circle.fill"
        }
    }

    var iconBg: Color {
        switch self {
        case .accessibility:  return Color(hex: "A8E8B0")
        case .support:        return Color(hex: "F5DEB0")
        }
    }
}

private struct SettingsAccordionCard: View {
    @Binding var expandedSection: SettingsSection?
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(SettingsSection.allCases.enumerated()), id: \.element.id) { idx, section in
                VStack(spacing: 0) {
                    if idx > 0 {
                        Divider().padding(.leading, 54)
                    }

                    AccordionRow(
                        section: section,
                        isExpanded: expandedSection == section,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                expandedSection = (expandedSection == section) ? nil : section
                            }
                        },
                        viewModel: viewModel
                    )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface"))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

private struct AccordionRow: View {
    let section: SettingsSection
    let isExpanded: Bool
    let onTap: () -> Void
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // Иконка
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(section.iconBg)
                            .frame(width: 34, height: 34)
                        Image(systemName: section.icon)
                            .font(.system(size: 15))
                            .foregroundColor(Color("AppTextPrimary"))
                    }

                    Text(section.localizedTitle(localization))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("AppTextPrimary"))

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("AppTextHint"))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(PlainButtonStyle())

            // Раскрытый контент
            if isExpanded {
                AccordionContent(section: section, viewModel: viewModel)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

private struct AccordionContent: View {
    let section: SettingsSection
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider().padding(.horizontal, 16)

            switch section {
            case .accessibility:
                AccessibilitySettings(viewModel: viewModel)
            case .support:
                SupportSettings()
            }
        }
    }
}

// MARK: - Accordion Content Views

private struct AccessibilitySettings: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            ToggleRow(label: localization.largeText, isOn: $viewModel.largeText)
            Divider().padding(.leading, 16)
            ToggleRow(label: localization.darkTheme, isOn: $viewModel.darkTheme)
        }
        .padding(.bottom, 4)
    }
}

private struct SupportSettings: View {
    var body: some View {
        let l = LocalizationManager.shared
        VStack(spacing: 0) {
            SupportLinkRow(label: l.helpCenter, icon: "questionmark.circle")
            Divider().padding(.leading, 16)
            SupportLinkRow(label: l.privacyPolicy, icon: "lock.shield")
            Divider().padding(.leading, 16)
            SupportLinkRow(label: l.version, icon: "info.circle")
        }
        .padding(.bottom, 4)
    }
}

private struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("AppTextPrimary"))
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(Color(hex: "5BAECC"))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct SupportLinkRow: View {
    let label: String
    let icon: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color("AppTextPrimary"))
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color("AppTextHint"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Action Row (Log Out / Delete Account)

struct ActionRow: View {
    let icon: String
    let iconBg: Color
    let title: String
    let titleColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconBg.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(iconBg)
                }

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(titleColor)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Profile Sheet (заглушка)

// MARK: - Edit Profile Screen
struct EditProfileSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let l = LocalizationManager.shared
        ZStack {
            Color("AppBgAlt").ignoresSafeArea()
            Text(l.editProfileComingSoon)
                .foregroundColor(Color("AppTextSecondary"))
        }
        .navigationTitle(l.editProfile)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Full Stats Screen
struct FullStatsView: View {
    @Environment(\.dismiss) var dismiss
    let stats: UserStats?
    
    var body: some View {
        let l = LocalizationManager.shared
        ZStack {
            Color("AppBgAlt").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Карточка общей статистики
                    StatsCard(
                        title: l.overview,
                        items: [
                            (l.totalCardsStat, "\(stats?.totalCards ?? 0)"),
                            (l.cardsThisWeek, "\(stats?.thisWeekCards ?? 0)"),
                            (l.currentStreak, "\(stats?.currentStreak ?? 0)"),
                            (l.totalCardUses, "\(stats?.totalCardUses ?? 0)"),
                            (l.totalPhrases, "\(stats?.totalPhrases ?? 0)"),
                            (l.totalPhraseUses, "\(stats?.totalPhraseUses ?? 0)")
                        ]
                    )

                    // Top Cards
                    if let topCards = stats?.topCards, !topCards.isEmpty {
                        MostUsedCardsCard(topCards: Array(topCards.prefix(5)))
                    }

                    // Top Phrases
                    if let topPhrases = stats?.topPhrases, !topPhrases.isEmpty {
                        StatsCard(
                            title: l.mostUsedPhrases,
                            items: topPhrases.prefix(5).map { phrase in
                                ("\(phrase.name)", "\(phrase.usageCount) \(l.uses)")
                            }
                        )
                    }

                    // Weekly Chart
                    if let weeklyData = stats?.weeklyData, !weeklyData.isEmpty {
                        WeeklyChartView(data: weeklyData)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(l.statistics)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatsCard: View {
    let title: String
    let items: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("AppTextPrimary"))
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text(item.0)
                            .font(.system(size: 14))
                            .foregroundColor(Color("AppTextPrimary"))
                        
                        Spacer()
                        
                        Text(item.1)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "5BAECC"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    if index < items.count - 1 {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Most Used Cards with hyperlink

struct MostUsedCardsCard: View {
    let topCards: [TopCard]

    var body: some View {
        let l = LocalizationManager.shared
        VStack(alignment: .leading, spacing: 12) {
            Text(l.mostUsedCards)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("AppTextPrimary"))
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(Array(topCards.enumerated()), id: \.element.id) { index, card in
                    NavigationLink(destination: TopCardDetailView(card: card)) {
                        HStack {
                            if index == 0 {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "F5A623"))
                            }
                            Text(card.word)
                                .font(.system(size: 14))
                                .foregroundColor(Color("AppTextPrimary"))
                            Spacer()
                            Text("\(card.usageCount) \(l.uses)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "5BAECC"))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11))
                                .foregroundColor(Color("AppTextHint"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(PlainButtonStyle())

                    if index < topCards.count - 1 {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Top Card Detail View

struct TopCardDetailView: View {
    let card: TopCard
    @State private var fullCard: Card? = nil
    @State private var uiImage: UIImage? = nil
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color("AppBgAlt").ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                if isLoading {
                    ProgressView()
                } else {
                    VStack(spacing: 16) {
                        if let img = uiImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("AppPlaceholderBg"))
                                .frame(width: 200, height: 200)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color("AppTextHint"))
                                )
                        }

                        Text(card.word)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color("AppTextPrimary"))

                        HStack(spacing: 6) {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(Color(hex: "5BAECC"))
                            Text("\(LocalizationManager.shared.uses): \(card.usageCount)")
                                .font(.system(size: 16))
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(Color("AppSurface"))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                        )

                        Button {
                            Task {
                                await TTSService.shared.speak(text: card.word, language: .russian)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text(LocalizationManager.shared.speak)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color(hex: "5BAECC")))
                        }
                    }
                }
                Spacer()
            }
        }
        .navigationTitle(LocalizationManager.shared.cardDetail)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let fetched = try? await CardService.shared.getCard(id: card.id) {
                fullCard = fetched
                if !fetched.imageBase64.isEmpty,
                   let data = Data(base64Encoded: fetched.imageBase64) {
                    uiImage = UIImage(data: data)
                }
            }
            isLoading = false
        }
    }
}

struct WeeklyChartView: View {
    let data: [Double]
    
    private var maxValue: Double {
        data.max() ?? 1.0
    }
    
    var body: some View {
        let l = LocalizationManager.shared
        VStack(alignment: .leading, spacing: 12) {
            Text(l.weeklyActivity)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("AppTextPrimary"))
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data.indices, id: \.self) { index in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index == data.count - 1
                                  ? Color(hex: "5BAECC")
                                  : Color(hex: "C5D8E8"))
                            .frame(width: 20, height: CGFloat(100 * data[index] / max(maxValue, 1.0)))
                        
                        Text(dayLabel(for: index))
                            .font(.system(size: 11))
                            .foregroundColor(Color("AppTextSecondary"))
                    }
                }
            }
            .frame(height: 120)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("AppSurface"))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
    }
    
    private func dayLabel(for index: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return index < days.count ? days[index] : "Day \(index + 1)"
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager.shared)
        .environmentObject(LocalizationManager.shared)
}
