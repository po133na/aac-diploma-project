// Features/Auth/ViewModels/AuthViewModel.swift

import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - State
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var selectedLanguage: AppLanguage = {
        let saved = UserDefaults.standard.string(forKey: "preferred_language") ?? "ru"
        return AppLanguage(rawValue: saved) ?? .russian
    }()

    // MARK: - Loading & Errors
    @Published var isLoading = false
    @Published var loginError: String?
    @Published var registerError: String?
    @Published var emailTakenError: String?

    private let authService = AuthService()

    // MARK: - Init — проверяем есть ли сохранённый токен
    init() {
        if APIClient.shared.isAuthenticated {
            Task { await tryRestoreSession() }
        }
    }

    // MARK: - Restore session

    private func tryRestoreSession() async {
        do {
            let user = try await authService.getMe()
            currentUser = user
            isAuthenticated = true
        } catch {
            // Токен просрочен — чистим
            authService.logout()
        }
    }

    // MARK: - Language

    func selectLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "preferred_language")
    }

    // MARK: - Login

    func login(email: String, password: String) async {
        isLoading = true
        loginError = nil
        defer { isLoading = false }

        do {
            let user = try await authService.login(email: email, password: password)
            currentUser = user
            isAuthenticated = true
        } catch APIError.unauthorized {
            loginError = "Double-check your information and try again"
        } catch APIError.serverError(401, _) {
            loginError = "Double-check your information and try again"
        } catch {
            loginError = error.localizedDescription
        }
    }

    // MARK: - Register

    func register(firstName: String, lastName: String, email: String, password: String) async {
        isLoading = true
        registerError = nil
        emailTakenError = nil
        defer { isLoading = false }

        do {
            // Регистрируемся (токен НЕ возвращается при регистрации — только UserResponse)
            _ = try await authService.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
            // Сразу логинимся чтобы получить токен
            let user = try await authService.login(email: email, password: password)
            currentUser = user
            // isAuthenticated выставим после экрана успеха
        } catch APIError.serverError(400, let msg) where msg.contains("already registered") {
            emailTakenError = "This email is already in use"
        } catch APIError.serverError(400, _) {
            emailTakenError = "This email is already in use"
        } catch {
            registerError = error.localizedDescription
        }
    }

    // После экрана успеха
    func completeRegistration() {
        isAuthenticated = true
    }

    // MARK: - Logout

    func logout() {
        authService.logout()
        currentUser = nil
        isAuthenticated = false
        loginError = nil
        registerError = nil
        emailTakenError = nil
    }
}
