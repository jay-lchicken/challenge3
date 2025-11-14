//
//  FinanceView.swift
//  challenge3
//
//  Created by Aletheus Ang on 9/11/25.
//

import SwiftUI
import SwiftData
import Charts

struct FinanceView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \ExpenseItem.date, order: .reverse) var expenses: [ExpenseItem]

    @State private var selectedTab = "Overview"
    @State private var selectedExpenseTab = "Today’s expenses"
    @State private var budget: Double = 1500

    
    private var filteredExpenses: [ExpenseItem] {
        let calendar = Calendar.current
        switch selectedExpenseTab {
        case "Today’s expenses":
            return expenses.filter { calendar.isDateInToday(Date(timeIntervalSince1970: $0.date)) }
        case "Monthly Expenses":
            return expenses.filter { calendar.isDate(Date(timeIntervalSince1970: $0.date), equalTo: Date(), toGranularity: .month) }
        default:
            return expenses
        }
    }

    private var categoryTotals: [(category: String, total: Double)] {
        let grouped = Dictionary(grouping: filteredExpenses, by: { $0.category })
        return grouped.map { (key, value) in
            (category: key, total: value.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.total > $1.total }
    }

    private var totalSpent: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    private var remainingBudget: Double {
        max(budget - totalSpent, 0)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Finance")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                Picker("", selection: $selectedTab) {
                    Text("Overview").tag("Overview")
                    Text("Expenses").tag("Expenses")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Picker("", selection: $selectedExpenseTab) {
                                Text("Today’s expenses").tag("Today’s expenses")
                                Text("Monthly Expenses").tag("Monthly Expenses")
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)

                            Button("Edit Budget") {}
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                      
                        if !categoryTotals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Expense Categories").font(.caption)
                                Chart(categoryTotals, id: \.category) { item in
                                    SectorMark(
                                        angle: .value("Total", item.total),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 1
                                    )
                                    .foregroundStyle(by: .value("Category", item.category))
                                }
                                .frame(height: 250)
                                .padding(.horizontal)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Expense Breakdown").font(.caption)

                            GeometryReader { geometry in
                                let totalWidth = geometry.size.width
                                let spentWidth = totalWidth * (min(totalSpent / budget, 1))
                                let remainingWidth = totalWidth - spentWidth

                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.gray.opacity(0.2)).frame(height: 20)
                                    HStack(spacing: 0) {
                                        Capsule().fill(Color.red).frame(width: spentWidth, height: 20)
                                        Capsule().fill(Color.green).frame(width: remainingWidth, height: 20)
                                    }
                                }
                            }
                            .frame(height: 20)

                            Text("Budget: $\(Int(budget)) | Spent: $\(Int(totalSpent)) | Saved: $\(Int(remainingBudget))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        HStack(spacing: 30) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Food: $\(Int(filteredExpenses.filter { $0.category == "food" }.reduce(0) { $0 + $1.amount }))")
                                    Circle().fill(Color.green).frame(width: 15)
                                }
                                HStack {
                                    Text("Utilities: $\(Int(filteredExpenses.filter { $0.category == "bills" }.reduce(0) { $0 + $1.amount }))")
                                    Circle().fill(Color.yellow).frame(width: 15)
                                }
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Transport: $\(Int(filteredExpenses.filter { $0.category == "transport" }.reduce(0) { $0 + $1.amount }))")
                                    Circle().fill(Color.red).frame(width: 15)
                                }
                                HStack {
                                    Text("Saved: $\(Int(remainingBudget))")
                                    Circle().fill(Color.gray).frame(width: 15)
                                }
                            }
                        }

                       
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Goals:")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Button("Add New") {}
                                    .padding(6)
                                    .background(Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Porsche Car - 75K / 150K")
                                    .font(.headline)
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.orange.opacity(0.5)).frame(height: 20)
                                    HStack(spacing: 0) {
                                        Capsule().fill(Color.green).frame(width: 150, height: 20)
                                        Capsule().fill(Color.red).frame(width: 50, height: 20)
                                    }
                                }
                                Text("Just a little bit more!")
                                    .italic()
                            }
                            .padding()
                            .background(Color.orange.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    FinanceView()
        .modelContainer(for: ExpenseItem.self)
}
