//
//  CurrencySelectionView.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 25.06.2025.
//

import SwiftUI

struct CurrencySelectionView: View {
    @Binding var selectedCurrency: String
    @Binding var isPresented: Bool
    
    let currencies = [
        ("Российский рубль", "₽"),
        ("Американский доллар", "$"),
        ("Евро", "€")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок
            Text("Валюта")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.bottom, 14)
            
            
            Divider()
                .padding(.horizontal, 16)
                .frame(height: 0.5)
                .background(Color(red: 128/255, green: 128/255, blue: 128/255).opacity(0.55))
            
            // Список валют
            ForEach(currencies.indices, id: \.self) { index in
                let name = currencies[index].0
                let symbol = currencies[index].1
                
                Button(action: {
                    if symbol != selectedCurrency {
                        selectedCurrency = symbol
                    }
                    isPresented = false
                }) {
                    Text("\(name) \(symbol)")
                        .foregroundColor(Color("ClockColor"))
                        .font(.system(size: 17))
                        .kerning(-0.43)
                        .frame(height: 56)
                }
                
                
                // Divider, кроме последнего
                if index < currencies.count - 1 {
                    Divider()
                        .padding(.horizontal, 16)
                        .frame(height: 0.5)
                        .background(Color(red: 128/255, green: 128/255, blue: 128/255).opacity(0.55))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(14)
        .padding(.horizontal, 12.5)
        .padding(.bottom, 4)
    }
}
