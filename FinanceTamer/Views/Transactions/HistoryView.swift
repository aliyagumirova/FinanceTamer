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

    @State private var transactions: [Transaction] = []
    @State private var totalAmount: Decimal = 0
    @ObservedObject private var currency = CurrencyManager.shared

    @State private var showSortOptions = false
    @State private var sortOption: SortOption = .byDate
    @State private var showAnalysis = false
    @State private var selectedTransaction: Transaction?

    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    @Environment(\.dismiss) private var dismiss

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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { backButton }
                ToolbarItem(placement: .navigationBarTrailing) { topActions }
            }
            .navigationBarBackButtonHidden(true)
            .confirmationDialog("Сортировать по:", isPresented: $showSortOptions, titleVisibility: .visible) {
                ForEach(SortOption.allCases) { option in
                    Button(option.rawValue) {
                        sortOption = option
                        applySort()
                    }
                }
                Button("Отмена", role: .cancel) {}
            }
            .navigationDestination(isPresented: $showAnalysis) {
                AnalysisViewWrapper(direction: direction)
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionEditView(direction: direction, mode: .edit(transaction))
            }
            .onChange(of: selectedTransaction) { newValue in
                if newValue == nil {
                    Task { await loadTransactions() }
                }
            }
            .task {
                await loadTransactions()
            }

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
        .alert("Не удалось загрузить данные", isPresented: $showError) {
            Button("Повторить") {
                Task { await loadTransactions() }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

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
                    .onTapGesture {
                        selectedTransaction = transaction
                    }
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
            Button {
                showAnalysis = true
            } label: {
                Image(systemName: "doc")
                    .foregroundColor(Color("ClockColor"))
            }
        }
    }

    @MainActor
    private func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let loaded = try await TransactionsNetworkService.shared.loadTransactions(
                accountId: 1,
                from: startDate,
                to: endDate,
                isIncome: direction == .income
            )

            let filtered = loaded.filter {
                direction == .income ? $0.category.isIncome : !$0.category.isIncome
            }

            self.transactions = filtered
            self.totalAmount = filtered.reduce(0) { $0 + $1.amount }
            applySort()

        } catch {
            await handleError(error)
        }
    }

    @MainActor
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
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
