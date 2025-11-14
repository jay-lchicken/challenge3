//
//  AddGoalView.swift
//  challenge3
//
//  Created by Aletheus Ang on 14/11/25.
//

import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @State private var title = ""
    @State private var current = ""
    @State private var target = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Goal Name", text: $title)
                TextField("Current Amount", text: $current)
                    .keyboardType(.decimalPad)
                TextField("Target Amount", text: $target)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Goal")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let currentVal = Double(current),
                              let targetVal = Double(target) else { return }

                        let newGoal = GoalItem(title: title, current: currentVal, target: targetVal)
                        modelContext.insert(newGoal)
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
