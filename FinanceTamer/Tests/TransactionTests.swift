//
//  TransactionTests.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import Foundation
import XCTest
@testable import FinanceTamer

final class TransactionTests: XCTestCase {
    
    private var sampleTransaction: Transaction!
    
    override func setUp() {
        super.setUp()
        
        sampleTransaction = Transaction(
            id: 999,
            accountId: 1,
            categoryId: 2,
            amount: Decimal(string: "123.45")!,
            transactionDate: ISO8601DateFormatter().date(from: "2024-06-01T12:00:00Z")!,
            comment: "Test operation",
            createdAt: ISO8601DateFormatter().date(from: "2024-06-01T12:00:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2024-06-01T12:00:00Z")!
        )
    }
    
    func testTransactionToJsonObject() {
        let json = sampleTransaction.jsonObject as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["id"] as? Int, 999)
        XCTAssertEqual(json?["accountId"] as? Int, 1)
        XCTAssertEqual(json?["categoryId"] as? Int, 2)
        XCTAssertEqual(json?["amount"] as? String, "123.45")
        XCTAssertEqual(json?["comment"] as? String, "Test operation")
        
        let formatter = ISO8601DateFormatter()
        XCTAssertEqual(json?["createdAt"] as? String, formatter.string(from: sampleTransaction.createdAt))
        XCTAssertEqual(json?["updatedAt"] as? String, formatter.string(from: sampleTransaction.updatedAt))
        XCTAssertEqual(json?["transactionDate"] as? String, formatter.string(from: sampleTransaction.transactionDate))
    }
    
    func testTransactionParseFromJsonObject() {
        let json = sampleTransaction.jsonObject
        let parsed = Transaction.parse(jsonObject: json)
        
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.id, sampleTransaction.id)
        XCTAssertEqual(parsed?.accountId, sampleTransaction.accountId)
        XCTAssertEqual(parsed?.categoryId, sampleTransaction.categoryId)
        XCTAssertEqual(parsed?.amount, sampleTransaction.amount)
        XCTAssertEqual(parsed?.comment, sampleTransaction.comment)
        
        let delta: TimeInterval = 1.0
        XCTAssertLessThan(abs(parsed!.transactionDate.timeIntervalSince(sampleTransaction.transactionDate)), delta)
        XCTAssertLessThan(abs(parsed!.createdAt.timeIntervalSince(sampleTransaction.createdAt)), delta)
        XCTAssertLessThan(abs(parsed!.updatedAt.timeIntervalSince(sampleTransaction.updatedAt)), delta)
    }
    
    func testParseInvalidJsonReturnsNil() {
        let invalidJson: [String: Any] = [
            "amount": "???", // incorrectly formatted
            "accountId": "ABC", // it must be an Int
        ]
        let parsed = Transaction.parse(jsonObject: invalidJson)
        XCTAssertNil(parsed)
    }
    
    func testParseIncompleteJsonReturnsNil() {
        let incompleteJson: [String: Any] = [
            "id": 1,
            "accountId": 1,
            // the CategoryID is missing
            "amount": "100.0",
            "transactionDate": "2024-06-01T12:00:00Z",
            "comment": "Payment",
            "createdAt": "2024-06-01T12:00:00Z",
            "updatedAt": "2024-06-01T12:00:00Z"
        ]
        let parsed = Transaction.parse(jsonObject: incompleteJson)
        XCTAssertNil(parsed)
    }
    
    func testParseJsonWithInvalidDateFormatReturnsNil() {
        let jsonWithInvalidDate: [String: Any] = [
            "id": 1,
            "accountId": 1,
            "categoryId": 2,
            "amount": "100.0",
            "transactionDate": "01-06-2024", // incorrect date format
            "comment": "Payment",
            "createdAt": "2024-06-01T12:00:00Z",
            "updatedAt": "2024-06-01T12:00:00Z"
        ]
        let parsed = Transaction.parse(jsonObject: jsonWithInvalidDate)
        XCTAssertNil(parsed)
    }
}
