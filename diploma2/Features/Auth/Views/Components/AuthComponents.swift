//
//  AuthComponents.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

import SwiftUI

// MARK: - Design Tokens

enum AuthColors {
    // Фон
    static let gradientTop    = Color(hex: "C8E6E4")
    static let gradientBottom = Color(hex: "D4EDF7")

    // Карточка
    static let card           = Color(hex: "EAF4F9").opacity(0.85)

    // Текст
    static let titleText      = Color(hex: "1C3F6E")
    static let subtitleText   = Color(hex: "6B8BAE")
    static let labelText      = Color(hex: "1C3F6E")

    // Поля ввода
    static let fieldBg        = Color(hex: "EEF5F9")
    static let fieldIcon      = Color(hex: "9BB8CC")
    static let fieldBorder    = Color(hex: "D0E5F0")
    static let fieldError     = Color(hex: "F87171")

    // Кнопки
    static let buttonBlue     = Color(hex: "5BAECC")  // Step 1 / Login
    static let buttonGreen    = Color(hex: "6DBF82")  // Step 2
    static let buttonSalmon   = Color(hex: "F87171")  // Try Again (ошибка)
    static let buttonDisabled = Color(hex: "C5D8E2")

    // Баннеры
    static let errorBannerBg  = Color(hex: "FFE8E8")
    static let errorBannerText = Color(hex: "D64545")
    static let hintBannerBg   = Color(hex: "E8F5EC")
    static let hintBannerText = Color(hex: "3A8A52")

    // Бейдж Step
    static let stepBadge      = Color(hex: "5BAECC")

    // Аватар-плейсхолдер
    static let avatarBlue     = Color(hex: "87BDD8")
    static let avatarGreen    = Color(hex: "6DBF82")
    static let avatarSalmon   = Color(hex: "F4A59A")

    // Язык
    static let languageRow    = Color.white.opacity(0.85)
}

// MARK: - Color hex init (помещается в Extensions/Color+Ext.swift)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Auth Background

struct AuthBackground: View {
    var body: some View {
        LinearGradient(
            colors: [AuthColors.gradientTop, AuthColors.gradientBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Auth Card Container

struct AuthCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AuthColors.card)
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
            )
            .padding(.horizontal, 20)
    }
}

// MARK: - Avatar Placeholder

struct AuthAvatar: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 80, height: 80)
            .padding(.bottom, 4)
    }
}

// MARK: - Step Badge ("Step 1/2")

struct StepBadge: View {
    let current: Int
    let total: Int

    var body: some View {
        Text("Step \(current)/\(total)")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(AuthColors.stepBadge)
            )
    }
}

// MARK: - Progress Dots

struct ProgressDots: View {
    let total: Int
    let current: Int   // 1-based

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...total, id: \.self) { index in
                Circle()
                    .fill(index == current ? AuthColors.buttonBlue : AuthColors.fieldBorder)
                    .frame(width: 10, height: 10)
                    .animation(.easeInOut(duration: 0.2), value: current)
            }
        }
    }
}

// MARK: - Back Button

struct AuthBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AuthColors.titleText)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                )
        }
    }
}

// MARK: - Auth Text Field

struct AuthTextField: View {
    let label: String
    let placeholder: String
    let icon: String
    @Binding var text: String
    var isError: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AuthColors.labelText)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(AuthColors.fieldIcon)
                    .frame(width: 18)

                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .font(.system(size: 15))
                    .foregroundColor(AuthColors.titleText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AuthColors.fieldBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isError ? AuthColors.fieldError : Color.clear, lineWidth: 1.5)
                    )
            )
        }
    }
}

// MARK: - Auth Secure Field

struct AuthSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isError: Bool = false
    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AuthColors.labelText)

            HStack(spacing: 10) {
                Image(systemName: "person.circle")
                    .foregroundColor(AuthColors.fieldIcon)
                    .frame(width: 18)

                Group {
                    if isVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .autocapitalization(.none)
                .font(.system(size: 15))
                .foregroundColor(AuthColors.titleText)

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye" : "eye.slash")
                        .foregroundColor(AuthColors.fieldIcon)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AuthColors.fieldBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isError ? AuthColors.fieldError : Color.clear, lineWidth: 1.5)
                    )
            )
        }
    }
}

// MARK: - Auth Primary Button

struct AuthButton: View {
    let title: String
    let color: Color
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isDisabled ? AuthColors.buttonDisabled : color)
            )
        }
        .disabled(isDisabled)
    }
}

// MARK: - Error Banner

struct AuthErrorBanner: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AuthColors.errorBannerText)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(AuthColors.errorBannerText.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AuthColors.errorBannerBg)
        )
    }
}

// MARK: - Hint Banner ("Almost done!")

struct AuthHintBanner: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(AuthColors.hintBannerText)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AuthColors.hintBannerBg)
            )
    }
}

// MARK: - Password Requirements List

struct PasswordRequirementsView: View {
    let password: String

    private var hasMinLength: Bool { password.count >= 8 }
    private var hasNumber: Bool    { password.contains(where: \.isNumber) }
    private var hasUppercase: Bool { password.contains(where: \.isUppercase) }

    var allMet: Bool { hasMinLength && hasNumber && hasUppercase }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RequirementRow(met: hasMinLength, text: "At least 8 characters")
            RequirementRow(met: hasNumber,    text: "At least 1 number")
            RequirementRow(met: hasUppercase, text: "At least 1 uppercase letter")
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AuthColors.fieldBg)
        )
    }
}

private struct RequirementRow: View {
    let met: Bool
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(met ? Color(hex: "6DBF82") : AuthColors.fieldError)
                .font(.system(size: 15))
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AuthColors.subtitleText)
        }
    }
}

// MARK: - Inline field error

struct FieldErrorText: View {
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 12))
                .foregroundColor(AuthColors.fieldError)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(AuthColors.fieldError)
        }
    }
}

// MARK: - Bottom link ("Already have an account? Login here")

struct AuthBottomLink: View {
    let prefix: String
    let actionText: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(prefix)
                .font(.system(size: 13))
                .foregroundColor(AuthColors.subtitleText)
            Button(action: action) {
                Text(actionText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AuthColors.titleText)
                    .underline()
            }
        }
    }
}
