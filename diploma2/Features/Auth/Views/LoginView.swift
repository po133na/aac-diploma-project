
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
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
                            AuthAvatar(color: isError
                                ? AuthColors.avatarSalmon
                                : AuthColors.avatarBlue)

                            // Заголовок
                            VStack(spacing: 6) {
                                Text(isError ? "Login unsuccessful" : "Welcome Back!")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(AuthColors.titleText)

                                Text(isError
                                     ? "Please check your credentials"
                                     : "Sign in to continue")
                                    .font(.system(size: 14))
                                    .foregroundColor(AuthColors.subtitleText)
                            }

                            // Ошибка-баннер
                            if let error = authViewModel.loginError {
                                AuthErrorBanner(
                                    title: "Incorrect email or password",
                                    subtitle: error
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Поля
                            VStack(spacing: 14) {
                                AuthTextField(
                                    label: "Email Address",
                                    placeholder: "your@email.com",
                                    icon: "envelope",
                                    text: $email,
                                    isError: isError,
                                    keyboardType: .emailAddress
                                )
                                .focused($focused, equals: .email)

                                AuthSecureField(
                                    label: "Password",
                                    placeholder: "Enter your password",
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
                                        Text("Remember me")
                                            .font(.system(size: 13))
                                            .foregroundColor(AuthColors.subtitleText)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())

                                Spacer()

                                Button("Forgot Password ?") {
                                    showForgotPassword = true
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AuthColors.titleText)
                                .underline()
                            }

                            // Кнопка Sign In
                            AuthButton(
                                title: isError ? "Try Again →" : "Sign In →",
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
                                Text("or").font(.system(size: 13)).foregroundColor(AuthColors.subtitleText)
                                    .padding(.horizontal, 8)
                                Rectangle().fill(AuthColors.fieldBorder).frame(height: 1)
                            }

                            // Ссылка на регистрацию
                            AuthBottomLink(
                                prefix: "Don't have an Account?",
                                actionText: "Sign Up here",
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
