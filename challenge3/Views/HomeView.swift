//
//  HomeView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//
 
//
//  HomeView.swift
//  challenge3
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [ExpenseItem]
    @AppStorage("question") var query: String = ""

    @AppStorage("budget") private var budget: Double = 1500

    @State private var selectedExpense: ExpenseItem? = nil
    private var todaySpent: Double {
        let start = Calendar.current.startOfDay(for: Date())
        return expenses
            .filter { Date(timeIntervalSince1970: $0.date) >= start }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var todaySaved: Double {
        max(budget - todaySpent, 0)
    }

    var body: some View {
        NavigationStack {
            List {

                Section(header:
                    HStack(spacing: 10) {
                        Image(systemName: "dollarsign.circle")
                            .font(.title3)
                        Text("Today's Spending")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .foregroundColor(.primary)
                ) {

                    HStack {
                        Text("Spent: $\(todaySpent, specifier: "%.2f")")
                        Spacer()
                        Text("Saved: $\(todaySaved, specifier: "%.2f")")
                    }

                    ForEach(expenses, id: \.self) { item in
                        NavigationLink(
                            tag: item,
                            selection: $selectedExpense
                        ) {
                            ExpenseDetailView(expense: item)
                        } label: {
                            ExpenseItemView(
                                title: item.name,
                                date: Date(timeIntervalSince1970: item.date),
                                amount: item.amount,
                                category: item.category
                            )
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}
