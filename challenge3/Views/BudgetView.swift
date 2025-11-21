//
//  BudgetViw.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/21/25.
//

import SwiftUI
import SwiftData
struct BudgetView: View {
    @State private var showEditBudgets = false
    @Environment(\.modelContext) var modelContext
    @Query(sort: \ExpenseItem.date, order: .reverse) var expenses: [ExpenseItem]
    @Query(sort: \GoalItem.dateCreated, order: .reverse) var goals: [GoalItem]
    @Query(sort: \BudgetItem.category, order: .forward) var budgets: [BudgetItem]
    @State private var selectedTimeRange = "Monthly"
   

    let timeRanges = ["Daily", "Monthly", "Yearly"]

    let categories = CategoryOptionsModel().category
    private func capForCategory(_ cat: String) -> Double {
        budgets.first(where: { $0.category.lowercased() == cat.lowercased() })?.cap ?? 200
    }

    private func spent(for category: String) -> Double {
        filteredExpenses.filter { $0.category.lowercased() == category.lowercased() }
                .reduce(0) { $0 + $1.amount }
    }
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
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 12) {
                    ForEach(categories, id: \.self) { cat in
                        categoryBudgetCard(cat)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Budgets")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit Budget") {
                        showEditBudgets = true
                        
                    }
                }
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
        
    }

}

#Preview {
    BudgetView()
}
