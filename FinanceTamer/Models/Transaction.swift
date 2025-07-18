//
//  Transaction.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: Int
    let account: BankAccount
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String
    let createdAt: Date
    var updatedAt: Date

    // 👇 Чтобы не ломать старый код с фильтрацией
    var accountId: Int { account.id }
    var categoryId: Int { category.id }
}
