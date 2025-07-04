//
//  CategoriesView.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 03.07.2025.
//

import SwiftUI

struct CategoriesView: View {
    @State private var allCategories: [Category] = []
    @State private var searchText: String = ""
    
    private let categoriesService = CategoriesService()
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return allCategories
        } else {
            return allCategories.filter { category in
                let name = category.name.lowercased()
                let query = searchText.lowercased()
                
                if name.hasPrefix(query) {
                    return true // Начинается с ввода → показываем сразу
                }
                
                // иначе проверяем расстояние Левенштейна
                let distance = name.levenshteinDistance(to: query)
                let maxAllowedDistance = max(1, name.count / 3)
                return distance <= maxAllowedDistance
            }
        }
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                
                List {
                    Section(header: Text("СТАТЬИ").font(.caption).foregroundColor(.gray)) {
                        ForEach(filteredCategories) { category in
                            CategoryRow(category: category)
                                .listRowBackground(Color.white)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Мои статьи")
            .navigationBarTitleDisplayMode(.large)
        }
        .searchable(text: $searchText, prompt: "Поиск")
        .task {
            await loadCategories()
        }
    }
    
    // MARK: - Загрузка
    @MainActor
    private func loadCategories() async {
        do {
            let result = try await categoriesService.categories()
            allCategories = result
        } catch {
            print("Ошибка загрузки категорий: \(error)")
        }
    }
}

#Preview {
    CategoriesView()
}

extension String {
    func levenshteinDistance(to target: String) -> Int {
        let source = Array(self.lowercased())
        let target = Array(target.lowercased())
        
        let (m, n) = (source.count, target.count)
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m { dp[i][0] = i }
        for j in 0...n { dp[0][j] = j }
        
        for i in 1...m {
            for j in 1...n {
                if source[i - 1] == target[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] =  Swift.min(
                        dp[i - 1][j] + 1,    // удаление
                        dp[i][j - 1] + 1,    // вставка
                        dp[i - 1][j - 1] + 1 // замена
                    )
                }
            }
        }
        
        return dp[m][n]
    }
}
