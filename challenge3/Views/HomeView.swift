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
                List {
                    Section(header: Text("Today's Spending")) {
                        VStack {
                            HStack {
                                Text("Spent: $10")
                                Spacer()
                                Text("Saved: $500")
                            }

                            ForEach(expenses, id: \.self) { item in
                                NavigationLink {
                                    ExpenseDetailView(expense: item)
                                } label: {
                                    ExpenseItemView(
                                        title: item.name,
                                        date: Date(timeIntervalSince1970: item.date),
                                        amount: item.amount,
                                        category: item.category
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct ExpenseDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    var expense: ExpenseItem
   
    @State private var name: String
    @State private var category: String
    @State private var date: Date
    @State private var amount: String

    let categories = ["beverage", "food", "transport", "entertainment", "bills", "shopping", "others"]

    init(expense: ExpenseItem) {
        self.expense = expense
        _name = State(initialValue: expense.name)
        _category = State(initialValue: expense.category)
        _date = State(initialValue: Date(timeIntervalSince1970: expense.date))
        _amount = State(initialValue: String(expense.amount))
    }

    var body: some View {
        Form {
            Picker("Category", selection: $category) {
                ForEach(categories, id: \.self) { cat in
                    Text(cat.capitalized)
                }
            }

            TextField("Expense name", text: $name)
            
            DatePicker("Date", selection: $date, displayedComponents: .date)

            HStack {
                Text("$")
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }

            Button("Save Changes") {
                guard let amt = Double(amount) else { return }
                
                expense.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                expense.category = category
                expense.date = date.timeIntervalSince1970
                expense.amount = amt
                
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Delete Expense") {
                modelContext.delete(expense)
                dismiss()
            }
            .foregroundColor(.red)
        }
        .navigationTitle("Expense Detail")
    }
}


#Preview {
    HomeView()
}

