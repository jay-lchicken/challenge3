//
//  EditBudgetView.swift
//  challenge3
//
//  Created by Gautham Dinakaran on 17/11/25.
//

import SwiftUI
import SwiftData

struct EditBudgetsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let categories: [String]
    @Query(sort: \BudgetItem.category) private var budgets: [BudgetItem]
    @State private var localCaps: [String: Double] = [:]
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    init(categories: [String]) {
        self.categories = categories
    }
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(categories, id: \.self) { category in
                    HStack {
                        Text(category)
                        Spacer()
                        TextField("0", value: Binding(
                            get: { localCaps[category] ?? startingCap(for: category) },
                            set: { localCaps[category] = $0 }
                        ), formatter: NumberFormatter())
                        .frame(width: 70)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Edit Budgets")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAll() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear { loadInitialValues() }
            .alert("Save Error", isPresented: $showErrorAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(errorMessage)
            })
        }
    }
    
    private func loadInitialValues() {
        for cat in categories {
            localCaps[cat] = startingCap(for: cat)
        }
    }
    
    private func startingCap(for cat: String) -> Double {
        budgets.first(where: { $0.category.lowercased() == cat.lowercased() })?.cap ?? 200
    }
    
    private func saveAll() {
        for cat in categories {
            let newCap = localCaps[cat] ?? 0
            if let existing = budgets.first(where: { $0.category.lowercased() == cat.lowercased() }) {
                existing.cap = newCap
            } else {
                modelContext.insert(BudgetItem(category: cat, cap: newCap))
            }
        }
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save budgets: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
