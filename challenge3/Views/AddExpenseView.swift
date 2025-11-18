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

    @State private var category = "Others"
    @State private var name = ""
    @State private var date = Date()
    @State private var amount = ""
    
    @FocusState private var isAmountFocused: Bool

    let categories = CategoryOptionsModel().category
    @State private var showAlert = false
    
    var clickButton: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && parseAmount(amount) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat.capitalized)
                            .tag(cat)
                        }
                }
                .pickerStyle(.menu)

                TextField("Expense name", text: $name)

                DatePicker("Date", selection: $date, displayedComponents: .date)

                HStack {
                    Text("$")
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($isAmountFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isAmountFocused = false
                                }
                            }
                        }
                }

                Button("Add Expense") {
                    isAmountFocused = false
                    
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
                    
                    category = "Food"
                    name = ""
                    date = Date()
                    amount = ""
                    
                    showAlert = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(!clickButton)
                .opacity(clickButton ? 1.0 : 0.5)
            }
            .alert("Expense Added!", isPresented: $showAlert) {
                Button("OK") {
                    dismiss()
                }
            }
            .navigationTitle("Add Expense")
        }
        .onTapGesture {                    
            isAmountFocused = false
        }
    }

    private func parseAmount(_ text: String) -> Double? {
        let cleaned = text.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return Double(cleaned)
    }
}

#Preview {
    AddExpenseView()
        .modelContainer(for: [ExpenseItem.self, GoalItem.self])

}
