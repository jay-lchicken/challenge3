//
//  HomeView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//
 
//
//  HomeView.swift
//  challenge3
//

import SwiftUI
import SwiftData
import FoundationModels

struct HomeView: View {
    @State private var foundationVM = FoundationModelViewModel()
    
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [ExpenseItem]
    @AppStorage("budget") private var budget: Double = 1500

    @State private var selectedExpense: ExpenseItem? = nil

    private var todaySpent: Double {
        let start = Calendar.current.startOfDay(for: Date())
        return expenses
            .filter { Date(timeIntervalSince1970: $0.date) >= start }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var todaySaved: Double { max(budget - todaySpent, 0) }

    @ViewBuilder
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let feedback = foundationVM.generatedResponse {
                Text(feedback)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ProgressView()
            }
        }
        .padding()
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: HStack(spacing: 10) {
                    Image(systemName: "dollarsign.circle")
                        .font(.title3)
                        .foregroundColor(.white)
                    Text("Today's Spending")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    HStack {
                        Text("Total: $\(todaySpent, specifier: "%.2f")")
                            .fontWeight(.bold)
                    }
                }) {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(expenses, id: \.self) { item in
                                NavigationLink(destination: ExpenseDetailView(expense: item)) {
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
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        Spacer()
                                        
                                        Text("$\(item.amount, specifier: "%.2f")")
                                            .bold()
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(item.category.categoryColor.opacity(0.97))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 8)
                    }


                }
                
                Section(header: HStack(spacing: 10) {
                    Image(systemName: "bubble.left.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                    Text("Feedback")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }) {
                    feedbackSection
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle").imageScale(.large)
                    }
                }
            }
            .onAppear {
                foundationVM.setModelContext(modelContext)
                foundationVM.query = "give me an analysis and feedback of my today's spendings"
                
                Task {
                    await foundationVM.generateResponse()
                }
            }
        }
    }
}

