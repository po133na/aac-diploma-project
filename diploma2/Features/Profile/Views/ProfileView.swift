
// Features/Profile/Views/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = ProfileViewModel()


    @State private var showDeleteConfirm = false
    @State private var expandedSection: SettingsSection? = nil

    var body: some View {
        NavigationStack{
            ZStack {
                Color(hex: "D6EEF5").ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // ── Аватар + имя + email + Edit profile ──
                        ProfileHeaderSection()
                            .padding(.top, 28)
                            .padding(.bottom, 24)
                        
                        // ── Activity Overview ──
                        SectionHeader(icon: "chart.bar.fill", title: "ACTIVITY OVERVIEW")
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        
                        ActivityCard(viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        
                        // ── Settings ──
                        SectionHeader(icon: "gearshape.fill", title: "SETTINGS")
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        
                        SettingsAccordionCard(expandedSection: $expandedSection, viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        
                        // ── Log Out ──
                        ActionRow(
                            icon: "rectangle.portrait.and.arrow.right.fill",
                            iconBg: Color(hex: "5BAECC"),
                            title: "Log Out",
                            titleColor: Color(hex: "1C3F6E")
                        ) {
                            authViewModel.logout()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        
                        // ── Delete Account ──
                        ActionRow(
                            icon: "trash.fill",
                            iconBg: Color(hex: "F87171"),
                            title: "Delete Account",
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
            "Delete Account",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                // TODO: удаление аккаунта
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {                              // ← сюда, самым последним
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
                .foregroundColor(Color(hex: "1C3F6E"))

            Text(authViewModel.currentUser?.email ?? "your@email.com")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6B8BAE"))

            NavigationLink(destination: EditProfileSheet()) {
                Text("Edit profile")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "1C3F6E"))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white)
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
                .foregroundColor(Color(hex: "6B8BAE"))
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "6B8BAE"))
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
        VStack(alignment: .leading, spacing: 12) {
            Text("This week")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6B8BAE"))

            HStack(alignment: .bottom) {
                // Число + подпись
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(cardsUsed)")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                    Text("cards used")
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
                    Text("\(streak)-day streak")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "6B8BAE"))
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "A78BFA"))
                        .frame(width: 8, height: 8)
                    Text("\(totalCards) total cards")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "6B8BAE"))
                }
            }

            Divider()
                .background(Color(hex: "E5EEF5"))

            NavigationLink(destination: FullStatsView(stats: viewModel.stats)) {
                Text("See full stats ›")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "5BAECC"))
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(Color(hex: "5BAECC"))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Settings Accordion

enum SettingsSection: Identifiable, CaseIterable {
    case communication, accessibility, support

    var id: Self { self }

    var title: String {
        switch self {
        case .communication: return "Communication"
        case .accessibility:  return "Accessibility"
        case .support:        return "Support & about"
        }
    }

    var icon: String {
        switch self {
        case .communication: return "message.fill"
        case .accessibility:  return "figure.roll"
        case .support:        return "questionmark.circle.fill"
        }
    }

    var iconBg: Color {
        switch self {
        case .communication: return Color(hex: "B8CFF5")
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
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

private struct AccordionRow: View {
    let section: SettingsSection
    let isExpanded: Bool
    let onTap: () -> Void
    @ObservedObject var viewModel: ProfileViewModel

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
                            .foregroundColor(Color(hex: "1C3F6E"))
                    }

                    Text(section.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "1C3F6E"))

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "9BB8CC"))
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
            case .communication:
                CommunicationSettings(viewModel: viewModel)
            case .accessibility:
                AccessibilitySettings(viewModel: viewModel)
            case .support:
                SupportSettings()
            }
        }
    }
}

// MARK: - Accordion Content Views

private struct CommunicationSettings: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            ToggleRow(label: "Text-to-Speech", isOn: $viewModel.ttsEnabled)
            Divider().padding(.leading, 16)
            ToggleRow(label: "Auto speak on selection", isOn: $viewModel.autoSpeak)
        }
        .padding(.bottom, 4)
    }
}

private struct AccessibilitySettings: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            ToggleRow(label: "Large text", isOn: $viewModel.largeText)
            Divider().padding(.leading, 16)
            ToggleRow(label: "High contrast", isOn: $viewModel.highContrast)
        }
        .padding(.bottom, 4)
    }
}

private struct SupportSettings: View {
    var body: some View {
        VStack(spacing: 0) {
            SupportLinkRow(label: "Help Center", icon: "questionmark.circle")
            Divider().padding(.leading, 16)
            SupportLinkRow(label: "Privacy Policy", icon: "lock.shield")
            Divider().padding(.leading, 16)
            SupportLinkRow(label: "Version 1.0.0", icon: "info.circle")
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
                .foregroundColor(Color(hex: "1C3F6E"))
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
                .foregroundColor(Color(hex: "1C3F6E"))
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "9BB8CC"))
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
                    .fill(Color.white)
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
        ZStack {
            Color(hex: "D6EEF5").ignoresSafeArea()
            Text("Edit Profile — coming soon")
                .foregroundColor(Color(hex: "6B8BAE"))
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Full Stats Screen
struct FullStatsView: View {
    @Environment(\.dismiss) var dismiss
    let stats: UserStats?
    
    var body: some View {
        ZStack {
            Color(hex: "D6EEF5").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Карточка общей статистики
                    StatsCard(
                        title: "Overview",
                        items: [
                            ("Total Cards", "\(stats?.totalCards ?? 0)"),
                            ("Cards This Week", "\(stats?.thisWeekCards ?? 0)"),
                            ("Current Streak", "\(stats?.currentStreak ?? 0) days"),
                            ("Total Card Uses", "\(stats?.totalCardUses ?? 0)"),
                            ("Total Phrases", "\(stats?.totalPhrases ?? 0)"),
                            ("Total Phrase Uses", "\(stats?.totalPhraseUses ?? 0)")
                        ]
                    )
                    
                    // Top Cards
                    if let topCards = stats?.topCards, !topCards.isEmpty {
                        StatsCard(
                            title: "Most Used Cards",
                            items: topCards.prefix(5).map { card in
                                ("\(card.word)", "\(card.usageCount) uses")
                            }
                        )
                    }
                    
                    // Top Phrases
                    if let topPhrases = stats?.topPhrases, !topPhrases.isEmpty {
                        StatsCard(
                            title: "Most Used Phrases",
                            items: topPhrases.prefix(5).map { phrase in
                                ("\(phrase.name)", "\(phrase.usageCount) uses")
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
        .navigationTitle("Statistics")
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
                .foregroundColor(Color(hex: "1C3F6E"))
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack {
                        Text(item.0)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "1C3F6E"))
                        
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
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
        }
    }
}

struct WeeklyChartView: View {
    let data: [Double]
    
    private var maxValue: Double {
        data.max() ?? 1.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Activity")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1C3F6E"))
            
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
                            .foregroundColor(Color(hex: "6B8BAE"))
                    }
                }
            }
            .frame(height: 120)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
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
        .environmentObject(ThemeManager())
}
