//
//  TransactionsService.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

final class TransactionsService {
    
    private var nextId: Int = 3
    
    private var transactions: [Transaction] = [
        Transaction(
            id: 3,
            accountId: 1,
            categoryId: 1,
            amount: 120_000,
            transactionDate: Date().addingTimeInterval(-86400 * 30), // 30 дней назад → 18 мая 2025
            comment: "Salary for May",
            createdAt: Date().addingTimeInterval(-86400 * 30),        // 18 мая 2025
            updatedAt: Date().addingTimeInterval(-86400 * 30)
        ),

        Transaction(
            id: 4,
            accountId: 1,
            categoryId: 3,
            amount: 300,
            transactionDate: Date().addingTimeInterval(-86400 * 20), // 28 мая 2025
            comment: "Gift from grandma",
            createdAt: Date().addingTimeInterval(-86400 * 20),        // 28 мая 2025
            updatedAt: Date().addingTimeInterval(-86400 * 20)
        ),

        Transaction(
            id: 5,
            accountId: 1,
            categoryId: 2,
            amount: 850.50,
            transactionDate: Date().addingTimeInterval(-86400 * 10), // 7 июня 2025
            comment: "Groceries at supermarket",
            createdAt: Date().addingTimeInterval(-86400 * 10),        // 7 июня 2025
            updatedAt: Date().addingTimeInterval(-86400 * 10)
        ),

        Transaction(
            id: 6,
            accountId: 1,
            categoryId: 4,
            amount: 49.00,
            transactionDate: Date().addingTimeInterval(-86400 * 5), // 12 июня 2025
            comment: "Bus fare",
            createdAt: Date().addingTimeInterval(-86400 * 5),        // 12 июня 2025
            updatedAt: Date().addingTimeInterval(-86400 * 5)
        ),

        Transaction(
            id: 7,
            accountId: 1,
            categoryId: 2,
            amount: 2_399.99,
            transactionDate: Date().addingTimeInterval(-86400 * 3), // 14 июня 2025
            comment: "Dinner with friends",
            createdAt: Date().addingTimeInterval(-86400 * 3),        // 14 июня 2025
            updatedAt: Date().addingTimeInterval(-86400 * 3)
        ),

        Transaction(
            id: 8,
            accountId: 1,
            categoryId: 4,
            amount: 1_500.00,
            transactionDate: Date().addingTimeInterval(-86400 * 7), // 10 июня 2025
            comment: "Taxi from airport",
            createdAt: Date().addingTimeInterval(-86400 * 7),        // 10 июня 2025
            updatedAt: Date().addingTimeInterval(-86400 * 7)
        ),

        Transaction(
            id: 9,
            accountId: 1,
            categoryId: 1,
            amount: 115_000,
            transactionDate: Date().addingTimeInterval(-86400 * 60), // 18 апреля 2025
            comment: "April salary",
            createdAt: Date().addingTimeInterval(-86400 * 60),        // 18 апреля 2025
            updatedAt: Date().addingTimeInterval(-86400 * 60)
        ),

        Transaction(
            id: 10,
            accountId: 1,
            categoryId: 3,
            amount: 2_000,
            transactionDate: Date().addingTimeInterval(-86400 * 2), // 15 июня 2025
            comment: "Birthday envelope",
            createdAt: Date().addingTimeInterval(-86400 * 2),        // 15 июня 2025
            updatedAt: Date().addingTimeInterval(-86400 * 2)
        ),

        Transaction(
            id: 11,
            accountId: 1,
            categoryId: 2,
            amount: 399.90,
            transactionDate: Date().addingTimeInterval(-86400), // 16 июня 2025
            comment: "Lunch at bistro",
            createdAt: Date().addingTimeInterval(-86400),        // 16 июня 2025
            updatedAt: Date().addingTimeInterval(-86400)
        ),

        Transaction(
            id: 12,
            accountId: 1,
            categoryId: 4,
            amount: 3_200.0,
            transactionDate: Date(), // 17 июня 2025
            comment: "Очень длинный комментарий",
            createdAt: Date(),       // 17 июня 2025
            updatedAt: Date()
        ),
        
        
        Transaction(
            id: 13,
            accountId: 1,
            categoryId: 3,
            amount: 300,
            transactionDate: Date(), // 28 мая 2025
            comment: "Gift from husband",
            createdAt: Date(),        // 28 мая 2025
            updatedAt: Date()
        ),
        
        Transaction(
            id: 13,
            accountId: 1,
            categoryId: 2,                       // Food 🍔
            amount: 549.90,
            transactionDate: Date(),             // сегодня
            comment: "Groceries at local market",
            createdAt: Date(),                   // сегодня
            updatedAt: Date()
        ),

        Transaction(
            id: 14,
            accountId: 1,
            categoryId: 4,                       // Transport 🚌
            amount: 120.00,
            transactionDate: Date(),             // сегодня
            comment: "Metro rides",
            createdAt: Date(),
            updatedAt: Date()
        ),

        Transaction(
            id: 15,
            accountId: 1,
            categoryId: 1,                       // Salary 💰
            amount: 80_000,
            transactionDate: Date(),             // сегодня
            comment: "Part-time project payment",
            createdAt: Date(),
            updatedAt: Date()
        ),

        Transaction(
            id: 16,
            accountId: 1,
            categoryId: 3,                       // Gifts 🎁
            amount: 2_500,
            transactionDate: Date(),             // сегодня
            comment: "Gift card for friend",
            createdAt: Date(),
            updatedAt: Date()
        )
        
    ]
    
    func transactions(accountId: Int, from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        return transactions.filter {
            $0.accountId == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
    }

    
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
        nextId += 1
        return transaction
    }

    
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
            return updatedTransaction
        }
        return nil
    }

    
    func delete(id: Int) async throws -> Bool {
        let originalCount = transactions.count
        transactions.removeAll { $0.id == id }
        return transactions.count < originalCount
    }

}

