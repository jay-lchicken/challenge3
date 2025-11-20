import SwiftUI
import SwiftData
import FoundationModels
import MarkdownUI

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
                Markdown(feedback)
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
                        .foregroundColor(.yellow)
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
                foundationVM.query = """
                “I want you to tell me how I am doing so far and remind me to stick to my budget for the different categories and give me a reminder to add expenses. All in one paragraph. Also give necessary feedback such as too much spending on food for the week using tools to get data
                """
                
                Task { await foundationVM.generateResponse() }

                let now = Date()
                for expense in expenses where expense.category.lowercased() == "subscriptions" && (expense.isRecurring ?? false) {
                    
                    let lastDate = expense.date > 0 ? Date(timeIntervalSince1970: expense.date) : Date.distantPast
                    
                    var shouldAdd = false
                    switch expense.frequency ?? .monthly {
                    case .daily:
                        shouldAdd = !Calendar.current.isDateInToday(lastDate)
                    case .weekly:
                        shouldAdd = now.timeIntervalSince(lastDate) >= 7 * 24 * 3600
                    case .monthly:
                        shouldAdd = now.timeIntervalSince(lastDate) >= 30 * 24 * 3600
                    case .yearly:
                        shouldAdd = now.timeIntervalSince(lastDate) >= 365 * 24 * 3600
                    }

                    if shouldAdd {
                        let newExpense = ExpenseItem(
                            name: expense.name,
                            amount: expense.amount,
                            date: now.timeIntervalSince1970,
                            category: "Subscriptions",
                            isRecurring: expense.isRecurring,
                            frequency: expense.frequency
                        )
                        modelContext.insert(newExpense)
                        
                        expense.date = now.timeIntervalSince1970
                    }
                }
            }

        }
    }
}
