//
//  TransactionsListView.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 19.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    
    @State private var transactions: [Transaction] = []
    @State private var totalAmount: Decimal = 0
    @State private var currency = CurrencyManager.shared
    
    @State private var showSortOptions = false
    @State private var sortOption: SortOption = .byDate
    
    private let transactionsService = TransactionsService()
    private let categoriesService = CategoriesService()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                
                VStack {
                    transactionsListSection
                }
                .navigationTitle(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        toolbarButtons
                    }
                }
                
                floatingAddButton
            }
        }
        .confirmationDialog("Сортировать по:", isPresented: $showSortOptions, titleVisibility: .visible) {
            ForEach(SortOption.allCases) { option in
                Button(option.rawValue) {
                    sortOption = option
                    applySort()
                }
            }
            Button("Отмена", role: .cancel) {}
        }
        .task {
            await loadTransactions()
        }
    }
    
    // MARK: - Subviews
    
    private var transactionsListSection: some View {
        List {
            Section {
                HStack {
                    Text("Всего")
                    Spacer()
                    Text("\(totalAmount.formatted()) \(currency.selectedCurrency)")
                        .foregroundColor(Color("ArrowColor"))
                }
            }
            .listRowBackground(Color.white)
            
            Section(header: Text("ОПЕРАЦИИ").font(.caption).foregroundColor(.gray)) {
                ForEach(transactions, id: \.id) { transaction in
                    TransactionRow(transaction: transaction)
                        .listRowBackground(Color.white)
                        .listRowInsets(EdgeInsets())
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
    
    private var toolbarButtons: some View {
        HStack(spacing: 16) {
            Button(action: { showSortOptions = true }) {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(Color("ClockColor"))
            }
            NavigationLink(destination: HistoryView(direction: direction)) {
                Image(systemName: "clock")
                    .foregroundColor(Color("ClockColor"))
            }
        }
    }
    
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    // TODO: handle action
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("AccentColor"))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: - Logic
    
    private func loadTransactions() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        
        do {
            let all = try await transactionsService.transactions(accountId: 1, from: startOfDay, to: endOfDay)
            let filteredCategories = try await categoriesService.categories(for: direction)
            let categoryIds = Set(filteredCategories.map { $0.id })
            
            let filtered = all.filter { categoryIds.contains($0.categoryId) }
            
            DispatchQueue.main.async {
                transactions = filtered
                totalAmount = transactions.reduce(0) { $0 + $1.amount }
                applySort()
            }
        } catch {
            print("Ошибка загрузки: \(error)")
        }
    }
    
    private func applySort() {
        switch sortOption {
        case .byDate:
            transactions.sort { $0.transactionDate > $1.transactionDate }
        case .byAmount:
            transactions.sort { $0.amount > $1.amount }
        }
    }
}
