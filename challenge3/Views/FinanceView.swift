//
//  FinanceView.swift
//  challenge3
//
//  Created by Aletheus Ang on 7/11/25.
//

import SwiftUI
import SwiftData
import Charts

struct FinanceView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \ExpenseItem.date, order: .reverse) var expenses: [ExpenseItem]
    @Query(sort: \GoalItem.dateCreated, order: .reverse) var goals: [GoalItem]
    @Query(sort: \BudgetItem.category, order: .forward) var budgets: [BudgetItem]

    @State private var selectedTab = "Overview"
    @State private var selectedTimeRange = "Monthly"
    @State private var showAddGoal = false
    @State private var showEditBudgets = false
    @State private var showDateRangePicker = false
    @State private var dateRangeStart = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var dateRangeEnd = Date()
    
    let timeRanges = ["Daily", "Monthly", "Yearly"]
    let categories = ["Food", "Transport", "Lifestyle", "Subscriptions", "Shopping", "Others"]
    
    private var filteredExpenses: [ExpenseItem] {
        let calendar = Calendar.current
        return expenses.filter { exp in
            let date = Date(timeIntervalSince1970: exp.date)
            switch selectedTimeRange {
            case "Daily": return calendar.isDateInToday(date)
            case "Monthly": return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
            case "Yearly": return calendar.isDate(date, equalTo: Date(), toGranularity: .year)
            default: return true
            }
        }
    }
    
    private func expensesBetween(_ start: Date, _ end: Date) -> [ExpenseItem] {
        let s = Calendar.current.startOfDay(for: start)
        let e = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
        return expenses.filter { exp in
            let d = Date(timeIntervalSince1970: exp.date)
            return d >= s && d <= e
        }
    }
    
    private var categoryTotals: [(category: String, total: Double)] {
        let grouped = Dictionary(grouping: filteredExpenses, by: { $0.category })
        return grouped
            .map { (key, value) in (category: key, total: value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }
    
    private var totalSpent: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var filteredBudgetTotal: Double {
        let categoriesShown = Set(filteredExpenses.map { $0.category.lowercased() })
        return budgets.filter { categoriesShown.contains($0.category.lowercased()) }
                      .reduce(0) { $0 + $1.cap }
    }

    
    private var totalBudget: Double {
        budgets.reduce(0) { $0 + $1.cap }
    }
    
    private var remainingBudget: Double { max(totalBudget - totalSpent, 0) }
    
    private func capForCategory(_ cat: String) -> Double {
        budgets.first(where: { $0.category.lowercased() == cat.lowercased() })?.cap ?? 200
    }
    
    private func spent(for category: String) -> Double {
        filteredExpenses.filter { $0.category.lowercased() == category.lowercased() }
                .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("", selection: $selectedTab) {
                    Text("Overview").tag("Overview")
                    Text("Budget").tag("Budget")
                    Text("Expenses").tag("Expenses")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if selectedTab == "Expenses" {
                            expensesTab
                        } else if selectedTab == "Budget" {
                            budgetTab
                        } else {
                            overviewTab
                        }
                    }
                    .padding(.vertical)
                }
            }
            .toolbar {
                if selectedTab == "Expenses" {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showDateRangePicker = true
                        } label: {
                            Image(systemName: "calendar")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                if selectedTab != "Expenses" {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            ForEach(timeRanges, id: \.self) { range in
                                Button(range) { selectedTimeRange = range }
                            }
                        } label: {
                            Text(selectedTimeRange)
                                .foregroundColor(.yellow)
                                .bold()
                        }
                    }
                }
            }
            .sheet(isPresented: $showDateRangePicker) {
                VStack {
                    DatePicker("Start", selection: $dateRangeStart, displayedComponents: .date)
                    DatePicker("End", selection: $dateRangeEnd, displayedComponents: .date)
                    Button("Done") { showDateRangePicker = false }
                        .padding()
                }
                .padding()
            }
            .navigationTitle("Finance")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddGoal) { AddGoalView() }
            .sheet(isPresented: $showEditBudgets) {
                EditBudgetsView(categories: categories)
            }
        }
    }

    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !categoryTotals.isEmpty {
                Text("Expense Categories")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack(alignment: .top, spacing: 12) {
                    Chart(categoryTotals, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.total),
                            innerRadius: .ratio(0.55),
                            angularInset: 1
                        )
                        .foregroundStyle(item.category.categoryColor)
                    }
                    .frame(width: 220, height: 220)
                    .padding(.leading, 12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(categoryTotals, id: \.category) { item in
                            HStack(spacing: 8) {
                                Image(systemName: item.category.sFSymbol)
                                    .foregroundColor(item.category.categoryColor)
                                Text(item.category)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Spacer()
                                Text("$\(Int(item.total))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.trailing)
                }
            }
            
            Text("Expense Breakdown")
                .font(.headline)
                .padding(.horizontal)
            
            GeometryReader { geo in
                let width = geo.size.width
                let ratio = totalBudget > 0 ? CGFloat(min(totalSpent / totalBudget, 1)) : 0
                let filled = width * ratio
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.12)).frame(height: 20)
                    Capsule().fill(Color.red).frame(width: filled, height: 20)
                }
            }
            .frame(height: 20)
            .padding(.horizontal)
            
            Text("Budget: $\(Int(totalBudget)) | Spent: $\(Int(totalSpent)) | Saved: $\(Int(max(totalBudget - totalSpent, 0)))")
                .font(.caption)
                .padding(.horizontal)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Goals:")
                        .font(.title3).bold()
                    Spacer()
                    Button("Add New") { showAddGoal = true }
                        .foregroundColor(.yellow)
                }
                
                ForEach(goals) { goal in
                    NavigationLink {
                        GoalDetailView(goal: goal)
                    } label: {
                        goalCard(goal)
                    }
                    .buttonStyle(.plain)
                }

            }
            .padding(.horizontal)
        }
    }
    
    private var budgetTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Category Budgets")
                    .font(.headline)
                Spacer()
                Button {
                    showEditBudgets = true
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(categories, id: \.self) { cat in
                    categoryBudgetCard(cat)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var expensesTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Expenses")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            let results = expensesBetween(dateRangeStart, dateRangeEnd)
            
            if results.isEmpty {
                Text("No expenses")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 10) {
                    ForEach(results, id: \.self) { item in
                        ExpenseItemView(title: item.name,
                                        date: Date(timeIntervalSince1970: item.date),
                                        amount: item.amount,
                                        category: item.category)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func categoryBudgetCard(_ cat: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: cat.sFSymbol)
                    .foregroundColor(cat.categoryColor)
                Text(cat)
                    .font(.subheadline)
                Spacer()
                Text("Budget $\(Int(capForCategory(cat)))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geo in
                let width = geo.size.width
                let spentAmount = spent(for: cat)
                let cap = capForCategory(cat)
                let ratio = cap > 0 ? CGFloat(min(spentAmount / cap, 1)) : 0
                let filled = width * ratio
                
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.12)).frame(height: 18)
                    Capsule().fill(Color.red).frame(width: filled, height: 18)
                }
            }
            .frame(height: 18)
            
            Text("Spent: $\(Int(spent(for: cat)))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func goalCard(_ goal: GoalItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(goal.title) — $\(Int(goal.current))/$\(Int(goal.target))")
                Spacer()
                Text("\(Int(min(goal.current / goal.target, 1) * 100))%")
                    .foregroundColor(.gray)
            }
            GeometryReader { geo in
                let w = geo.size.width
                let ratio = CGFloat(min(goal.current / goal.target, 1))
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.3)).frame(height: 18)
                    Capsule().fill(Color.green).frame(width: w * ratio, height: 18)
                }
            }
            .frame(height: 18)
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
