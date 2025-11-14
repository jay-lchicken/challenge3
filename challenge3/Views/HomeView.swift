//
//  HomeView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    //SWIFT DATA
    @Environment(\.modelContext) var modelContext
    @Query var expenses:[ExpenseItem]
    @AppStorage("question") var query: String = ""
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    Section(header: Text("Today's Spending")) {
                        List {
                            Section(header: Text("Today's Spending")) {

                                HStack {
                                    Text("Spent: $10")
                                    Spacer()
                                    Text("Saved: $500")
                                }

                                ForEach(expenses, id: \.self) { item in
                                    NavigationLink {
                                        ExpenseDetailView(expense: item)
                                    } label: {
                                        ExpenseItemView(
                                            title: item.name,
                                            date: Date(timeIntervalSince1970: item.date),
                                            amount: item.amount,
                                            category: item.category
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                            .accessibilityLabel("Profile")
                    }
                }
            }
        }
    }
}

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

    let categories = ["beverage", "food", "transport", "entertainment", "bills", "shopping", "others"]

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
                ForEach(categories, id: \.self) { cat in
                    Text(cat.capitalized)
                }
            }

            TextField("Expense name", text: $name)
            
            DatePicker("Date", selection: $date, displayedComponents: .date)

            HStack {
                Text("$")
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }
            
            HStack (spacing: 20) {
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
                    Text("Add Edits")
                }
                
                
                Button(action: {
                    showDelete = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.body)
                        Text("Delete")
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Color.red)
                    .cornerRadius(10)
                }
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


#Preview {
    HomeView()
}

