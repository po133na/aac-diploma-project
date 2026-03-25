//
//  AuthService.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

// Services/AuthService.swift

import Foundation

final class AuthService {
    private let client = APIClient.shared

    struct RegisterRequest: Encodable {
        let email: String
        let username: String
        let password: String
    }

    struct LoginRequest: Encodable {
        let email: String
        let password: String
    }

    struct ForgotPasswordRequest: Encodable {
        let email: String
    }

    struct ChangePasswordRequest: Encodable {
        let oldPassword: String
        let newPassword: String
        enum CodingKeys: String, CodingKey {
            case oldPassword = "old_password"
            case newPassword = "new_password"
        }
    }

    // Регистрация — склеиваем firstName + lastName → username
    func register(firstName: String, lastName: String, email: String, password: String) async throws -> User {
        let username = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        let body = RegisterRequest(email: email, username: username, password: password)
        let user: User = try await client.request(path: "/auth/register", method: "POST", body: body)
        return user
    }

    // Логин — получаем токен, сохраняем
    func login(email: String, password: String) async throws -> User {
        let body = LoginRequest(email: email, password: password)
        let tokenResponse: TokenResponse = try await client.request(
            path: "/auth/login",
            method: "POST",
            body: body
        )
        client.saveToken(tokenResponse.accessToken)

        // Получаем данные пользователя
        let user: User = try await client.request(path: "/auth/me")
        return user
    }

    // Получить текущего пользователя
    func getMe() async throws -> User {
        return try await client.request(path: "/auth/me")
    }

    // Выход
    func logout() {
        client.clearToken()
    }

    // Забыл пароль
    func forgotPassword(email: String) async throws -> MessageResponse {
        let body = ForgotPasswordRequest(email: email)
        return try await client.request(path: "/auth/forgot-password", method: "POST", body: body)
    }

    // Смена пароля (авторизованный)
    func changePassword(old: String, new: String) async throws -> MessageResponse {
        let body = ChangePasswordRequest(oldPassword: old, newPassword: new)
        return try await client.request(path: "/auth/change-password", method: "POST", body: body)
    }
}
