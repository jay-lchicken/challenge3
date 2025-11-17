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

                HStack (spacing: 0){
                    Text("Target: $")
                    TextField("Target Amount", value: $goal.target, format: .number)
                        .keyboardType(.decimalPad)
                        .disabled(!isEditing)
                }

                if isEditing {
                    Button {
                        showDelete = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Goal")
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
        .navigationTitle("Goal Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditing.toggle()
                } label: {
                    if isEditing { Text("Done") } else { Image(systemName: "pencil") }
                }
                .buttonStyle(.plain)
            }
        }
        .alert("Are you sure?", isPresented: $showDelete) {
            Button("Yes", role: .destructive) {
                modelContext.delete(goal)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
