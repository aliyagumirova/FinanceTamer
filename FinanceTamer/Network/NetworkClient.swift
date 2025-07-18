//
//  NetworkClient.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 17.07.2025.
//

import Foundation

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError
    case encodingError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL"
        case .invalidResponse: return "Неверный ответ от сервера"
        case .statusCode(let code): return "Ошибка сервера: \(code)"
        case .decodingError: return "Ошибка чтения данных"
        case .encodingError: return "Ошибка подготовки данных"
        case .serverError(let message): return message
        }
    }
}

// MARK: - Вспомогательные типы

struct EmptyBody: Encodable {}
struct EmptyResponse: Decodable {}

// MARK: - Network Client

final class NetworkClient {
    static let shared = NetworkClient()
    private init() {}

    private let baseURL = "https://shmr-finance.ru/api/v1"
    private let token = "FAzzHbfMNfji7WRKoPgCU3Ph"

    private func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            if let date = formatter.date(from: dateStr) {
                return date
            }
            let fallbackFormatter = ISO8601DateFormatter()
            fallbackFormatter.formatOptions = [.withInternetDateTime]
            if let date = fallbackFormatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
        }
        return decoder
    }

    func request<ResponseBody: Decodable>(
        method: HTTPMethod,
        path: String
    ) async throws -> ResponseBody {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        if ResponseBody.self == EmptyResponse.self {
            return EmptyResponse() as! ResponseBody
        }

        let decoder = makeJSONDecoder()
        return try decoder.decode(ResponseBody.self, from: data)
    }

    func requestRawJSON(method: HTTPMethod, path: String) async throws -> Any {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        return try JSONSerialization.jsonObject(with: data, options: [])
    }

    func request<RequestBody: Encodable, ResponseBody: Decodable>(
        method: HTTPMethod,
        path: String,
        body: RequestBody
    ) async throws -> ResponseBody {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw NetworkError.encodingError
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        if ResponseBody.self == EmptyResponse.self {
            return EmptyResponse() as! ResponseBody
        }

        let decoder = makeJSONDecoder()
        return try decoder.decode(ResponseBody.self, from: data)
    }
}
