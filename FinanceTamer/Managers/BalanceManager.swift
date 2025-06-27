//
//  BalanceManager.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 28.06.2025.
//

import Foundation

final class BalanceManager: ObservableObject {
    static let shared = BalanceManager()
    
    private let key = "accountBalance"
    
    @Published var balance: Decimal {
        didSet {
            UserDefaults.standard.set(balance.description, forKey: key)
        }
    }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: key) ?? "0"
        self.balance = Decimal(string: saved) ?? 0
    }
}

