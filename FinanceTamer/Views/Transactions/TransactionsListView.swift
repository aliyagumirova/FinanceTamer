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
    @State private var showCreateScreen = false
    @State private var selectedTransaction: Transaction?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
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

                // Индикатор загрузки
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.1).ignoresSafeArea()
                        ProgressView("Загрузка...")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateScreen) {
            TransactionEditView(direction: direction, mode: .create)
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionEditView(direction: direction, mode: .edit(transaction))
        }
        .onChange(of: showCreateScreen) { isOpen in
            if !isOpen {
                Task { await loadTransactions() }
            }
        }
        .onChange(of: selectedTransaction) { selected in
            if selected == nil {
                Task { await loadTransactions() }
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
        // Алерт с кнопками Повторить и Отмена
        .alert("Не удалось загрузить данные", isPresented: $showError) {
            Button("Повторить") {
                Task { await loadTransactions() }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .task {
            await loadTransactions()
        }
    }

    // MARK: - Transactions List

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
                ForEach(transactions, id: \ .id) { transaction in
                    TransactionRow(transaction: transaction)
                        .onTapGesture {
                            selectedTransaction = transaction
                        }
                        .listRowBackground(Color.white)
                        .listRowInsets(EdgeInsets())
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Toolbar

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

    // MARK: - Floating Add Button

    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showCreateScreen = true
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

    // MARK: - Data Loading

    private func loadTransactions() async {
        let (startOfDay, endOfDay) = TransactionsNetworkService.shared.utcStartAndEndOfDay()
        let isIncome = (direction == .income)

        isLoading = true
        defer { isLoading = false }

        do {
            let loaded = try await TransactionsNetworkService.shared.loadTransactions(
                accountId: 1,
                from: startOfDay,
                to: endOfDay,
                isIncome: isIncome
            )

            let filtered = loaded.filter {
                direction == .income ? $0.category.isIncome : !$0.category.isIncome
            }

            await MainActor.run {
                self.transactions = filtered
                self.totalAmount = filtered.reduce(0) { $0 + $1.amount }
                self.applySort()
            }

        } catch {
            await handleError(error)
        }
    }

    // MARK: - Error Handling

    @MainActor
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }

    // MARK: - Sorting

    private func applySort() {
        switch sortOption {
        case .byDate:
            transactions.sort { $0.transactionDate > $1.transactionDate }
        case .byAmount:
            transactions.sort { $0.amount > $1.amount }
        }
    }
}
 
