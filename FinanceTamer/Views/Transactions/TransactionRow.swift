//
//  TransactionRow.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 19.06.2025.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    @ObservedObject private var currency = CurrencyManager.shared

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
    }

    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(Color("ImageBackgroundColor"))
                .frame(width: 30, height: 30)

            Text(String(transaction.category.emoji))
                .font(.system(size: 14.5))
        }
    }

    private var transactionInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(transaction.category.name)
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
}
