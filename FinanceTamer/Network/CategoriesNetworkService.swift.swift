//
//  CategoriesNetworkService.swift.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 17.07.2025.
//

import Foundation

final class CategoriesNetworkService {
    static let shared = CategoriesNetworkService()
    private init() {}

    private let client = NetworkClient.shared

    // Получение списка всех категорий
    func categories() async throws -> [Category] {
        let path = "/categories"
        return try await client.request(method: .get, path: path)
    }
}
