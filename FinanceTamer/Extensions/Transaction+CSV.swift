//
//  Transaction+CSV.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

extension Transaction {
    
    static func fromCSV(_ line: String) -> Transaction? {
        let components = line.components(separatedBy: ",")
        
        guard components.count == 8 else {
            print("❌ Expected 8 fields, received \(components.count)")
            return nil
        }

        let idString = components[0].trimmingCharacters(in: .whitespaces)
        let accountIdString = components[1].trimmingCharacters(in: .whitespaces)
        let categoryIdString = components[2].trimmingCharacters(in: .whitespaces)
        let amountString = components[3].trimmingCharacters(in: .whitespaces)
        let dateString = components[4].trimmingCharacters(in: .whitespaces)
        let comment = components[5].trimmingCharacters(in: .whitespaces)
        let createdAtString = components[6].trimmingCharacters(in: .whitespaces)
        let updatedAtString = components[7].trimmingCharacters(in: .whitespaces)

        guard let id = Int(idString),
              let accountId = Int(accountIdString),
              let categoryId = Int(categoryIdString),
              let amount = Decimal(string: amountString),
              let date = ISO8601DateFormatter().date(from: dateString),
              let createdAt = ISO8601DateFormatter().date(from: createdAtString),
              let updatedAt = ISO8601DateFormatter().date(from: updatedAtString) else {
            return nil
        }

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: date,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var csvLine: String {
        let dateStr = ISO8601DateFormatter().string(from: transactionDate)
        let createdStr = ISO8601DateFormatter().string(from: createdAt)
        let updatedStr = ISO8601DateFormatter().string(from: updatedAt)
        
        return "\(id),\(accountId),\(categoryId),\(amount),\(dateStr),\(comment),\(createdStr),\(updatedStr)"
    }
}
