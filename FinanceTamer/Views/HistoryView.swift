//
//  HistoryView.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 19.06.2025.
//

import SwiftUI

struct HistoryView: View {
    let direction: Direction
    
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate:   Date = Date()
    
    @State private var transactions: [Transaction] = []
    @State private var totalAmount:  Decimal       = 0
    
    @State private var showSortOptions = false
    @State private var sortOption: SortOption = .byDate
    
    private let transactionsService = TransactionsService()
    private let categoriesService   = CategoriesService()
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Моя история")
                    .font(.largeTitle).bold()
                    .padding(.horizontal)
                
                List {
                    Section {
                        HStack {
                            Text("Начало")
                            Spacer()
                            DatePicker("", selection: $startDate, displayedComponents: [.date])
                                .labelsHidden()
                                .accentColor(Color("AccentColor"))
                                .onChange(of: startDate) {
                                    if startDate > endDate { endDate = startDate }
                                    Task { await loadTransactions() }
                                }
                        }
                        HStack {
                            Text("Конец")
                            Spacer()
                            DatePicker("", selection: $endDate, in: ...Date(), displayedComponents: [.date])
                                .labelsHidden()
                                .onChange(of: endDate) {
                                    if endDate < startDate { startDate = endDate }
                                    Task { await loadTransactions() }
                                }
                        }
                        HStack {
                            Text("Сумма")
                            Spacer()
                            Text("\(totalAmount.formatted()) ₽")
                        }
                    }
                    .listRowBackground(Color.white)

                    Section(header: Text("ОПЕРАЦИИ")
                                .font(.caption)
                                .foregroundColor(.gray)) {
                        ForEach(transactions.indices, id: \.self) { idx in
                            TransactionRow(transaction: transactions[idx])
                                .listRowBackground(Color.white)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .background(Color("BackgroundColor"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button { showSortOptions = true } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(Color("ClockColor"))
                        }
                        Button(action: {}) {
                            Image(systemName: "doc")
                                .foregroundColor(Color("ClockColor"))
                        }
                    }
                }
            }
        }
        .confirmationDialog("Сортировать по:",
                            isPresented: $showSortOptions,
                            titleVisibility: .visible) {
            ForEach(SortOption.allCases) { option in
                Button(option.rawValue) {
                    sortOption = option
                    applySort()
                }
            }
            Button("Отмена", role: .cancel){ }
        }
        .onAppear { Task { await loadTransactions() } }
    }
    
    private func loadTransactions() async {
        let dayStart = Calendar.current.startOfDay(for: startDate)
        let dayEnd   = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        do {
            let all = try await transactionsService.transactions(accountId: 1,
                                                                 from: dayStart,
                                                                 to: dayEnd)
            let ids = try await categoriesService
                .categories(for: direction)
                .map(\.id)
            
            let filtered = all.filter { ids.contains($0.categoryId) }
            
            DispatchQueue.main.async {
                transactions = filtered
                applySort()
                totalAmount  = filtered.reduce(0) { $0 + $1.amount }
            }
        } catch {
            print("Ошибка: \(error)")
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
