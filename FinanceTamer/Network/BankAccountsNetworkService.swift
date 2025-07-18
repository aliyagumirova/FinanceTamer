//
//  BankAccountsNetworkService.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 18.07.2025.
//

import Foundation

final class BankAccountsNetworkService {
    static let shared = BankAccountsNetworkService()
    private init() {}

    private let client = NetworkClient.shared

    // MARK: - Загрузка всех аккаунтов

    func loadAccounts() async throws -> [BankAccount] {
        try await client.request(method: .get, path: "/accounts")
    }

    // MARK: - Обновление аккаунта (через Result)

    struct UpdateAccountRequest: Encodable {
        let name: String
        let balance: String
        let currency: String
    }

    func updateAccount(
        id: Int,
        name: String,
        balance: String,
        currency: String
    ) async -> Result<BankAccount, Error> {
        let body = UpdateAccountRequest(
            name: name,
            balance: balance,
            currency: currency
        )

        do {
            let updated: BankAccount = try await client.request(
                method: .put,
                path: "/accounts/\(id)",
                body: body
            )
            return .success(updated)
        } catch {
            return .failure(error)
        }
    }
}

