//
//  Transaction.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String
    let createdAt: Date
    var updatedAt: Date
    
    init(id: Int, accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}




