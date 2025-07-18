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
            "account": [
                "id": account.id,
                "userId": account.userId,
                "name": account.name,
                "balance": account.balance, // теперь это String
                "currency": account.currency,
                "createdAt": ISO8601DateFormatter().string(from: account.createdAt),
                "updatedAt": ISO8601DateFormatter().string(from: account.updatedAt)
            ],
            "category": [
                "id": category.id,
                "name": category.name,
                "emoji": String(category.emoji),
                "isIncome": category.isIncome
            ],
            "amount": "\(amount)",
            "transactionDate": ISO8601DateFormatter().string(from: transactionDate),
            "comment": comment,
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "updatedAt": ISO8601DateFormatter().string(from: updatedAt)
        ]
    }
    
    // Универсальный парсер ISO8601 даты с или без дробных секунд
    private static func parseISO8601Date(_ string: String) -> Date? {
        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFractional.date(from: string) {
            return date
        }
        let formatterWithoutFractional = ISO8601DateFormatter()
        formatterWithoutFractional.formatOptions = [.withInternetDateTime]
        return formatterWithoutFractional.date(from: string)
    }
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any] else {
            print("❌ Не словарь JSON:", jsonObject)
            return nil
        }

        guard let id = dict["id"] as? Int else {
            print("❌ Нет id в", dict)
            return nil
        }

        guard let amountStr = dict["amount"] as? String, let amount = Decimal(string: amountStr) else {
            print("❌ Проблема с amount:", dict["amount"] ?? "nil")
            return nil
        }

        guard let dateStr = dict["transactionDate"] as? String,
              let transactionDate = parseISO8601Date(dateStr) else {
            print("❌ Проблема с transactionDate:", dict["transactionDate"] ?? "nil")
            return nil
        }

        guard let accountDict = dict["account"] as? [String: Any] else {
            print("❌ Нет account в", dict)
            return nil
        }

        guard let accountId = accountDict["id"] as? Int else {
            print("❌ Нет account.id в", accountDict)
            return nil
        }

        guard let name = accountDict["name"] as? String else {
            print("❌ Нет account.name в", accountDict)
            return nil
        }

        guard let balanceStr = accountDict["balance"] as? String else {
            print("❌ Нет account.balance в", accountDict)
            return nil
        }

        guard let currency = accountDict["currency"] as? String else {
            print("❌ Нет account.currency в", accountDict)
            return nil
        }

        guard let categoryDict = dict["category"] as? [String: Any] else {
            print("❌ Нет category в", dict)
            return nil
        }

        guard let categoryId = categoryDict["id"] as? Int else {
            print("❌ Нет category.id в", categoryDict)
            return nil
        }

        guard let categoryName = categoryDict["name"] as? String else {
            print("❌ Нет category.name в", categoryDict)
            return nil
        }

        guard let emojiStr = categoryDict["emoji"] as? String,
              let emoji = emojiStr.first else {
            print("❌ Проблема с category.emoji:", categoryDict["emoji"] ?? "nil")
            return nil
        }

        // isIncome: может быть Int или Bool
        var isIncome: Bool = false
        if let isIncomeBool = categoryDict["isIncome"] as? Bool {
            isIncome = isIncomeBool
        } else if let isIncomeInt = categoryDict["isIncome"] as? Int {
            isIncome = (isIncomeInt != 0)
        } else {
            print("❌ Ошибка с category.isIncome:", categoryDict["isIncome"] ?? "nil")
            return nil
        }

        let userId = accountDict["userId"] as? Int ?? 0
        let accCreatedAt = (accountDict["createdAt"] as? String).flatMap { parseISO8601Date($0) } ?? Date()
        let accUpdatedAt = (accountDict["updatedAt"] as? String).flatMap { parseISO8601Date($0) } ?? Date()

        // comment: может быть строкой или null или "<null>"
        let rawComment = dict["comment"]
        var comment = ""
        if let commentStr = rawComment as? String, commentStr.lowercased() != "<null>" {
            comment = commentStr
        }

        let createdAt = (dict["createdAt"] as? String).flatMap { parseISO8601Date($0) } ?? transactionDate
        let updatedAt = (dict["updatedAt"] as? String).flatMap { parseISO8601Date($0) } ?? transactionDate

        let account = BankAccount(
            id: accountId,
            userId: userId,
            name: name,
            balance: balanceStr,
            currency: currency,
            createdAt: accCreatedAt,
            updatedAt: accUpdatedAt
        )

        let category = Category(
            id: categoryId,
            name: categoryName,
            emoji: emoji,
            isIncome: isIncome
        )

        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
