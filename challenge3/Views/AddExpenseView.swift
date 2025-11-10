//
//  AddExpenseView.swift
//  challenge3
//
//  Created by Gautham Dinakaran on 10/11/25.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @State private var category = "beverage"
    @State private var name = ""
    @State private var date = Date()
    @State private var amount = ""
    
    let categories = ["beverage", "food", "transport", "entertainment", "bills", "shopping", "others"]
    
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
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

                Button("Add Expense") {
                    guard
                        let amt = parseAmount(amount),
                        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    else { return }

                    let expense = ExpenseItem(
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        amount: amt,
                        date: date.timeIntervalSince1970,
                        category: category
                    )
                    modelContext.insert(expense)
                    
                    showConfirmation = true
                    
                    category = "beverage"
                    name = ""
                    date = Date()
                    amount = ""
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showConfirmation = false
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("Add Expense")
        }.overlay(
            Group {
                if showConfirmation {
                    Text("Expense Added!")
                        .padding()
                        .background(.green.opacity(0.8))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                }
            }
        )
    }

    private func parseAmount(_ text: String) -> Double? {
        let cleaned = text.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return Double(cleaned)
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: ExpenseItem.self)
}
