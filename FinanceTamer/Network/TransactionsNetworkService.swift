//
//  TransactionsNetworkService.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 17.07.2025.
//

import Foundation

final class TransactionsNetworkService {
    static let shared = TransactionsNetworkService()
    private init() {}

    private let client = NetworkClient.shared

    // MARK: - Получение транзакций
    func loadTransactions(accountId: Int, from: Date, to: Date, isIncome: Bool) async throws -> [Transaction] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let startStr = formatter.string(from: from)
        let endStr = formatter.string(from: to)
        let isIncomeParam = isIncome ? "true" : "false"

        let path = "/transactions/account/\(accountId)/period?startDate=\(startStr)&endDate=\(endStr)&isIncome=\(isIncomeParam)"

        let raw = try await client.requestRawJSON(method: .get, path: path)

        guard let array = raw as? [Any] else {
            throw NSError(domain: "TransactionsNetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ожидался массив транзакций"])
        }

        return array.compactMap { Transaction.parse(jsonObject: $0) }
    }

    // MARK: - Создание транзакции
    struct CreateTransactionRequest: Encodable {
        let accountId: Int
        let categoryId: Int
        let amount: String
        let transactionDate: String
        let comment: String
    }

    func create(
        accountId: Int,
        categoryId: Int,
        amount: Decimal,
        transactionDate: Date,
        comment: String
    ) async -> Result<Transaction, Error> {
        let isoDate = ISO8601DateFormatter().string(from: transactionDate)
        let requestBody = CreateTransactionRequest(
            accountId: accountId,
            categoryId: categoryId,
            amount: "\(amount)",
            transactionDate: isoDate,
            comment: comment
        )

        do {
            let transaction: Transaction = try await client.request(
                method: .post,
                path: "/transactions",
                body: requestBody
            )
            return .success(transaction)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Обновление транзакции
    struct UpdateTransactionRequest: Encodable {
        let accountId: Int
        let categoryId: Int
        let amount: String
        let transactionDate: String
        let comment: String
    }

    func update(_ transaction: Transaction) async -> Result<Transaction, Error> {
        let isoDate = ISO8601DateFormatter().string(from: transaction.transactionDate)

        let requestBody = UpdateTransactionRequest(
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: "\(transaction.amount)",
            transactionDate: isoDate,
            comment: transaction.comment
        )

        do {
            let updated: Transaction = try await client.request(
                method: .put,
                path: "/transactions/\(transaction.id)",
                body: requestBody
            )
            return .success(updated)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Удаление транзакции
    func delete(id: Int) async throws {
        _ = try await client.request(
            method: .delete,
            path: "/transactions/\(id)",
            body: EmptyBody()
        ) as EmptyResponse
    }

    // MARK: - Вспомогательная функция
    func utcStartAndEndOfDay(for date: Date = Date()) -> (start: Date, end: Date) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!

        return (startOfDay, endOfDay)
    }
}
