//
//  TransactionsService.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

final class TransactionsService {
    
    static let shared = TransactionsService() // ✅ Синглтон
    
    private init() {} // запрет на создание извне
    
    private var nextId: Int = 5
    
    private var transactions: [Transaction] = [
        Transaction(
            id: 1,
            accountId: 1,
            categoryId: 3,
            amount: 300,
            transactionDate: Date().addingTimeInterval(-86400 * 20),
            comment: "Gift from grandma",
            createdAt: Date().addingTimeInterval(-86400 * 20),
            updatedAt: Date().addingTimeInterval(-86400 * 20)
        ),
        Transaction(
            id: 2,
            accountId: 1,
            categoryId: 2,
            amount: 850.50,
            transactionDate: Date().addingTimeInterval(-86400 * 10),
            comment: "Groceries at supermarket",
            createdAt: Date().addingTimeInterval(-86400 * 10),
            updatedAt: Date().addingTimeInterval(-86400 * 10)
        ),
        
        Transaction(
            id: 3,
            accountId: 1,
            categoryId: 2,
            amount: 850.50,
            transactionDate: Date(),
            comment: "Groceries at supermarket",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 4,
            accountId: 1,
            categoryId: 3,
            amount: 49.00,
            transactionDate: Date(),
            comment: "Bus fare",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    // MARK: - Получение транзакций по периоду
    func transactions(accountId: Int, from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        let all = transactions.filter {
            $0.accountId == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
        
        print("🗂️ Всего операций за сегодня: \(transactions.count)")
        for t in transactions {
            print("• \(t.id) | \(t.amount) | \(t.transactionDate) | catId: \(t.categoryId)")
        }
        return all
    }
    
    // MARK: - Создание
    func create(accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String) async throws -> Transaction {
        let now = Date()
        let transaction = Transaction(
            id: nextId,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: now,
            updatedAt: now
        )
        transactions.append(transaction)
        print("✅ [TransactionsService] Транзакция создана: id \(transaction.id)")
        nextId += 1
        return transaction
    }
    
    // MARK: - Обновление
    func update(_ transaction: Transaction) async throws -> Transaction? {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            let updatedTransaction = Transaction(
                id: transaction.id,
                accountId: transaction.accountId,
                categoryId: transaction.categoryId,
                amount: transaction.amount,
                transactionDate: transaction.transactionDate,
                comment: transaction.comment,
                createdAt: transactions[index].createdAt,
                updatedAt: Date()
            )
            transactions[index] = updatedTransaction
            print("✏️ [TransactionsService] Транзакция обновлена: id \(transaction.id)")
            return updatedTransaction
        } else {
            print("⚠️ [TransactionsService] Не найдено для обновления: id \(transaction.id)")
            return nil
        }
    }
    
    // MARK: - Удаление
    func delete(id: Int) async throws -> Bool {
        let originalCount = transactions.count
        transactions.removeAll { $0.id == id }
        let deleted = transactions.count < originalCount
        print(deleted ? "🗑️ Удалена транзакция id: \(id)" : "⚠️ Не найдена для удаления: id \(id)")
        return deleted
    }
}
