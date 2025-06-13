//
//  TransactionsFileCache.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation

final class TransactionsFileCache {
    
    private(set) var transactions: [Transaction] = []
    
    func add(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }
    
    func remove(id: Int) {
        transactions.removeAll { $0.id == id }
    }
    
    func save(to fileName: String) throws {
        let jsonArray = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
        let url = try fileURL(for: fileName)
        try data.write(to: url, options: [.atomic])
    }
    
    func load(from fileName: String) throws {
        let url = try fileURL(for: fileName)
        let data = try Data(contentsOf: url)
        let rawJson = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let array = rawJson as? [Any] else {
            print("❌ JSON is not array")
            return
        }
        
        var loadedTransactions: [Transaction] = []
        for jsonObject in array {
            if let transaction = Transaction.parse(jsonObject: jsonObject) {
                if !loadedTransactions.contains(where: { $0.id == transaction.id }) {
                    loadedTransactions.append(transaction)
                }
            }
        }
        
        transactions = loadedTransactions
    }
    
    private func fileURL(for fileName: String) throws -> URL {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Couldn't find Documents folder"])
        }
        return directory.appendingPathComponent("\(fileName).json")
    }
}

