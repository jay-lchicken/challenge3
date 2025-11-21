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
                    } else {
                        Text(goal.title)
                            .bold()
                    }
                }
                if isEditing {
             
                } else {
                    Section("Current Amount") {
                        Text("$\(goal.current, specifier: "%.2f")")
                            .bold()
                        
                    }
                    
                }
                
                Section("Target Amount") {
                    if isEditing {
                        TextField("Edit target", value: $goal.target, format: .number)
                            .keyboardType(.decimalPad)
                    } else {
                        Text("$\(goal.target, specifier: "%.2f")")
                            .bold()
                    }
                }
                
                Text("Created on \(goal.dateCreated, style: .date)")
                    
                
                
            }
            .navigationTitle("Goal Details")
            .toolbar {
                if isEditing{
                    ToolbarItem(placement: .topBarTrailing){
                        Button(role: .destructive) {
                            showDelete = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isEditing.toggle() } label: {
                        if isEditing {
                            Image(systemName: "checkmark")
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
