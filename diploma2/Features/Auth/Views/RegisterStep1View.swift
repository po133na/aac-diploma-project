// Features/Auth/Views/RegisterStep1View.swift
// Шаг 1/2 — Имя, Фамилия, Email

import SwiftUI

struct RegisterStep1View: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var localization: LocalizationManager

    @Binding var firstName: String
    @Binding var lastName:  String
    @Binding var email:     String

    var onBack: () -> Void
    var onContinue: () -> Void

    // Inline ошибка под полем email (если email занят)
    private var isEmailTaken: Bool { authViewModel.emailTakenError != nil }

    private var canContinue: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".")
    }

    var body: some View {
        ZStack {
            AuthBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    AuthCard {
                        VStack(spacing: 18) {

                            // Top nav
                            HStack {
                                AuthBackButton(action: onBack)
                                Spacer()
                                StepBadge(current: 1, total: 2)
                            }

                            // Аватар
                            Image("onboarding_image")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 170, height: 170)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                                .padding(.bottom, 40)

                            // Заголовок
                            VStack(spacing: 6) {
                                Text(localization.welcomeEmoji)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(AuthColors.titleText)

                                // Если email занят — показываем подсказку вместо subtitle
                                Text(isEmailTaken
                                     ? localization.emailAlreadyTaken
                                     : localization.letsGetToKnowYou)
                                    .font(.system(size: 14))
                                    .foregroundColor(isEmailTaken
                                        ? AuthColors.fieldError
                                        : AuthColors.subtitleText)
                                    .animation(.easeInOut, value: isEmailTaken)
                            }

                            // Прогресс-точки
                            ProgressDots(total: 2, current: 1)

                            // Поля
                            VStack(spacing: 14) {
                                AuthTextField(
                                    label: localization.firstName,
                                    placeholder: localization.enterNamePlaceholder,
                                    icon: "person",
                                    text: $firstName
                                )

                                AuthTextField(
                                    label: localization.lastName,
                                    placeholder: localization.enterSurnamePlaceholder,
                                    icon: "person",
                                    text: $lastName
                                )

                                // Email с inline ошибкой
                                VStack(alignment: .leading, spacing: 4) {
                                    AuthTextField(
                                        label: localization.emailAddress,
                                        placeholder: localization.emailPlaceholder,
                                        icon: "person",
                                        text: $email,
                                        isError: isEmailTaken,
                                        keyboardType: .emailAddress
                                    )

                                    if let errMsg = authViewModel.emailTakenError {
                                        FieldErrorText(text: errMsg)
                                            .padding(.leading, 4)
                                            .transition(.opacity)
                                    }
                                }
                                .animation(.easeInOut(duration: 0.2), value: isEmailTaken)
                            }

                            // Кнопка Continue
                            AuthButton(
                                title: localization.continueArrow,
                                color: AuthColors.buttonBlue,
                                isDisabled: !canContinue
                            ) {
                                authViewModel.emailTakenError = nil
                                onContinue()
                            }

                            // Ссылка на логин
                            AuthBottomLink(
                                prefix: localization.alreadyHaveAccount,
                                actionText: localization.loginHere,
                                action: onBack
                            )
                        }
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        // Сбрасываем ошибку email при изменении поля
        .onChange(of: email) { _ in
            authViewModel.emailTakenError = nil
        }
    }
}

#Preview {
    RegisterStep1View(
        firstName: .constant("Polina"),
        lastName: .constant("Stelmakh"),
        email: .constant("polya@gmail.com"),
        onBack: {},
        onContinue: {}
    )
    .environmentObject(AuthViewModel())
}
