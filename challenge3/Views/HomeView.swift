//
//  HomeView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import SwiftUI
import SwiftData
struct HomeView: View {
    //SWIFT DATA
    @Environment(\.modelContext) var modelContext
    @Query var expenses:[ExpenseItem]
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
