//
//  BankAccount.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

struct BankAccount: Identifiable, Codable, Equatable {
    let id: Int
    let userId: Int
    var name: String
    var balance: String
    var currency: String
    let createdAt: Date
    var updatedAt: Date
    
    init(id: Int, userId: Int, name: String, balance: String, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
