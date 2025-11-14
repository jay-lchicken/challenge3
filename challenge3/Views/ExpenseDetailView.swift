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
    
    // alerts
    @State private var showDelete: Bool = false
    @State private var showEdit: Bool = false

    let categories = ["Social Life", "Food", "Transport", "Payments", "Shopping", "Others"]

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
                ForEach(categories, id: \.self) {
                    Text($0)
                }
            }

            TextField("Expense name", text: $name)
            
            DatePicker("Date", selection: $date, displayedComponents: .date)

            HStack {
                Text("$")
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }

            Button(action: {
                showEdit = true
            }) {
                Image(systemName: "pencil")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }

            
            Button(action: {
                showDelete = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.body)
                    Text("Delete")
                }
                .padding()
                .glassEffect(.regular.tint(.red).interactive(), in: Capsule())
               
            }

        }
        .navigationTitle("Expense Detail")
        .alert("Confirm Edits?", isPresented: $showEdit) {
            Button("Yes") {
                guard let amt = Double(amount) else { return }
                
                expense.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                expense.category = category
                expense.date = date.timeIntervalSince1970
                expense.amount = amt
                
                dismiss()
            }
            Button("No", role: .cancel) {
            }
        }
        .alert("Are you sure?", isPresented: $showDelete) {
            Button("Yes", role: .destructive) {
                guard let amt = Double(amount) else { return }
                
                modelContext.delete(expense)
                dismiss()
            }
            Button("No", role: .cancel) {}
        }
    }
}
