//
//  HomeView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    // SWIFT DATA
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [ExpenseItem]
    @AppStorage("question") var query: String = ""

    @State private var selectedExpense: ExpenseItem? = nil
    @State private var showExpenseDetail = false

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Today's Spending")) {
                        HStack {
                            Text("Spent: $10")
                            Spacer()
                            Text("Saved: $500")
                        }

                        ForEach(expenses, id: \.self) { item in
                            Button {
                                selectedExpense = item
                                showExpenseDetail = true
                            } label: {
                                ExpenseItemView(
                                    title: item.name,
                                    date: Date(timeIntervalSince1970: item.date),
                                    amount: item.amount,
                                    category: item.category
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                            .accessibilityLabel("Profile")
                    }
                }
            }
            .sheet(isPresented: $showExpenseDetail) {
                if let expense = selectedExpense {
                    NavigationStack {
                        ExpenseDetailView(expense: expense)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: ExpenseItem.self)
}



#Preview {
    HomeView()
}

