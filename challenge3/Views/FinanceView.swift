//
//  FinanceView.swift
//  challenge3
//
//  Created by Aletheus on 11/7/25.
//

import SwiftUI
import SwiftData
import Charts

struct FinanceView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \ExpenseItem.date, order: .reverse) var expenses: [ExpenseItem]
    @Query(sort: \GoalItem.dateCreated, order: .reverse) var goals: [GoalItem]
    @Query(sort: \BudgetItem.category, order: .forward) var budgets: [BudgetItem]

    @State private var selectedTab = "Expenses"
    @State private var selectedTimeRange = "Monthly"
    @State private var showAddGoal = false
    @State private var showEditBudgets = false
    @State private var showDateRangePicker = false
    @State private var dateRangeStart = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var dateRangeEnd = Date()
    @State private var showAddExpense = false

    let categories = CategoryOptionsModel().category

    let timeRanges = ["Daily", "Monthly", "Yearly"]
    let tabs = ["Budget", "Expenses"]
    
    @State private var expense_searchText: String = ""
    @State private var expense_selectedCategory: String = "All"
    // DONT DELETE THIS
    private var expense_categories: [String] { ["All"] + categories }

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
            ScrollView{
                VStack(spacing: 16) {
                    expensesTab
                }
            }
        }
    }
                
//    private var overviewTab: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Expense Breakdown")
//                .font(.headline)
//                .padding(.horizontal)
//
//            GeometryReader { geo in
//                let width = geo.size.width
//                let ratio = totalBudget > 0 ? CGFloat(min(totalSpent / totalBudget, 1)) : 0
//                let filled = width * ratio
//                ZStack(alignment: .leading) {
//                    Capsule().fill(Color.gray.opacity(0.12)).frame(height: 20)
//                    Capsule().fill(Color.red).frame(width: filled, height: 20)
//                }
//            }
//            .frame(height: 20)
//            .frame(maxWidth: .infinity)
//            .padding(.horizontal)
//
//
//
//            Text("Budget: $\(Int(totalBudget)) | Spent: $\(Int(totalSpent)) | Saved: $\(Int(max(totalBudget - totalSpent, 0)))")
//                .font(.caption)
//                .padding(.horizontal)
//                .foregroundColor(.gray)
//
//            VStack(alignment: .leading, spacing: 10) {
//                HStack {
//                    Text("Goals:")
//                        .font(.title3).bold()
//                    Spacer()
//                    Button("Add New") { showAddGoal = true }
//                        .foregroundColor(.yellow)
//                }
//
//                ForEach(goals) { goal in
//                    NavigationLink {
//                        GoalDetailView(goal: goal)
//                    } label: {
//                        goalCard(goal)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//            .padding(.horizontal)
//        }
//    }

    private var expensesTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            

            HStack {
                
                
                DatePicker("Start", selection: $dateRangeStart, displayedComponents: .date)
                    .padding(-10)
                    .scaleEffect(0.8)
                    .labelsHidden()
                    .onChange(of: dateRangeStart) { newStart in
                                    if newStart > dateRangeEnd {
                                        dateRangeEnd = newStart
                                    }
                                }
                Text("to")
                DatePicker("End", selection: $dateRangeEnd, displayedComponents: .date)
                    .padding(-10)
                
                    .scaleEffect(0.8)
                    .labelsHidden()
                    .onChange(of: dateRangeEnd) { newEnd in
                                    if newEnd < dateRangeStart {
                                        dateRangeStart = newEnd
                                    }
                                }

                
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(expense_categories, id: \.self) { cat in
                        Button {
                            expense_selectedCategory = cat
                        } label: {
                            Text(cat.capitalized)
                                .font(.caption)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(expense_selectedCategory == cat ? Color.yellow : Color.gray.opacity(0.2))
                                .foregroundColor(expense_selectedCategory == cat ? .black : .primary)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }

            let results = expensesBetween(dateRangeStart, dateRangeEnd)
                .filter { item in
                    (expense_selectedCategory == "All" ||
                     item.category.lowercased() == expense_selectedCategory.lowercased())
                    && (expense_searchText.isEmpty ||
                        item.name.lowercased().contains(expense_searchText.lowercased()))
                }


            if results.isEmpty {
                ContentUnavailableView("No Expenses Found", systemImage: "dollarsign.circle")
            } else {
                VStack(spacing: 10) {
                    ForEach(results, id: \.self) { item in
                        NavigationLink {
                            ExpenseDetailView(expense: item)
                        } label: {
                            HStack {
                                Image(systemName: item.category.sFSymbol)
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .bold()
                                        .foregroundColor(.white)
                                    Text(Date(timeIntervalSince1970: item.date), style: .date)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Text("$\(item.amount, specifier: "%.2f")")
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(item.category.categoryColor)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .toolbar{
            ToolbarItem{
                Button {
                    showAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
                .padding(.horizontal)
                
            }
        }
        .searchable(text: $expense_searchText, placement: .navigationBarDrawer)
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView()
        }
        .navigationTitle("Expenses")
        
        
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
