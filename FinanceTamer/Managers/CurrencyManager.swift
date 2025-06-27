//
//  CurrencyManager.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 25.06.2025.
//

import Foundation

final class CurrencyManager: ObservableObject {
    static let shared = CurrencyManager()
    
    private let key = "selectedCurrency"
    
    @Published var selectedCurrency: String {
        didSet {
            UserDefaults.standard.set(selectedCurrency, forKey: key)
        }
    }
    
    private init() {
        self.selectedCurrency = UserDefaults.standard.string(forKey: key) ?? "₽"
    }
}


