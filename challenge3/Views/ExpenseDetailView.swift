//
//  ExpenseDetailView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/14/25.
//

import SwiftUI
import SwiftData
import Foundation

struct ExpenseDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @Bindable var expense: ExpenseItem
    @State private var isEditing = false
    @State private var showDelete = false

    let categories = CategoryOptionsModel().category

    private var dateBinding: Binding<Date> {
        Binding<Date>(
            get: { Date(timeIntervalSince1970: expense.date) },
            set: { expense.date = $0.timeIntervalSince1970 }
        )
    }

    private var amountStringBinding: Binding<String> {
        Binding<String>(
            get: {
                if expense.amount.truncatingRemainder(dividingBy: 1) == 0 {
                    return String(Int(expense.amount))
                } else {
                    return String(expense.amount)
                }
            },
            set: { newValue in
                let cleaned = newValue.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                if let val = Double(cleaned) {
                    expense.amount = val
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $expense.category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat.capitalized).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(!isEditing)
                }
                Section("Expense Name") {
                    TextField("Expense name", text: $expense.name)
                        .disabled(!isEditing)
                }
                Section("Date") {
                    DatePicker("Date", selection: dateBinding, displayedComponents: .date)
                        .disabled(!isEditing)
                }
                Section("Amount") {
                    HStack {
                        Text("$")
                        TextField("Amount", text: amountStringBinding)
                            .keyboardType(.decimalPad)
                            .disabled(!isEditing)
                    }
                }
                if isEditing {
                    Section {
                        Button("Delete", role: .destructive) {
                            showDelete = true
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(expense.name)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if isEditing {
                        Button("Save") {
                            isEditing = false
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !isEditing {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
            .alert("Are you sure you want to delete this expense?", isPresented: $showDelete) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(expense)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
