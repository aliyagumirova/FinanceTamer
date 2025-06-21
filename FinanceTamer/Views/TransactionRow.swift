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
            ZStack {
                Circle()
                    .fill(Color("ImageBackgroundColor"))
                    .frame(width: 30, height: 30)

                if let category {
                    Text(String(category.emoji))
                        .font(.system(size: 14.5))
                }
            }

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

            Spacer()

            HStack(spacing: 6) {
                Text("\(transaction.amount.formatted()) ₽")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("ArrowColor"))
                    .opacity(0.3) 
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.white)
        .contentShape(Rectangle())
        .onAppear {
            Task {
                let all = try? await categoriesService.categories()
                category = all?.first(where: { $0.id == transaction.categoryId })
            }
        }
    }
}
