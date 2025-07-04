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
    @State private var endDate: Date = Date()
    
    @State private var rawTransactions: [Transaction] = []
    @State private var transactions: [Transaction] = []
    @State private var totalAmount: Decimal = 0
    @ObservedObject private var currency = CurrencyManager.shared
    
    @State private var showSortOptions = false
    @State private var sortOption: SortOption = .byDate
    
    @Environment(\.dismiss) private var dismiss
    
    private let transactionsService = TransactionsService()
    private let categoriesService = CategoriesService()
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack {
                List {
                    dateAndSummarySection
                    transactionListSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Моя история")
            .background(Color("BackgroundColor"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { backButton }
                ToolbarItem(placement: .navigationBarTrailing) { topActions }
            }
            .navigationBarBackButtonHidden(true)
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
        .onAppear {
            Task { await loadTransactions() }
        }
    }
    
    // MARK: - Subviews
    
    private var dateAndSummarySection: some View {
        Section {
            datePickerRow(title: "Начало", selection: $startDate, isStart: true)
            datePickerRow(title: "Конец", selection: $endDate, isStart: false)
            
            HStack {
                Text("Сумма")
                Spacer()
                Text("\(totalAmount.formatted()) \(currency.selectedCurrency)")
            }
        }
        .listRowBackground(Color.white)
    }
    
    private var transactionListSection: some View {
        Section(header: Text("ОПЕРАЦИИ").font(.caption).foregroundColor(.gray)) {
            ForEach(transactions, id: \.id) { transaction in
                TransactionRow(transaction: transaction)
                    .listRowBackground(Color.white)
                    .listRowInsets(EdgeInsets())
            }
        }
    }
    
    private func datePickerRow(title: String, selection: Binding<Date>, isStart: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            DatePicker(
                "",
                selection: selection,
                in: isStart ? Date.distantPast...endDate : startDate...Date(),
                displayedComponents: [.date]
            )
            .labelsHidden()
            .accentColor(Color("AccentColor"))
            .background(Color.accentColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .environment(\.locale, Locale(identifier: "ru_RU"))
            .onChange(of: selection.wrappedValue) {
                if isStart && selection.wrappedValue > endDate {
                    endDate = selection.wrappedValue
                } else if !isStart && selection.wrappedValue < startDate {
                    startDate = selection.wrappedValue
                }
                Task { await loadTransactions() }
            }
        }
    }
    
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                Text("Назад")
            }
            .foregroundColor(Color("ClockColor"))
        }
    }
    
    private var topActions: some View {
        HStack {
            Button { showSortOptions = true } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(Color("ClockColor"))
            }
            Button(action: {
                // TODO: Export
            }) {
                Image(systemName: "doc")
                    .foregroundColor(Color("ClockColor"))
            }
        }
    }
    
    // MARK: - Logic
    
    @MainActor
    private func loadTransactions() async {
        let dayStart = Calendar.current.startOfDay(for: startDate)
        let dayEnd = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        do {
            let all = try await transactionsService.transactions(accountId: 1, from: dayStart, to: dayEnd)
            let ids = try await categoriesService.categories(for: direction).map(\.id)
            
            let filtered = all.filter { ids.contains($0.categoryId) }
            
            rawTransactions = filtered
            applySort()
        } catch {
            print("Ошибка загрузки транзакций: \(error)")
        }
    }
    
    private func applySort() {
        var sorted = rawTransactions
        
        switch sortOption {
        case .byDate:
            sorted.sort { $0.transactionDate > $1.transactionDate }
        case .byAmount:
            sorted.sort { $0.amount > $1.amount }
        }
        
        transactions = sorted
        totalAmount = sorted.reduce(0) { $0 + $1.amount }
    }
}
