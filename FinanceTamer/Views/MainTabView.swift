//
//  MainTabView.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 19.06.2025.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView {
            
            Group{
                TransactionsListView(direction: .outcome)
                    .tabItem {
                        Image("Expense")
                            .renderingMode(.template)
                        Text("Расходы")
                    }
                
                TransactionsListView(direction: .income)
                    .tabItem {
                        Image("income")
                            .renderingMode(.template)
                        Text("Доходы")
                    }
                
                AccountView()
                    .tabItem {
                        Image("Account")
                            .renderingMode(.template)
                        Text("Счет")
                    }
                
                CategoriesView()
                    .tabItem {
                        Image("Item")
                            .renderingMode(.template)
                        Text("Статьи")
                    }
                
                Text("Настройки")
                    .tabItem {
                        Image("Settings")
                            .renderingMode(.template)
                        Text("Настройки")
                    }
            }
            .toolbarBackground(.white, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
        .accentColor(Color("AccentColor"))
    }
}

#Preview {
    MainTabView()
}
