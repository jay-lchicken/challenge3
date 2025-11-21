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
        NavigationStack {
            Form {
                Section("Goal Name") {
                    if isEditing {
                        TextField("Edit goal name", text: $goal.title)
                            .font(.title2)
                    } else {
                        Text(goal.title)
                            .font(.title)
                            .bold()
                    }
                }
                Section("Current Amount") {
                    if isEditing {
                        TextField("Edit current", value: $goal.current, format: .number)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                    } else {
                        Text("$\(goal.current, specifier: "%.2f")")
                            .font(.title)
                            .bold()
                    }
                }
                Section("Target Amount") {
                    if isEditing {
                        TextField("Edit target", value: $goal.target, format: .number)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                    } else {
                        Text("$\(goal.target, specifier: "%.2f")")
                            .font(.title)
                            .bold()
                    }
                }
                    Text("Created on \(goal.dateCreated, style: .date)")
                        .font(.headline
                    )
                Section {
                    Button {
                        showContribute = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Contribute")
                        }
                        .frame(maxWidth: .infinity)
                        .font(.title2)
                    }
                    .padding(.vertical)
                }
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            showDelete = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Goal")
                                    .font(.title2)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("Goal Details")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isEditing.toggle() } label: {
                        if isEditing {
                            Text("Done")
                        } else {
                            Image(systemName: "pencil")
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
        }
    }
}
