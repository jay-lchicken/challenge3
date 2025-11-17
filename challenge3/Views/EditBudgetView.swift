//
//  EditBudgetView.swift
//  challenge3
//
//  Created by Gautham Dinakaran on 17/11/25.
//

import SwiftUI
import SwiftData

struct EditBudgetsView: View {
    let categories: [String]
    var existingBudgets: [BudgetItem]
    var onDone: () -> Void

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var local: [String: String] = [:]

    init(categories: [String], existingBudgets: [BudgetItem], onDone: @escaping () -> Void) {
        self.categories = categories
        self.existingBudgets = existingBudgets
        self.onDone = onDone

        var d: [String: String] = [:]
        for cat in categories {
            if let b = existingBudgets.first(where: { $0.category.lowercased() == cat.lowercased() }) {
                d[cat] = String(Int(b.cap))
            } else {
                d[cat] = "200"
            }
        }
        _local = State(initialValue: d)
    }

    var body: some View {
        NavigationStack {
            Form {
                ForEach(categories, id: \.self) { cat in
                    HStack {
                        Text(cat)
                        Spacer()
                        TextField("0",
                                  text: Binding(
                                    get: { local[cat] ?? "0" },
                                    set: { local[cat] = $0 }
                                  ))
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Edit Budgets")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        for cat in categories {
                            let newCap = Double(local[cat] ?? "0") ?? 0

                            if let existing = existingBudgets.first(where: {
                                $0.category.lowercased() == cat.lowercased()
                            }) {
                                existing.cap = newCap
                            } else {
                                let b = BudgetItem(category: cat, cap: newCap)
                                modelContext.insert(b)
                            }
                        }
                        try? modelContext.save()
                        onDone()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
