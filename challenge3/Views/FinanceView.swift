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

    @State private var selectedTab = "Overview"
    @State private var budget: Double = 1500
    @State private var selectedTimeRange = "Daily"
    @State private var showAddGoal = false

    let timeRanges = ["Daily", "Monthly", "Yearly"]

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

    private var categoryTotals: [(category: String, total: Double)] {
        let grouped = Dictionary(grouping: filteredExpenses, by: { $0.category })
        return grouped
            .map { (key, value) in
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
                    .font(.title2).bold()
                    .padding(.top)

                Picker("", selection: $selectedTab) {
                    Text("Overview").tag("Overview")
                    Text("Budget").tag("Budget")
                    Text("Expenses").tag("Expenses")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Picker("", selection: $selectedTimeRange) {
                            ForEach(timeRanges, id: \.self) { range in
                                Text(range)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)

                        if selectedTab == "Expenses" {
                            ExpenseView()
                        }

                        else if selectedTab == "Budget" {
                            categoryBudgetSection
                        }

                        else {
                            overviewSection
                        }
                        goalsSection
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView()
            }

        }
    }

    private var categoryBudgetSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Category Budgets")
                .font(.caption).bold()

            ForEach(["Food","Transport","Social Life","Payments","Shopping","Others"], id: \.self) { cat in
                VStack(alignment: .leading, spacing: 6) {
                    Text(cat).font(.subheadline)

                    GeometryReader { geo in
                        let width = geo.size.width
                        let spent = filteredExpenses
                            .filter { $0.category.lowercased() == cat.lowercased() }
                            .reduce(0) { $0 + $1.amount }

                        let budgetCap: CGFloat = 200
                        let ratio = min(CGFloat(spent) / budgetCap, 1)
                        let filled = width * ratio
                        let remain = width - filled

                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.gray.opacity(0.2)).frame(height: 18)
                            HStack(spacing: 0) {
                                Capsule().fill(Color.red).frame(width: filled, height: 18)
                                Capsule().fill(Color.green).frame(width: remain, height: 18)
                            }
                        }
                    }
                    .frame(height: 18)

                    Text("Spent: $\(Int(spentFor(cat)))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }

    private func spentFor(_ cat: String) -> Double {
        filteredExpenses.filter { $0.category.lowercased() == cat.lowercased() }
            .reduce(0) { $0 + $1.amount }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !categoryTotals.isEmpty {
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

            Text("Expense Breakdown").font(.caption)

            GeometryReader { geo in
                let width = geo.size.width
                let ratio = CGFloat(min(totalSpent / budget, 1))
                let filled = width * ratio
                let remain = width - filled

                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2)).frame(height: 20)
                    HStack(spacing: 0) {
                        Capsule().fill(Color.red).frame(width: filled, height: 20)
                        Capsule().fill(Color.green).frame(width: remain, height: 20)
                    }
                }
            }
            .frame(height: 20)

            Text("Budget: $\(Int(budget)) | Spent: $\(Int(totalSpent)) | Saved: $\(Int(remainingBudget))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Goals:")
                    .font(.title3).bold()
                Spacer()
                Button("Add New") { showAddGoal = true }
                    .padding(6)
                    .glassEffect(.clear.interactive(), in: .capsule)
            }

            VStack(spacing: 12) {
                ForEach(goals) { goal in
                    goalCard(goal)
                }
            }
        }
        .padding(.top)
    }

    private func goalCard(_ goal: GoalItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(goal.title) - \(Int(goal.current))/\(Int(goal.target))")
                    .font(.headline)

                Spacer()

                let pct = min(goal.current / goal.target, 1)
                Text("\(Int(pct * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            GeometryReader { geo in
                let width = geo.size.width
                let ratio = CGFloat(min(goal.current / goal.target, 1))
                let filled = width * ratio
                let remain = width - filled

                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2)).frame(height: 20)
                    HStack(spacing: 0) {
                        Capsule().fill(Color.green).frame(width: filled, height: 20)
                        Capsule().fill(Color.red.opacity(0.6)).frame(width: remain, height: 20)
                    }
                }
            }
            .frame(height: 20)
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    FinanceView()
        .modelContainer(for: [GoalItem.self, ExpenseItem.self], inMemory: true)
}
