//
//  Transaction+JSON.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

extension Transaction {
    
    var jsonObject: Any {
        return [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": "\(amount)",
            "transactionDate": ISO8601DateFormatter().string(from: transactionDate),
            "comment": comment,
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "updatedAt": ISO8601DateFormatter().string(from: updatedAt)
        ]
    }

    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any] else { return nil }

        guard let id = dict["id"] as? Int,
              let accountId = dict["accountId"] as? Int,
              let categoryId = dict["categoryId"] as? Int,
              let amountString = dict["amount"] as? String,
              let amount = Decimal(string: amountString),
              let dateString = dict["transactionDate"] as? String,
              let transactionDate = ISO8601DateFormatter().date(from: dateString),
              let comment = dict["comment"] as? String,
              let createdAtString = dict["createdAt"] as? String,
              let createdAt = ISO8601DateFormatter().date(from: createdAtString),
              let updatedAtString = dict["updatedAt"] as? String,
              let updatedAt = ISO8601DateFormatter().date(from: updatedAtString) else {
            return nil
        }

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
