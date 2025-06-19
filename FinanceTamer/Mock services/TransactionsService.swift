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
            id: 1,
            accountId: 1,
            categoryId: 2,
            amount: 299.99,
            transactionDate: Date().addingTimeInterval(-3600),
            comment: "Dinner in cafe",
            createdAt: Date().addingTimeInterval(-3600),
            updatedAt: Date().addingTimeInterval(-3600)
        ),
        Transaction(
            id: 2,
            accountId: 1,
            categoryId: 1,
            amount: 5000,
            transactionDate: Date().addingTimeInterval(-86400 * 2),
            comment: "Salary",
            createdAt: Date().addingTimeInterval(-86400 * 2),
            updatedAt: Date().addingTimeInterval(-86400 * 2)
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

