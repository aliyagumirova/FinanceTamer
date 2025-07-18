//
//  AccountView.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 25.06.2025.
//

import SwiftUI

struct AccountView: View {
    @State private var account: BankAccount?
    @State private var editing = false
    @State private var editedBalance = ""
    @State private var showCurrencySheet = false
    @State private var isBalanceHidden = false

    @FocusState private var isBalanceFieldFocused: Bool

    @StateObject private var currencyManager = CurrencyManager.shared
    private let bankAccountsService = BankAccountsNetworkService.shared

    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        headerView
                        balanceRow
                        currencyRow
                        Spacer().frame(height: 200)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .scrollDismissesKeyboard(.immediately)
                .refreshable {
                    if !editing {
                        await loadAccount()
                        print("🔄 Refreshed")
                    }
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
            .onShake {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isBalanceHidden.toggle()
                }
            }
            .navigationTitle("Мой счёт")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editing ? "Сохранить" : "Редактировать") {
                        if editing {
                            saveChanges()
                            isBalanceFieldFocused = false
                        }
                        editing.toggle()
                    }
                    .foregroundColor(Color("ClockColor"))
                }
            }
            .alert("Не удалось загрузить данные", isPresented: $showError) {
                Button("Повторить") {
                    Task { await loadAccount() }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .overlay(
                Group {
                    if showCurrencySheet {
                        ZStack {
                            Color.black.opacity(0.2)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    withAnimation {
                                        showCurrencySheet = false
                                    }
                                }

                            CurrencySelectionView(
                                selectedCurrency: $currencyManager.selectedCurrency,
                                isPresented: $showCurrencySheet
                            )
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .transition(.move(edge: .bottom))
                            .animation(.easeOut(duration: 0.3), value: showCurrencySheet)
                        }
                    }
                }
            )
            .task {
                await loadAccount()
            }
            .onAppear {
                Task {
                    await loadAccount()
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        EmptyView()
    }

    private var balanceRow: some View {
        VStack(spacing: 4) {
            HStack {
                HStack(spacing: 8) {
                    Text("💰")
                    Text("Баланс")
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                }

                Spacer()

                if editing {
                    TextField("0", text: $editedBalance)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($isBalanceFieldFocused)
                } else {
                    Text(formattedBalance)
                        .foregroundColor(Color("ArrowColor"))
                        .spoiler(isOn: $isBalanceHidden)
                }
            }

            if editing {
                HStack {
                    Spacer()
                    Button("Вставить") {
                        if let clipboard = UIPasteboard.general.string {
                            editedBalance = sanitizedBalance(from: clipboard)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color("AccentColor"))
                }
            }
        }
        .frame(height: editing ? 70 : 44)
        .padding(.horizontal, 16)
        .background(editing ? Color.white : Color("AccentColor"))
        .cornerRadius(10)
    }

    private var currencyRow: some View {
        Button(action: {
            if editing {
                showCurrencySheet = true
            }
        }) {
            HStack {
                Text("Валюта")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)

                Spacer()

                Text(currencyManager.selectedCurrency)
                    .foregroundColor(.black)

                if editing {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color("ArrowColor"))
                        .opacity(0.3)
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 16)
            .background(editing ? Color.white : Color("ImageBackgroundColor"))
            .cornerRadius(10)
        }
        .disabled(!editing)
    }

    // MARK: - Logic

    private var formattedBalance: String {
        guard let account = account else { return "–" }
        return "\(account.balance) \(currencyManager.selectedCurrency)"
    }

    @MainActor
    private func loadAccount() async {
        isLoading = true
        defer { isLoading = false }

        do {
            print("📱 Загружаем счёт...")
            let accounts = try await bankAccountsService.loadAccounts()

            guard let result = accounts.first else {
                throw NSError(domain: "AccountView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Список аккаунтов пуст"])
            }

            self.account = result
            self.editedBalance = result.balance
            self.currencyManager.selectedCurrency = result.currency

        } catch {
            await handleError(error)
        }
    }

    private func saveChanges() {
        guard let account = account else { return }

        Task {
            isLoading = true
            defer { isLoading = false }

            let result = await bankAccountsService.updateAccount(
                id: account.id,
                name: account.name,
                balance: editedBalance,
                currency: currencyManager.selectedCurrency
            )

            switch result {
            case .success(let updated):
                self.account = updated
                self.editedBalance = updated.balance
                self.currencyManager.selectedCurrency = updated.currency

                UserDefaults.standard.set(updated.balance, forKey: "accountBalance")
                UserDefaults.standard.set(updated.currency, forKey: "selectedCurrency")

            case .failure(let error):
                await handleError(error)
            }
        }
    }


    @MainActor
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }

    private func sanitizedBalance(from text: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        let filtered = text.unicodeScalars.filter { allowedCharacters.contains($0) }
        var cleaned = String(String.UnicodeScalarView(filtered))
            .replacingOccurrences(of: ",", with: ".")

        if let firstDotRange = cleaned.range(of: ".") {
            let beforeDot = cleaned[..<firstDotRange.upperBound]
            let afterDot = cleaned[firstDotRange.upperBound...].replacingOccurrences(of: ".", with: "")
            cleaned = String(beforeDot + afterDot)
        }

        return cleaned
    }
}
