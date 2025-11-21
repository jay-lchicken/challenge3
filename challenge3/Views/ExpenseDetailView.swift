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

    @State private var isEditing = false
    @State private var showDelete = false

    @Bindable var expense: ExpenseItem

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
                let cleaned = newValue.replacingOccurrences(
                    of: "[^0-9.]",
                    with: "",
                    options: .regularExpression
                )
                if let val = Double(cleaned) {
                    expense.amount = val
                }
            }
        )
    }

    var body: some View {
        VStack {
            Form {
                Picker("Category", selection: $expense.category) {
                    ForEach(categories, id: \.self) {
                        Text($0.prefix(1).uppercased() + $0.dropFirst())
                    }
                }
                .disabled(!isEditing)

                TextField("Expense name", text: $expense.name)
                    .disabled(!isEditing)

                DatePicker("Date", selection: dateBinding, displayedComponents: .date)
                    .disabled(!isEditing)

                HStack {
                    Text("$")
                    TextField("Amount", text: amountStringBinding)
                        .keyboardType(.decimalPad)
                        .disabled(!isEditing)
                }
                if isEditing {
                    Button {
                        showDelete = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .glassEffect(.regular.tint(.red).interactive(), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .padding(.bottom)
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

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditing.toggle()
                } label: {
                    if isEditing {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.yellow)
                    } else {
                        Image(systemName: "pencil").foregroundColor(.yellow)
                    }
                }
                .buttonStyle(.plain)
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
