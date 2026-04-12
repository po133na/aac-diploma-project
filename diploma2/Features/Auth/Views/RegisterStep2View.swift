//
//  RegisterView2.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//


import SwiftUI

struct RegisterStep2View: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var localization: LocalizationManager

    @Binding var password:        String
    @Binding var confirmPassword: String

    var onBack: () -> Void
    var onContinue: () -> Void   // Вызывается когда регистрация прошла

    // Требования к паролю
    private var hasMinLength: Bool  { password.count >= 8 }
    private var hasNumber: Bool     { password.contains(where: \.isNumber) }
    private var hasUppercase: Bool  { password.contains(where: \.isUppercase) }
    private var passwordsMatch: Bool { password == confirmPassword && !confirmPassword.isEmpty }

    private var allRequirementsMet: Bool {
        hasMinLength && hasNumber && hasUppercase && passwordsMatch
    }

    // Показывать ли красные рамки (ввод начат, но требования не выполнены)
    private var showPasswordError: Bool {
        !password.isEmpty && !(hasMinLength && hasNumber && hasUppercase)
    }
    private var showConfirmError: Bool {
        !confirmPassword.isEmpty && !passwordsMatch
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
                                StepBadge(current: 2, total: 2)
                            }

                            Image("onboarding_image")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 170, height: 170)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                                .padding(.bottom, 40)

                            // Заголовок
                            VStack(spacing: 6) {
                                Text(localization.staySafe)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(AuthColors.titleText)

                                Text(allRequirementsMet
                                     ? localization.lookingGoodAlmost
                                     : localization.secureYourAccount)
                                    .font(.system(size: 14))
                                    .foregroundColor(AuthColors.subtitleText)
                                    .animation(.easeInOut, value: allRequirementsMet)
                            }

                            // Прогресс-точки
                            ProgressDots(total: 2, current: 2)

                            // Поля пароля
                            VStack(spacing: 14) {
                                AuthSecureField(
                                    label: localization.createPasswordLabel,
                                    placeholder: localization.passwordPlaceholder,
                                    text: $password,
                                    isError: showPasswordError
                                )

                                AuthSecureField(
                                    label: localization.confirmPasswordLabel,
                                    placeholder: localization.repeatPasswordPlaceholder,
                                    text: $confirmPassword,
                                    isError: showConfirmError
                                )
                            }

                            // Требования к паролю
                            if !password.isEmpty {
                                PasswordRequirementsView(password: password)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Hint баннер — появляется когда всё хорошо
                            if allRequirementsMet {
                                AuthHintBanner(text: localization.almostDoneBanner)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }

                            // Ошибка регистрации с сервера
                            if let error = authViewModel.registerError {
                                AuthErrorBanner(
                                    title: localization.registrationFailed,
                                    subtitle: error
                                )
                                .transition(.opacity)
                            }

                            // Кнопка Continue — зелёная на шаге 2
                            AuthButton(
                                title: authViewModel.isLoading ? localization.creatingAccount : localization.continueArrow,
                                color: AuthColors.buttonGreen,
                                isDisabled: !allRequirementsMet || authViewModel.isLoading
                            ) {
                                onContinue()
                            }

                            // Ссылка на логин
                            AuthBottomLink(
                                prefix: localization.alreadyHaveAccount,
                                actionText: localization.loginHere,
                                action: {
                                    // Сбрасываем всё и идём на логин
                                    password = ""
                                    confirmPassword = ""
                                    onBack()   // Регистрацию закроет AuthRootView
                                }
                            )
                        }
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: allRequirementsMet)
        .animation(.easeInOut(duration: 0.2),  value: password.isEmpty)
    }
}

#Preview {
    RegisterStep2View(
        password: .constant("Test1234"),
        confirmPassword: .constant("Test1234"),
        onBack: {},
        onContinue: {}
    )
    .environmentObject(AuthViewModel())
}
