//
//  TransactionRow.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 19.06.2025.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    @State private var category: Category?
    @ObservedObject private var currency = CurrencyManager.shared
    private let categoriesService = CategoriesService()
    
    var body: some View {
        HStack(spacing: 12) {
            categoryIcon
            transactionInfo
            Spacer()
            amountBlock
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.white)
        .contentShape(Rectangle())
        .onAppear {
            loadCategory()
        }
    }
    
    // MARK: - Subviews
    
    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(Color("ImageBackgroundColor"))
                .frame(width: 30, height: 30)
            
            if let category {
                Text(String(category.emoji))
                    .font(.system(size: 14.5))
            }
        }
    }
    
    private var transactionInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(category?.name ?? "—")
                .font(.system(size: 17))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            if !transaction.comment.isEmpty {
                Text(transaction.comment)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
    
    private var amountBlock: some View {
        HStack(spacing: 6) {
            Text("\(transaction.amount.formatted()) \(currency.selectedCurrency)")
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color("ArrowColor"))
                .opacity(0.3)
        }
    }
    
    // MARK: - Logic
    
    private func loadCategory() {
        Task {
            let all = try? await categoriesService.categories()
            category = all?.first(where: { $0.id == transaction.categoryId })
        }
    }
}
