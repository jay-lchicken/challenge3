//
//  GoalItemView.swift
//  challenge3
//
//  Created by Aletheus Ang on 17/11/25.
//

import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var isEditing = false
    @State private var showDelete = false
    @State private var showContribute = false

    @Bindable var goal: GoalItem

    var body: some View {
        VStack {
            Form {
                TextField("Goal Name", text: $goal.title)
                    .disabled(!isEditing)

                HStack(spacing: 0) {
                    Text("Current: $")
                    TextField("Current Amount", value: $goal.current, format: .number)
                        .keyboardType(.decimalPad)
                        .disabled(!isEditing)
                }

                HStack(spacing: 0) {
                    Text("Target: $")
                    TextField("Target Amount", value: $goal.target, format: .number)
                        .keyboardType(.decimalPad)
                        .disabled(!isEditing)
                }

                Button {
                    showContribute = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Contribute")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical)

                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            showDelete = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Goal")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
        }
        .navigationTitle("Goal Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { isEditing.toggle() } label: {
                    HStack {
                        if isEditing {
                            Text("Done")
                        } else {
                            Image(systemName: "pencil")
                        }
                    }
                }
            }
        }
        .alert("Are you sure?", isPresented: $showDelete) {
            Button("Yes", role: .destructive) {
                modelContext.delete(goal)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showContribute) {
            ContributeSheetView(goal: goal)
        }
        .onChange(of: goal.current) { newValue in
            if newValue >= goal.target {
                modelContext.delete(goal)
                dismiss()
            }
        }

    }
}
