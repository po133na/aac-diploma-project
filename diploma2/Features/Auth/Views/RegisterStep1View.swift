// Features/Auth/Views/RegisterStep1View.swift
// Шаг 1/2 — Имя, Фамилия, Email

import SwiftUI

struct RegisterStep1View: View {
    @EnvironmentObject var authViewModel: AuthViewModel

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
                            AuthAvatar(color: AuthColors.avatarBlue)

                            // Заголовок
                            VStack(spacing: 6) {
                                Text("Welcome! 👋")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(AuthColors.titleText)

                                // Если email занят — показываем подсказку вместо subtitle
                                Text(isEmailTaken
                                     ? "Email already taken"
                                     : "Let's get to know you better")
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
                                    label: "First Name",
                                    placeholder: "Enter your name",
                                    icon: "person",
                                    text: $firstName
                                )

                                AuthTextField(
                                    label: "Last Name",
                                    placeholder: "Enter your surname",
                                    icon: "person",
                                    text: $lastName
                                )

                                // Email с inline ошибкой
                                VStack(alignment: .leading, spacing: 4) {
                                    AuthTextField(
                                        label: "Email Address",
                                        placeholder: "your@email.com",
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
                                title: "Continue →",
                                color: AuthColors.buttonBlue,
                                isDisabled: !canContinue
                            ) {
                                authViewModel.emailTakenError = nil
                                onContinue()
                            }

                            // Ссылка на логин
                            AuthBottomLink(
                                prefix: "Already have an account?",
                                actionText: "Login here",
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
