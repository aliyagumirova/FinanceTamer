//
//  CategoriesService.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

final class CategoriesService {
    
    private let mockCategories: [Category] = [
        Category(id: 1, name: "Salary", emoji: "💰", isIncome: true),
        Category(id: 2, name: "Food", emoji: "🍔", isIncome: false),
        Category(id: 3, name: "Gifts", emoji: "🎁", isIncome: true),
        Category(id: 4, name: "Transport", emoji: "🚌", isIncome: false)
    ]
    
    func categories() async throws -> [Category] {
        return mockCategories
    }
    
    func categories(for direction: Direction) async throws -> [Category] {
        return mockCategories.filter { $0.direction == direction }
    }
}

