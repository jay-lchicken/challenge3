//
//  ExpenseView.swift
//  challenge3
//
//  Created by Aletheus Ang on 14/11/25.
//

import SwiftUI
import SwiftData

struct ExpenseView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \ExpenseItem.date, order: .reverse) var expenses: [ExpenseItem]
    
    @State private var selectedExpense: ExpenseItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Expenses")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(expenses) { exp in
                        Button {
                            selectedExpense = exp
                        } label: {
                            expenseCard(exp)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .sheet(item: $selectedExpense) { exp in
            VStack(spacing: 20) {
                Text(exp.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 14) {
                    infoRow("Category", exp.category)
                    infoRow("Amount", "$\(String(format: "%.2f", exp.amount))")
                    infoRow("Date", formattedDate(exp.date))
                }
                .font(.title3)
                .padding(.horizontal)
                
                Spacer()
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    func expenseCard(_ exp: ExpenseItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text(exp.name)
                    .font(.headline)
                Spacer()
                Text("$\(String(format: "%.2f", exp.amount))")
                    .font(.headline)
            }
            
            HStack {
                Text(exp.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(formattedDate(exp.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
    
    func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title + ":")
            Spacer()
            Text(value)
        }
    }
    
    func formattedDate(_ time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ExpenseView()
        .modelContainer(for: ExpenseItem.self)
}
