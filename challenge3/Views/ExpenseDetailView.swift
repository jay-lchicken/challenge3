//
//  ExpenseDetailView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/14/25.
//

import Foundation
import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    var expense: ExpenseItem

    @State private var name: String
    @State private var category: String
    @State private var date: Date
    @State private var amount: String

    @State private var isEditing = false

    // alerts
    @State private var showDelete = false
    @State private var showEditConfirm = false

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
            .disabled(!isEditing)

            TextField("Expense name", text: $name)
                .disabled(!isEditing)

            DatePicker("Date", selection: $date, displayedComponents: .date)
                .disabled(!isEditing)

            HStack {
                Text("$")
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .disabled(!isEditing)
            }

            Button(role: .destructive) {
                showDelete = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Expense Detail")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        showEditConfirm = true
                    } else {
                        isEditing = true
                    }
                }
            }
        }
        .alert("Confirm Edits?", isPresented: $showEditConfirm) {
            Button("Yes") {
                applyEdits()
            }
            Button("No", role: .cancel) {
                revertChanges()
                isEditing = false
            }
        }
        .alert("Are you sure?", isPresented: $showDelete) {
            Button("Yes", role: .destructive) {
                modelContext.delete(expense)
                dismiss()
            }
        }
    }
    
    // functiosn
    
    private func applyEdits() {
        guard let amt = Double(amount) else { return }

        expense.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        expense.category = category
        expense.date = date.timeIntervalSince1970
        expense.amount = amt

        isEditing = false
    }

    private func revertChanges() {
        name = expense.name
        category = expense.category
        date = Date(timeIntervalSince1970: expense.date)
        amount = String(expense.amount)
    }
}

