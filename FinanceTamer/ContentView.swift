//
//  ContentView.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 08.06.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Testing")
                .font(.title)
                .padding()
            Spacer()
        }
        .onAppear {
            Task {
                await testAllMockServices()
            }
        }
    }

    func testAllMockServices() async {
        print("---- 🧪 Testing of services has begun ----")

        // 1. CategoriesService
        let categoryService = CategoriesService()
        let allCategories = try? await categoryService.categories()
        print("📁 All categories: \(allCategories?.map { $0.name } ?? [])")

        let incomeCategories = try? await categoryService.categories(for: .income)
        print("💸 Income categories: \(incomeCategories?.map { $0.name } ?? [])")

        // 2. BankAccountsService
        let bankService = BankAccountsService()
        guard let bankAccount = try? await bankService.accountForUser(userId: 1) else {
            print("❌ Couldn't get a bank account")
            return
        }
        print("🏦 Current bank account: \(bankAccount.name), balance: \(bankAccount.balance) \(bankAccount.currency)")

        let updatedAccount = try? await bankService.updateAccount(
            id: bankAccount.id,
            name: "New account",
            balance: 15_000,
            currency: "USD"
        )
        print("✅ Updated account: \(updatedAccount?.name ?? "-"), balance: \(updatedAccount?.balance ?? 0) \(updatedAccount?.currency ?? "")")

        // 3. TransactionsService
        let transactionService = TransactionsService()

        // Creating a transaction
        let newTransaction = try? await transactionService.create(
            accountId: bankAccount.id,
            categoryId: 1,
            amount: 1200,
            transactionDate: Date(),
            comment: "Purchase of equipment"
        )
        print("➕ A transaction has been created: \(newTransaction?.comment ?? "") for the amount of \(newTransaction?.amount ?? 0)")

        // Updating the transaction
        if var toUpdate = newTransaction {
            toUpdate = Transaction(
                id: toUpdate.id,
                accountId: toUpdate.accountId,
                categoryId: toUpdate.categoryId,
                amount: 1400,
                transactionDate: toUpdate.transactionDate,
                comment: "Purchase of equipment (specified)",
                createdAt: toUpdate.createdAt,
                updatedAt: Date()
            )
            if let updated = try? await transactionService.update(toUpdate) {
                print("✏️ The transaction has been updated: \(updated.comment) for the amount of \(updated.amount)")
            }
        }

        // Deleting a transaction
        if let toDeleteId = newTransaction?.id {
            let deleted = try? await transactionService.delete(id: toDeleteId)
            print(deleted == true ? "🗑️ Transaction deleted (id: \(toDeleteId))" : "❌ Couldn't delete transaction")
        }

        // Filtering by date
        let fromDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let toDate = Date()
        let recentTransactions = try? await transactionService.transactions(
            accountId: bankAccount.id,
            from: fromDate,
            to: toDate
        )
        print("🕒 Transactions in the last 3 days: \(recentTransactions?.count ?? 0) pc.")

        // 4. JSON & CSV serialization
        let testTransaction = Transaction(
            id: 99,
            accountId: bankAccount.id,
            categoryId: 1,
            amount: 100.50,
            transactionDate: Date(),
            comment: "Test JSON",
            createdAt: Date(),
            updatedAt: Date()
        )

        let jsonObject = testTransaction.jsonObject
        print("🧾 JSON object: \(jsonObject)")

        if let parsed = Transaction.parse(jsonObject: jsonObject) {
            print("✅ Successful JSON parsing: \(parsed.comment)")
        } else {
            print("❌ JSON parsing error")
        }

        let csvLine = testTransaction.csvLine
        print("📄 CSV string: \(csvLine)")

        if let parsedCSV = Transaction.fromCSV(csvLine) {
            print("✅ Successful CSV parsing: \(parsedCSV.comment)")
        } else {
            print("❌ CSV parsing error")
        }

        // 5. FileCache
        let cache = TransactionsFileCache()
        cache.add(testTransaction)

        do {
            try cache.save(to: "transactions_test")
            print("💾 The file is saved")
            let newCache = TransactionsFileCache()
            try newCache.load(from: "transactions_test")
            print("📂 Downloaded from the transaction file: \(newCache.transactions.count)")
        } catch {
            print("❌ Error when working with the file: \(error.localizedDescription)")
        }

        print("---- ✅ Testing of services is completed ----")
    }
}

#Preview {
    ContentView()
}
