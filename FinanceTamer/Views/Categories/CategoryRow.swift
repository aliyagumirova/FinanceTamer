//
//  CategoryRow.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 03.07.2025.
//

import Foundation
import SwiftUI

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            categoryIcon
            Text(category.name)
                .font(.system(size: 17))
                .foregroundColor(.primary)
            Spacer()
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
            
            Text(String(category.emoji))
                .font(.system(size: 14.5))
        }
    }
}
