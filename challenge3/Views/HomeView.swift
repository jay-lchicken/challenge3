//
//  HomeView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    // SWIFT DATA
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [ExpenseItem]
    @AppStorage("question") var query: String = ""

    @State private var selectedExpense: ExpenseItem? = nil
    @State private var showExpenseDetail = false

    var body: some View {
        NavigationStack {
            List {
                Section(header:
                    HStack(spacing: 10) {
                        Image(systemName: "questionmark.circle")
                            .font(.title3)
                        Text("Feedback")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .foregroundColor(.primary)
                ) {
                    FeedbackView()
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity)
                }
                
                Section(header:
                    HStack(spacing: 10) {
                        Image(systemName: "dollarsign.circle")
                            .font(.title3)
                        Text("Today's Spending")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .foregroundColor(.primary)
                ) {
                    HStack {
                        Text("Spent: $10")
                        Spacer()
                        Text("Saved: $500")
                    }
                    
                    ExpenseView()

                    ForEach(expenses, id: \.self) { item in
                        NavigationLink(
                            tag: item,
                            selection: $selectedExpense
                        ) {
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
            .listStyle(.insetGrouped)
            .navigationTitle("Home").font(.title2).bold()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                            .accessibilityLabel("Profile")
                    }
                }
            }
            .sheet(isPresented: $showExpenseDetail) {
                if let expense = selectedExpense {
                    NavigationStack {
                        ExpenseDetailView(expense: expense)
                    }
                }
            }
        }
    }
}

import FoundationModels
struct FeedbackView: View {
    @State var feedback: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Feedback").font(.headline)
                Text("Feedback blah blah blah...")
                    .font(.body)
            }
            .padding()
        }
        .task{
            let session = LanguageModelSession(instructions: 
            """
            
            """
            )
            let response = try? await session.respond(to: "AHEHEHEMEMEMM")
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: ExpenseItem.self)
}



#Preview {
    HomeView()
}

