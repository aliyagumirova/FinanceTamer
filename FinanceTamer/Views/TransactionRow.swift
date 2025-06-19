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
    private let categoriesService = CategoriesService()

    var body: some View {
        HStack(spacing: 12) {
            if let category = category {
                ZStack {
                    Circle()
                        .fill(Color("ImageBackgroundColor"))
                        .frame(width: 22, height: 22)

                    Text(String(category.emoji))
                        .font(.system(size: 12))
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.body)

                    if !transaction.comment.isEmpty {
                        Text(transaction.comment)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.gray)
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Text(transaction.comment)
                        .font(.body)
                }
            }

            Spacer()

            HStack(spacing: 14) {
                Text("\(transaction.amount.formatted()) ₽")

                Image(systemName: "chevron.right")
                    .foregroundColor(Color("ArrowColor"))
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .onAppear {
            Task {
                let all = try? await categoriesService.categories()
                category = all?.first(where: { $0.id == transaction.categoryId })
            }
        }
    }
}
