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
        Category(id: 4, name: "Transport", emoji: "🚌", isIncome: false),
        Category(id: 5, name: "Freelance", emoji: "🧑‍💻", isIncome: true),
        Category(id: 6, name: "Coffee", emoji: "☕️", isIncome: false),
        Category(id: 7, name: "Shopping", emoji: "🛍️", isIncome: false),
        Category(id: 8, name: "Investments", emoji: "📈", isIncome: true),
            
        Category(id: 9, name: "Books", emoji: "📚", isIncome: false),
        Category(id: 10, name: "Entertainment", emoji: "🎮", isIncome: false),
        Category(id: 11, name: "Dividends", emoji: "🏦", isIncome: true),
        Category(id: 12, name: "Rent", emoji: "🏠", isIncome: false),
        
        Category(id: 13, name: "Health", emoji: "💊", isIncome: false),
        Category(id: 14, name: "Bonus", emoji: "🎉", isIncome: true),
        Category(id: 15, name: "Utilities", emoji: "💡", isIncome: false),
        Category(id: 16, name: "Courses", emoji: "🎓", isIncome: false)
    ]
    
    func categories() async throws -> [Category] {
        return mockCategories
    }
    
    func categories(for direction: Direction) async throws -> [Category] {
        return mockCategories.filter { $0.direction == direction }
    }
}

