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
    @StateObject private var balanceManager = BalanceManager.shared
    
    
    private let bankAccountsService = BankAccountsService()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        headerView
                        balanceRow
                        currencyRow
                        
                        Spacer()
                            .frame(height: 200)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .scrollDismissesKeyboard(.immediately)
                .refreshable {
                    if !editing {
                        await loadAccount()
                        print("refreshed")
                    }
                }
                //                .onTapGesture {
                //                    isBalanceFieldFocused = false
                //                }
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
                        }
                        editing.toggle()
                    }
                    .foregroundColor(Color("ClockColor"))
                }
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
                    Text("\u{1F4B0}")
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
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isBalanceFieldFocused = true
                            }
                        }
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
        "\(balanceManager.balance.formatted()) \(currencyManager.selectedCurrency)"
    }
    
    @MainActor
    private func loadAccount() async {
        do {
            let result = try await bankAccountsService.accountForUser(userId: 1)
            account = result
            
            if UserDefaults.standard.string(forKey: "accountBalance") == nil {
                balanceManager.balance = result.balance
            }
            
            if UserDefaults.standard.string(forKey: "selectedCurrency") == nil {
                currencyManager.selectedCurrency = result.currency
            }
            
            editedBalance = "\(balanceManager.balance)"
            
        } catch {
            print("Ошибка загрузки счёта: \(error)")
        }
    }
    
    
    private func saveChanges() {
        if let value = Decimal(string: editedBalance) {
            balanceManager.balance = value
        }
    }
    
    
    private func sanitizedBalance(from text: String) -> String {
        // Оставляем только цифры и запятую/точку
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        let filtered = text.unicodeScalars.filter { allowedCharacters.contains($0) }
        var cleaned = String(String.UnicodeScalarView(filtered))
            .replacingOccurrences(of: ",", with: ".") // Заменяем запятую на точку
        
        // Убираем все точки, кроме первой
        if let firstDotRange = cleaned.range(of: ".") {
            let beforeDot = cleaned[..<firstDotRange.upperBound]
            let afterDot = cleaned[firstDotRange.upperBound...].replacingOccurrences(of: ".", with: "")
            cleaned = String(beforeDot + afterDot)
        }
        
        return cleaned
    }
    
    
}

#Preview {
    AccountView()
}
