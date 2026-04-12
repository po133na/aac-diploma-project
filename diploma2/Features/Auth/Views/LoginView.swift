
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var localization: LocalizationManager
    var onRegisterTap: () -> Void

    @State private var email        = ""
    @State private var password     = ""
    @State private var rememberMe   = false
    @State private var showForgotPassword = false
    @FocusState private var focused: Field?

    private enum Field { case email, password }

    // Состояние ошибки тянем из ViewModel
    private var isError: Bool { authViewModel.loginError != nil }

    var body: some View {
        ZStack {
            AuthBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    AuthCard {
                        VStack(spacing: 20) {

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
                                Text(isError ? localization.loginUnsuccessful : localization.welcomeBack)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(AuthColors.titleText)

                                Text(isError
                                     ? localization.pleaseCheckCredentials
                                     : localization.signInToContinue)
                                    .font(.system(size: 14))
                                    .foregroundColor(AuthColors.subtitleText)
                            }

                            // Ошибка-баннер
                            if let error = authViewModel.loginError {
                                AuthErrorBanner(
                                    title: localization.incorrectEmailPassword,
                                    subtitle: error
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Поля
                            VStack(spacing: 14) {
                                AuthTextField(
                                    label: localization.emailAddress,
                                    placeholder: localization.emailPlaceholder,
                                    icon: "envelope",
                                    text: $email,
                                    isError: isError,
                                    keyboardType: .emailAddress
                                )
                                .focused($focused, equals: .email)

                                AuthSecureField(
                                    label: localization.password,
                                    placeholder: localization.passwordPlaceholder,
                                    text: $password,
                                    isError: isError
                                )
                                .focused($focused, equals: .password)
                            }

                            // Remember me + Forgot password
                            HStack {
                                Button {
                                    rememberMe.toggle()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: rememberMe
                                              ? "checkmark.square.fill"
                                              : "square")
                                            .foregroundColor(rememberMe
                                                ? AuthColors.buttonBlue
                                                : AuthColors.subtitleText)
                                            .font(.system(size: 16))
                                        Text(localization.rememberMe)
                                            .font(.system(size: 13))
                                            .foregroundColor(AuthColors.subtitleText)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())

                                Spacer()

                                Button(localization.forgotPasswordQ) {
                                    showForgotPassword = true
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AuthColors.titleText)
                                .underline()
                            }

                            // Кнопка Sign In
                            AuthButton(
                                title: isError ? localization.tryAgainArrow : localization.signInArrow,
                                color: isError ? AuthColors.buttonSalmon : AuthColors.buttonBlue,
                                isDisabled: email.isEmpty || password.isEmpty
                            ) {
                                focused = nil
                                authViewModel.loginError = nil
                                Task { await authViewModel.login(email: email, password: password, rememberMe: rememberMe) }
                            }

                            // Разделитель
                            HStack {
                                Rectangle().fill(AuthColors.fieldBorder).frame(height: 1)
                                Text(localization.or).font(.system(size: 13)).foregroundColor(AuthColors.subtitleText)
                                    .padding(.horizontal, 8)
                                Rectangle().fill(AuthColors.fieldBorder).frame(height: 1)
                            }

                            // Ссылка на регистрацию
                            AuthBottomLink(
                                prefix: localization.dontHaveAccount,
                                actionText: localization.signUpHere,
                                action: onRegisterTap
                            )
                        }
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isError)
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    LoginView(onRegisterTap: {})
        .environmentObject(AuthViewModel())
}
