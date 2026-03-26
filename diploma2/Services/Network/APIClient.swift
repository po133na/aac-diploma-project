// Services/Network/APIClient.swift
//
//import Foundation
//
//// MARK: - API Error
//
//enum APIError: Error, LocalizedError {
//    case invalidURL
//    case noData
//    case decodingError(Error)
//    case serverError(Int, String)
//    case unauthorized
//    case noConnection
//
//    var errorDescription: String? {
//        switch self {
//        case .unauthorized:
//            return "Сессия истекла. Войдите снова."
//        case .noConnection:
//            return "Нет подключения к интернету."
//        case .serverError(let code, let msg):
//            return "Ошибка \(code): \(msg)"
//        case .decodingError(let err):
//            return "Ошибка данных: \(err.localizedDescription)"
//        default:
//            return "Что-то пошло не так."
//        }
//    }
//}
//
//// MARK: - API Client
//
//final class APIClient {
//    static let shared = APIClient()
//
//    // При деплое заменить на реальный URL
//    // Для симулятора: http://127.0.0.1:8000
//    // Для реального устройства: http://YOUR_MAC_IP:8000
//    private let baseURL = "http://195.133.194.88:8000"
//
//    private var token: String? {
//        get { UserDefaults.standard.string(forKey: "auth_token") }
//        set { UserDefaults.standard.set(newValue, forKey: "auth_token") }
//    }
//
//    func saveToken(_ token: String) {
//        self.token = token
//    }
//
//    func clearToken() {
//        token = nil
//    }
//
//    var isAuthenticated: Bool { token != nil }
//
//    // MARK: - Generic Request
//
//    func request<T: Decodable>(
//        path: String,
//        method: String,
//        body: Any)
//    async throws -> T{
//
//        // Собираем URL
//        var components = URLComponents(string: baseURL + path)!
//        if let queryItems { components.queryItems = queryItems }
//
//        guard let url = components.url else { throw APIError.invalidURL }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.timeoutInterval = 30
//
//        // Auth header
//        if requiresAuth, let token {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        // Body
//        if let body {
//            request.httpBody = try JSONEncoder().encode(body)
//        }
//
//        // Выполняем запрос
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw APIError.noData
//        }
//
//        switch httpResponse.statusCode {
//        case 200...299:
//            do {
//                let decoder = JSONDecoder()
//                let formatter = DateFormatter()
//                formatter.locale = Locale(identifier: "en_US_POSIX")
//                decoder.dateDecodingStrategy = .custom { decoder in
//                    let container = try decoder.singleValueContainer()
//                    let dateString = try container.decode(String.self)
//                    let formats = [
//                        "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
//                        "yyyy-MM-dd'T'HH:mm:ss",
//                        "yyyy-MM-dd'T'HH:mm:ssZ",
//                        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
//                    ]
//                    for format in formats {
//                        formatter.dateFormat = format
//                        if let date = formatter.date(from: dateString) {
//                            return date
//                        }
//                    }
//                    throw DecodingError.dataCorruptedError(
//                        in: container,
//                        debugDescription: "Cannot decode date: \(dateString)"
//                    )
//                }
//                return try decoder.decode(T.self, from: data)
//            } catch {
//                throw APIError.decodingError(error)
//            }
//        case 401:
//            clearToken()
//            throw APIError.unauthorized
//        case 400...499:
//            // Пробуем прочитать detail из FastAPI ошибки
//            let detail = (try? JSONDecoder().decode(FastAPIError.self, from: data))?.detail ?? "Ошибка запроса"
//            throw APIError.serverError(httpResponse.statusCode, detail)
//        default:
//            throw APIError.serverError(httpResponse.statusCode, "Ошибка сервера")
//        }
//    }
//
//    // Запрос без тела ответа (DELETE и т.п.)
//    func requestVoid(
//        path: String,
//        method: String,
//        body: Encodable? = nil
//    ) async throws {
//        let _: EmptyResponse = try await request(path: path, method: method, body: body)
//    }
//}
//
//// MARK: - Helper types
//
//private struct FastAPIError: Codable {
//    let detail: String
//}
//
//struct EmptyResponse: Codable {}

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String)
    case unauthorized
    case noConnection

    var errorDescription: String? {
        switch self {
        case .unauthorized:       return "Сессия истекла. Войдите снова."
        case .noConnection:       return "Нет подключения к интернету."
        case .serverError(let code, let msg): return "Ошибка \(code): \(msg)"
        case .decodingError(let err): return "Ошибка данных: \(err.localizedDescription)"
        default:                  return "Что-то пошло не так."
        }
    }
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = "http://апишка:8000"

    private var token: String? {
        get { UserDefaults.standard.string(forKey: "auth_token") }
        set { UserDefaults.standard.set(newValue, forKey: "auth_token") }
    }

    func saveToken(_ token: String) { self.token = token }
    func clearToken() { token = nil }
    var isAuthenticated: Bool { token != nil }

    // MARK: - С телом запроса
    func request<T: Decodable, B: Encodable>(
        path: String,
        method: String = "GET",
        body: B,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        try await performRequest(path: path, method: method, body: body, queryItems: queryItems)
    }

    // MARK: - Без тела запроса
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        try await performRequest(path: path, method: method, body: nil as EmptyBody?, queryItems: queryItems)
    }

    // MARK: - Void (DELETE и т.п.)
    func requestVoid(
        path: String,
        method: String = "DELETE",
        queryItems: [URLQueryItem]? = nil
    ) async throws {
        let _: EmptyResponse = try await performRequest(path: path, method: method, body: nil as EmptyBody?, queryItems: queryItems)
    }

    // MARK: - Приватный метод
    private func performRequest<T: Decodable, B: Encodable>(
        path: String,
        method: String,
        body: B?,
        queryItems: [URLQueryItem]?
    ) async throws -> T {
        var components = URLComponents(string: baseURL + path)!
        if let queryItems { components.queryItems = queryItems }
        guard let url = components.url else { throw APIError.invalidURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30

        if let token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.noData }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let str = try container.decode(String.self)
                    for format in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd'T'HH:mm:ss",
                                   "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"] {
                        formatter.dateFormat = format
                        if let date = formatter.date(from: str) { return date }
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(str)")
                }
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            clearToken()
            throw APIError.unauthorized
        case 400...499:
            let detail = (try? JSONDecoder().decode(FastAPIError.self, from: data))?.detail ?? "Ошибка запроса"
            throw APIError.serverError(httpResponse.statusCode, detail)
        default:
            throw APIError.serverError(httpResponse.statusCode, "Ошибка сервера")
        }
    }
}

private struct FastAPIError: Codable { let detail: String }
private struct EmptyBody: Encodable {}
struct EmptyResponse: Codable {}
