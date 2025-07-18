//
//  BankAccountsService.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

final class BankAccountsService {
    
    private var account: BankAccount = BankAccount(
        id: 1,
        userId: 1,
        name: "Main account",
        balance: "10000.00",
        currency: "₽",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    func accountForUser(userId: Int) async throws -> BankAccount {
        return account
    }
    
    func updateAccount(id: Int, name: String, balance: String, currency: String) async throws -> BankAccount {
        guard id == account.id else {
            throw NSError(
                domain: "BankAccountsService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Account not found"]
            )
        }
        
        account = BankAccount(
            id: id,
            userId: account.userId,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        
        return account
    }
}
