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

    @State private var category = "food"
    @State private var name = ""
    @State private var date = Date()
    @State private var amount = ""

    let categories = CategoryOptionsModel().category

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat.capitalized).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundStyle(.yellow)
                }
                Section("Expense Name") {
                    TextField("Expense name", text: $name)
                        .onChange(of: name) { _, newValue in
                            if name.count > 17 {
                                name = String(newValue.prefix(17))
                            }
                        }
                }
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Amount") {
                    HStack {
                        Text("$")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save expense:", error.localizedDescription)
                        }
                        dismiss()
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        parseAmount(amount) == nil
                    )
                }
                
            }
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
