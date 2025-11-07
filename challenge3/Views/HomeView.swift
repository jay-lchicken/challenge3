//
//  HomeView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import SwiftUI

struct HomeView: View {
    @State var expenses: [ExpenseItem] = [ExpenseItem(name: "Starbucks Overpriceeed Moccha latte", amount: 12.0, date: Date().timeIntervalSince1970, category: "beverage")]
    @AppStorage("question") var query: String = ""
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    Section(header: Text("Today's Spending")){
                        VStack{
                            HStack{
                                Text("Spent: $10 ")
                                Spacer()
                                Text("Saved: $500 ")
                            }
                            ForEach(expenses, id: \.self){item in
                                ExpenseItemView(title: item.name, date: Date(timeIntervalSince1970: item.date), amount: item.amount, category: item.category)
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
