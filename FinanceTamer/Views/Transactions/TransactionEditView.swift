//
//  TransactionEditView.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 12.07.2025.
//

import SwiftUI
import Foundation

enum EditMode {
    case create
    case edit(Transaction)
}

struct TransactionEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    let direction: Direction
    let mode: EditMode
    
    @State private var selectedCategory: Category?
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var comment: String = ""
    
    @State private var availableCategories: [Category] = []
    @State private var showCategorySheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let transactionsService = TransactionsNetworkService.shared
    private let categoriesService = CategoriesNetworkService.shared
    private let bankAccountService = BankAccountsService()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showCategorySheet = true
                    } label: {
                        HStack {
                            Text("Статья")
                                .foregroundColor(.black)
                            Spacer()
                            categoryText
                        }
                    }
                    
                    HStack {
                        Text("Сумма")
                            .foregroundColor(.black)
                        Spacer()
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    
                    DatePicker("Дата", selection: $date, in: ...Date(), displayedComponents: [.date])
                    DatePicker("Время", selection: $date, displayedComponents: [.hourAndMinute])
                    
                    TextField("Комментарий", text: $comment, prompt: Text("Комментарий").foregroundColor(.gray))
                }
                
                if case .edit(let transaction) = mode {
                    Section {
                        Button(role: .destructive) {
                            Task {
                                _ = try? await transactionsService.delete(id: transaction.id)
                                dismiss()
                            }
                        } label: {
                            Text("Удалить расход")
                        }
                    }
                }
            }
            .navigationTitle("Мои \(direction == .income ? "Доходы" : "Расходы")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(Color("ClockColor"))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(modeTitle) {
                        handleSave()
                    }
                    .foregroundColor(Color("ClockColor"))
                }
            }
            .confirmationDialog("Выберите категорию", isPresented: $showCategorySheet) {
                ForEach(availableCategories, id: \.id) { cat in
                    Button("\(String(cat.emoji)) \(cat.name)") {
                        selectedCategory = cat
                    }
                }
            }
            .alert("Ошибка", isPresented: $showAlert) {
                Button("Ок", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onChange(of: amount) { newValue in
                let decimalSeparator = Locale.current.decimalSeparator ?? ","
                let allowedChars = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: decimalSeparator))
                
                let filtered = newValue.unicodeScalars
                    .filter { allowedChars.contains($0) }
                    .map { String($0) }
                    .joined()
                
                let parts = filtered.components(separatedBy: decimalSeparator)
                if parts.count <= 2 {
                    amount = filtered
                } else {
                    amount = parts[0] + decimalSeparator + parts[1]
                }
            }
            .onAppear {
                Task {
                    availableCategories = (try? await categoriesService.categories()) ?? []
                    
                    if case .edit(let transaction) = mode {
                        selectedCategory = availableCategories.first(where: { $0.id == transaction.category.id })
                        amount = formattedAmount(transaction.amount)
                        date = transaction.transactionDate
                        comment = transaction.comment
                    }
                }
            }
        }
    }
    
    // MARK: - Вынесенный текст категории для упрощения body
    
    private var categoryText: some View {
        Group {
            if let cat = selectedCategory {
                Text("\(String(cat.emoji)) \(cat.name)")
            } else {
                Text("Выбрать")
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var modeTitle: String {
        switch mode {
        case .create: return "Создать"
        case .edit: return "Сохранить"
        }
    }
    
    // MARK: - Logic
    
    private func handleSave() {
        guard let category = selectedCategory else {
            showValidationError("Выберите категорию")
            return
        }

        guard let parsedAmount = parseAmount(from: amount), parsedAmount > 0 else {
            showValidationError("Введите корректную сумму")
            return
        }

        Task {
            do {
                let account = try await bankAccountService.accountForUser(userId: 1)
               
                switch mode {
                case .create:
                    let response = try await transactionsService.create(
                        accountId: account.id,
                        categoryId: category.id,
                        amount: parsedAmount,
                        transactionDate: date,
                        comment: comment
                    )

                case .edit(let old):
                    let updated = Transaction(
                        id: old.id,
                        account: account,
                        category: category,
                        amount: parsedAmount,
                        transactionDate: date,
                        comment: comment,
                        createdAt: old.createdAt,
                        updatedAt: Date()
                    )

                    let response = try await transactionsService.update(updated)
                }

                dismiss()
            } catch {
                showValidationError("Ошибка: \(error.localizedDescription)")
            }
        }
    }


    private func showValidationError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func parseAmount(from text: String) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter.number(from: text)?.decimalValue
    }
    
    private func formattedAmount(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter.string(from: value as NSDecimalNumber) ?? ""
    }
}
