//
//  TransactionsService.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

final class TransactionsService {
    
    static let shared = TransactionsService()
    
    private var nextId: Int = 5

    // 🔹 Моковые данные счета и категорий
    private let mockAccount = BankAccount(
        id: 1,
        userId: 1,
        name: "Основной счёт",
        balance: "1000.00",
        currency: "RUB",
        createdAt: Date().addingTimeInterval(-86400 * 30),
        updatedAt: Date().addingTimeInterval(-86400 * 5)
    )

    private let mockCategory2 = Category(
        id: 2,
        name: "Продукты",
        emoji: "🛒",
        isIncome: false
    )

    private let mockCategory3 = Category(
        id: 3,
        name: "Подарок",
        emoji: "🎁",
        isIncome: true
    )

    // 🔹 Транзакции создаются в инициализаторе, чтобы избежать обращения к self.*
    private var transactions: [Transaction] = []

    private init() {
        let now = Date()

        transactions = [
            Transaction(
                id: 1,
                account: mockAccount,
                category: mockCategory3,
                amount: 300,
                transactionDate: now.addingTimeInterval(-86400 * 20),
                comment: "Gift from grandma",
                createdAt: now.addingTimeInterval(-86400 * 20),
                updatedAt: now.addingTimeInterval(-86400 * 20)
            ),
            Transaction(
                id: 2,
                account: mockAccount,
                category: mockCategory2,
                amount: 850.50,
                transactionDate: now.addingTimeInterval(-86400 * 10),
                comment: "Groceries at supermarket",
                createdAt: now.addingTimeInterval(-86400 * 10),
                updatedAt: now.addingTimeInterval(-86400 * 10)
            ),
            Transaction(
                id: 3,
                account: mockAccount,
                category: mockCategory2,
                amount: 850.50,
                transactionDate: now,
                comment: "Groceries at supermarket",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 4,
                account: mockAccount,
                category: mockCategory3,
                amount: 49.00,
                transactionDate: now,
                comment: "Bus fare",
                createdAt: now,
                updatedAt: now
            )
        ]
    }

    // MARK: - Получение транзакций по периоду
    func transactions(accountId: Int, from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        let all = transactions.filter {
            $0.account.id == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }

        print("🗂️ Всего операций за период: \(all.count)")
        return all
    }

    // MARK: - Создание
    func create(accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String) async throws -> Transaction {
        let now = Date()

        let category: Category = {
            switch categoryId {
            case mockCategory2.id: return mockCategory2
            case mockCategory3.id: return mockCategory3
            default: return Category(id: categoryId, name: "Неизвестно", emoji: "❓", isIncome: false)
            }
        }()

        let transaction = Transaction(
            id: nextId,
            account: mockAccount,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: now,
            updatedAt: now
        )

        transactions.append(transaction)
        nextId += 1
        return transaction
    }

    // MARK: - Обновление
    func update(_ transaction: Transaction) async throws -> Transaction? {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            let updatedTransaction = Transaction(
                id: transaction.id,
                account: transaction.account,
                category: transaction.category,
                amount: transaction.amount,
                transactionDate: transaction.transactionDate,
                comment: transaction.comment,
                createdAt: transaction.createdAt,
                updatedAt: Date()
            )
            transactions[index] = updatedTransaction
            return updatedTransaction
        }
        return nil
    }

    // MARK: - Удаление
    func delete(id: Int) async throws -> Bool {
        let originalCount = transactions.count
        transactions.removeAll { $0.id == id }
        return transactions.count < originalCount
    }
}
