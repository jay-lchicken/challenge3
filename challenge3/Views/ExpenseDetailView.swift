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
                        .onChange(of: expense.name) { _, newValue in
                            if newValue.count > 17 {
                                expense.name = String(newValue.prefix(17))
                            }
                        }
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

                }
            }
        }
        .navigationTitle(expense.name)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Image(systemName: expense.category.sFSymbol)
                        .font(.title2)
                    Text(expense.name)
                        .font(.headline)
                }
            }

            if isEditing {
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        showDelete = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditing.toggle()
                } label: {
                    if isEditing {
                        Image(systemName: "checkmark")
                    } else {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Are you sure?", isPresented: $showDelete) {
            Button("Yes", role: .destructive) {
                modelContext.delete(expense)
                dismiss()
            }
            .buttonStyle(.plain)
            Button("Cancel", role: .cancel) {}
        }
    }
}
