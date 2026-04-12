import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var viewModel = ProfileViewModel()

    @State private var showLogOutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var expandedSection: SettingsSection? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBgAlt").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        ProfileHeaderSection()
                            .padding(.top, 28)
                            .padding(.bottom, 24)

                        SectionHeader(icon: "chart.bar.fill", title: localization.activityOverview)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                        ActivityCard(viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)

                        SectionHeader(icon: "gearshape.fill", title: localization.settings)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)

                        SettingsAccordionCard(expandedSection: $expandedSection, viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)

                        // Log Out
                        ActionRow(
                            icon: "rectangle.portrait.and.arrow.right.fill",
                            iconBg: Color(hex: "5BAECC"),
                            title: localization.logOut,
                            titleColor: Color("AppTextPrimary")
                        ) {
                            showLogOutConfirm = true
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                        // Delete Account
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

                // ── Log Out Modal ──
                if showLogOutConfirm {
                    ConfirmActionModal(
                        icon: "rectangle.portrait.and.arrow.right.fill",
                        iconBg: Color(hex: "5BAECC"),
                        title: "Log Out ?",
                        subtitle: "You'll need to sign in again to use SpeakEasy. Your cards and data will be saved.",
                        buttonTitle: "Log Out",
                        buttonColor: Color(hex: "5BAECC"),
                        onCancel: { showLogOutConfirm = false },
                        onConfirm: {
                            showLogOutConfirm = false
                            authViewModel.logout()
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // ── Delete Account Modal ──
                if showDeleteConfirm {
                    ConfirmActionModal(
                        icon: "trash.fill",
                        iconBg: Color(hex: "F87171"),
                        title: "Delete your Account ?",
                        subtitle: "All your cards, categories and data will be permanently deleted. This cannot be undone.",
                        buttonTitle: "Delete Account",
                        buttonColor: Color(hex: "F87171"),
                        onCancel: { showDeleteConfirm = false },
                        onConfirm: {
                            showDeleteConfirm = false
                            // TODO: удаление аккаунта
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showLogOutConfirm)
            .animation(.easeInOut(duration: 0.2), value: showDeleteConfirm)
        }
        .onAppear {
            Task { await viewModel.loadStats() }
        }
    }
}

// MARK: - Confirm Action Modal

struct ConfirmActionModal: View {
    let icon: String
    let iconBg: Color
    let title: String
    let subtitle: String
    let buttonTitle: String
    let buttonColor: Color
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: onCancel) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "F0F0F0"))
                                .frame(width: 30, height: 30)
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "888888"))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                ZStack {
                    Circle()
                        .fill(iconBg.opacity(0.2))
                        .frame(width: 64, height: 64)
                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(iconBg)
                }

                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "1C3F6E"))
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6B8BAE"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                Button(action: onConfirm) {
                    Text(buttonTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(buttonColor))
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
            )
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Profile Header

private struct ProfileHeaderSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var avatarImage: UIImage? = nil

    private let avatarKey = "profile_avatar_base64"

    private var initials: String {
        let parts = (authViewModel.currentUser?.name ?? "LL")
            .split(separator: " ").prefix(2)
            .map { String($0.prefix(1)).uppercased() }
        return parts.joined()
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                if let img = avatarImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 88, height: 88)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(hex: "87BDD8").opacity(0.55))
                        .frame(width: 88, height: 88)
                        .overlay(
                            Text(initials)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color(hex: "2C5F7A"))
                        )
                }
                NavigationLink(destination: EditProfileSheet()) {
                    ZStack {
                        Circle().fill(Color(hex: "5BAECC")).frame(width: 26, height: 26)
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
        .onAppear {
            if let base64 = UserDefaults.standard.string(forKey: avatarKey),
               let data = Data(base64Encoded: base64) {
                avatarImage = UIImage(data: data)
            } else {
                avatarImage = nil
            }
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

    private var cardsUsed: Int { viewModel.stats?.thisWeekCards ?? 0 }
    private var streak: Int { viewModel.stats?.currentStreak ?? 0 }
    private var barData: [CGFloat] {
        guard let weeklyData = viewModel.stats?.weeklyData, !weeklyData.isEmpty else {
            return [0.3, 0.5, 0.4, 0.7, 0.6, 0.85, 1.0]
        }
        let maxValue = weeklyData.max() ?? 1.0
        return weeklyData.map { CGFloat($0 / max(maxValue, 1.0)) }
    }

    var body: some View {
        let l = LocalizationManager.shared
        VStack(alignment: .leading, spacing: 12) {
            Text(l.thisWeek)
                .font(.system(size: 14))
                .foregroundColor(Color("AppTextSecondary"))

            HStack(alignment: .bottom) {
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
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(barData.indices, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i == barData.count - 1 ? Color(hex: "5BAECC") : Color(hex: "C5D8E8"))
                            .frame(width: 8, height: 40 * barData[i])
                    }
                }
                .frame(height: 40)
            }

            HStack(spacing: 6) {
                Circle().fill(Color(hex: "F5A623")).frame(width: 8, height: 8)
                Text("\(streak) \(l.dayStreak)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("AppTextSecondary"))
            }

            Divider().background(Color("AppBorderLight"))

            NavigationLink(destination: FullStatsView(stats: viewModel.stats)) {
                Text(l.seeFullStats)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "5BAECC"))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface"))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Settings Accordion

enum SettingsSection: Identifiable, CaseIterable {
    case communication, accessibility, support

    var id: Self { self }

    func localizedTitle(_ l: LocalizationManager) -> String {
        switch self {
        case .communication: return "Communication"
        case .accessibility: return l.accessibility
        case .support:       return l.supportAbout
        }
    }

    var icon: String {
        switch self {
        case .communication: return "message.fill"
        case .accessibility: return "figure.roll"
        case .support:       return "questionmark.circle.fill"
        }
    }

    var iconBg: Color {
        switch self {
        case .communication: return Color(hex: "B8D8F0")
        case .accessibility: return Color(hex: "A8E8B0")
        case .support:       return Color(hex: "F5DEB0")
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
                    if idx > 0 { Divider().padding(.leading, 54) }
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
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("AppTextHint"))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(PlainButtonStyle())

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
            case .communication: CommunicationSettings()
            case .accessibility: AccessibilitySettings(viewModel: viewModel)
            case .support:       SupportSettings()
            }
        }
    }
}

// MARK: - Communication Settings

private struct CommunicationSettings: View {
    @EnvironmentObject var localization: LocalizationManager
    @State private var voiceType: String = UserDefaults.standard.string(forKey: "voice_type") ?? "female"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Voice type
            VStack(alignment: .leading, spacing: 10) {
                Text("Voice type")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("AppTextSecondary"))
                    .padding(.horizontal, 16)

                HStack(spacing: 10) {
                    SegmentButton(title: "Male", isSelected: voiceType == "male") {
                        voiceType = "male"
                        UserDefaults.standard.set("male", forKey: "voice_type")
                    }
                    SegmentButton(title: "Female", isSelected: voiceType == "female") {
                        voiceType = "female"
                        UserDefaults.standard.set("female", forKey: "voice_type")
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 14)

            // Language
            VStack(alignment: .leading, spacing: 10) {
                Text("Language")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("AppTextSecondary"))
                    .padding(.horizontal, 16)

                HStack(spacing: 10) {
                    SegmentButton(title: "KK", isSelected: localization.currentLanguage == .kazakh) {
                        localization.currentLanguage = .kazakh
                    }
                    SegmentButton(title: "EN", isSelected: localization.currentLanguage == .english) {
                        localization.currentLanguage = .english
                    }
                    SegmentButton(title: "RU", isSelected: localization.currentLanguage == .russian) {
                        localization.currentLanguage = .russian
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Accessibility Settings

private struct AccessibilitySettings: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Theme")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("AppTextSecondary"))
                    .padding(.horizontal, 16)

                HStack(spacing: 10) {
                    SegmentButton(
                        title: "Light",
                        isSelected: !viewModel.darkTheme,
                        selectedBg: Color(hex: "F5A623")
                    ) {
                        viewModel.darkTheme = false
                    }
                    SegmentButton(
                        title: "Dark",
                        isSelected: viewModel.darkTheme,
                        selectedBg: Color(hex: "6DBF82")
                    ) {
                        viewModel.darkTheme = true
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 14)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Support Settings

private struct SupportSettings: View {
    var body: some View {
        VStack(spacing: 0) {
            // Email us
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "A8E8B0"))
                        .frame(width: 34, height: 34)
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("AppTextPrimary"))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Email us")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("AppTextPrimary"))
                    Text("@unim_support@gmail.com")
                        .font(.system(size: 12))
                        .foregroundColor(Color("AppTextSecondary"))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider().padding(.leading, 16)

            // Version
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "D8B8F0"))
                        .frame(width: 34, height: 34)
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("AppTextPrimary"))
                }
                Text("Version")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("AppTextPrimary"))
                Spacer()
                Text("1.2.0")
                    .font(.system(size: 14))
                    .foregroundColor(Color("AppTextSecondary"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .padding(.bottom, 4)
    }
}

// MARK: - Segment Button

struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    var selectedBg: Color = Color(hex: "1C3F6E")
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? selectedBg : Color("AppBgAlt"))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Action Row

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

// MARK: - Edit Profile

struct EditProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var showRemovePhotoConfirm = false
    @State private var isSaving = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? = nil

    private let avatarKey = "profile_avatar_base64"

    private var initials: String {
        let parts = (authViewModel.currentUser?.name ?? "LL")
            .split(separator: " ").prefix(2)
            .map { String($0.prefix(1)).uppercased() }
        return parts.joined()
    }

    var body: some View {
        ZStack {
            Color("AppBgAlt").ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Навбар ──
                HStack {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 15))
                        .foregroundColor(Color("AppTextSecondary"))

                    Spacer()

                    Text("Edit profile")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("AppTextPrimary"))

                    Spacer()

                    Button {
                        isSaving = true
                        Task {
                            let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                            await authViewModel.updateProfile(name: fullName)
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        if isSaving {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Text("Save")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "5BAECC"))
                        }
                    }
                    .disabled(isSaving)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        // ── Аватар ──
                        ZStack(alignment: .bottomTrailing) {
                            if let img = avatarImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 88, height: 88)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color(hex: "87BDD8").opacity(0.55))
                                    .frame(width: 88, height: 88)
                                    .overlay(
                                        Text(initials)
                                            .font(.system(size: 30, weight: .bold))
                                            .foregroundColor(Color(hex: "2C5F7A"))
                                    )
                            }
                            ZStack {
                                Circle().fill(Color(hex: "5BAECC")).frame(width: 26, height: 26)
                                Image(systemName: "pencil")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 2, y: 2)
                        }
                        .padding(.top, 20)

                        // ── Кнопки фото ──
                        HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                HStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Change photo")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "5BAECC"))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button {
                                guard avatarImage != nil else { return }
                                showRemovePhotoConfirm = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Remove Photo")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "F87171"))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)

                        // ── Поля имени ──
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Firstname")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color("AppTextPrimary"))

                                HStack(spacing: 10) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color("AppTextHint"))
                                    TextField("First name", text: $firstName)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color("AppTextPrimary"))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "EAF6FB"))
                                )
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Lastname")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color("AppTextPrimary"))

                                HStack(spacing: 10) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color("AppTextHint"))
                                    TextField("Last name", text: $lastName)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color("AppTextPrimary"))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "EAF6FB"))
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }

            // ── Remove photo modal ──
            if showRemovePhotoConfirm {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture { showRemovePhotoConfirm = false }

                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                            Button { showRemovePhotoConfirm = false } label: {
                                ZStack {
                                    Circle().fill(Color(hex: "F0F0F0")).frame(width: 30, height: 30)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color(hex: "888888"))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        ZStack {
                            Circle().fill(Color(hex: "FECACA")).frame(width: 64, height: 64)
                            Image(systemName: "trash.fill")
                                .font(.system(size: 26))
                                .foregroundColor(Color(hex: "F87171"))
                        }

                        Text("Remove your photo?")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "1C3F6E"))
                            .multilineTextAlignment(.center)

                        Button {
                            showRemovePhotoConfirm = false
                            avatarImage = nil
                            UserDefaults.standard.removeObject(forKey: avatarKey)
                        } label: {
                            Text("Remove")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Capsule().fill(Color(hex: "F87171")))
                        }
                        .padding(.horizontal, 4)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
                    )
                    .padding(.horizontal, 32)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showRemovePhotoConfirm)
        .navigationBarHidden(true)
        .onAppear {
            let parts = (authViewModel.currentUser?.name ?? "").split(separator: " ")
            firstName = parts.first.map(String.init) ?? ""
            lastName = parts.dropFirst().first.map(String.init) ?? ""
            if let base64 = UserDefaults.standard.string(forKey: avatarKey),
               let data = Data(base64Encoded: base64) {
                avatarImage = UIImage(data: data)
            }
        }
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    avatarImage = image
                    UserDefaults.standard.set(data.base64EncodedString(), forKey: avatarKey)
                }
            }
        }
    }
}
// MARK: - Full Stats

struct FullStatsView: View {
    let stats: UserStats?

    var body: some View {
        let l = LocalizationManager.shared
        ZStack {
            Color("AppBgAlt").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
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
                    if let topCards = stats?.topCards, !topCards.isEmpty {
                        MostUsedCardsCard(topCards: Array(topCards.prefix(5)))
                    }
                    if let topPhrases = stats?.topPhrases, !topPhrases.isEmpty {
                        StatsCard(
                            title: l.mostUsedPhrases,
                            items: topPhrases.prefix(5).map { ("\($0.name)", "\($0.usageCount) \(l.uses)") }
                        )
                    }
                    if let weeklyData = stats?.weeklyData, !weeklyData.isEmpty {
                        WeeklyChartView(data: weeklyData).padding(.horizontal, 16)
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
                        Text(item.0).font(.system(size: 14)).foregroundColor(Color("AppTextPrimary"))
                        Spacer()
                        Text(item.1).font(.system(size: 14, weight: .medium)).foregroundColor(Color(hex: "5BAECC"))
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    if index < items.count - 1 { Divider().padding(.leading, 16) }
                }
            }
            .background(RoundedRectangle(cornerRadius: 18).fill(Color("AppSurface")).shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2))
            .padding(.horizontal, 16)
        }
    }
}

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
                                Image(systemName: "star.fill").font(.system(size: 12)).foregroundColor(Color(hex: "F5A623"))
                            }
                            Text(card.word).font(.system(size: 14)).foregroundColor(Color("AppTextPrimary"))
                            Spacer()
                            Text("\(card.usageCount) \(l.uses)").font(.system(size: 14, weight: .medium)).foregroundColor(Color(hex: "5BAECC"))
                            Image(systemName: "chevron.right").font(.system(size: 11)).foregroundColor(Color("AppTextHint"))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    if index < topCards.count - 1 { Divider().padding(.leading, 16) }
                }
            }
            .background(RoundedRectangle(cornerRadius: 18).fill(Color("AppSurface")).shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2))
            .padding(.horizontal, 16)
        }
    }
}

struct TopCardDetailView: View {
    let card: TopCard
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
                            Image(uiImage: img).resizable().scaledToFit()
                                .frame(width: 200, height: 200).cornerRadius(20)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 20).fill(Color("AppPlaceholderBg"))
                                .frame(width: 200, height: 200)
                                .overlay(Image(systemName: "photo").font(.system(size: 40)).foregroundColor(Color("AppTextHint")))
                        }
                        Text(card.word).font(.system(size: 28, weight: .bold)).foregroundColor(Color("AppTextPrimary"))
                        HStack(spacing: 6) {
                            Image(systemName: "hand.tap.fill").foregroundColor(Color(hex: "5BAECC"))
                            Text("\(LocalizationManager.shared.uses): \(card.usageCount)").font(.system(size: 16)).foregroundColor(Color("AppTextSecondary"))
                        }
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Capsule().fill(Color("AppSurface")).shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2))
                        Button {
                            Task { await TTSService.shared.speak(text: card.word, language: .russian) }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text(LocalizationManager.shared.speak).font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white).padding(.horizontal, 32).padding(.vertical, 14)
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
                if !fetched.imageBase64.isEmpty, let data = Data(base64Encoded: fetched.imageBase64) {
                    uiImage = UIImage(data: data)
                }
            }
            isLoading = false
        }
    }
}

struct WeeklyChartView: View {
    let data: [Double]
    private var maxValue: Double { data.max() ?? 1.0 }

    var body: some View {
        let l = LocalizationManager.shared
        VStack(alignment: .leading, spacing: 12) {
            Text(l.weeklyActivity).font(.system(size: 16, weight: .bold)).foregroundColor(Color("AppTextPrimary"))
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data.indices, id: \.self) { index in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index == data.count - 1 ? Color(hex: "5BAECC") : Color(hex: "C5D8E8"))
                            .frame(width: 20, height: CGFloat(100 * data[index] / max(maxValue, 1.0)))
                        Text(dayLabel(for: index)).font(.system(size: 11)).foregroundColor(Color("AppTextSecondary"))
                    }
                }
            }
            .frame(height: 120).padding(12)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color("AppSurface")).shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2))
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
