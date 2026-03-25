//
//  AuthRootView.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//


import SwiftUI

enum AuthScreen {
    case language
    case login
    case registerStep1
    case registerStep2
    case registerSuccess
}

struct AuthRootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    // Текущий экран флоу
    @State private var currentScreen: AuthScreen = .language

    // Данные регистрации — живут здесь, передаются в шаги через Binding
    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var email     = ""
    @State private var password  = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            // Переключение экранов с анимацией
            switch currentScreen {

            case .language:
                LanguageSelectView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen = .login
                    }
                }
                .transition(.opacity)

            case .login:
                LoginView(onRegisterTap: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen = .registerStep1
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

            case .registerStep1:
                RegisterStep1View(
                    firstName: $firstName,
                    lastName:  $lastName,
                    email:     $email,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .login
                        }
                    },
                    onContinue: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .registerStep2
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

            case .registerStep2:
                RegisterStep2View(
                    password:        $password,
                    confirmPassword: $confirmPassword,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .registerStep1
                        }
                    },
                    onContinue: {
                        // Запускаем регистрацию
                        Task {
                            await authViewModel.register(
                                firstName:  firstName,
                                lastName:   lastName,
                                email:      email,
                                password:   password
                            )
                            // Если ошибка emailTaken — отправляем на шаг 1
                            if authViewModel.emailTakenError != nil {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentScreen = .registerStep1
                                }
                                return
                            }
                            // Если нет ошибок — успех
                            if authViewModel.registerError == nil {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentScreen = .registerSuccess
                                }
                            }
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))

            case .registerSuccess:
                RegisterSuccessView {
                    // Переход на главный экран — authViewModel.isAuthenticated = true
                    authViewModel.completeRegistration()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentScreen)
    }
}

#Preview {
    AuthRootView()
        .environmentObject(AuthViewModel())
}
