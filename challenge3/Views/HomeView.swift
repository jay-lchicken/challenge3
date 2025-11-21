
import SwiftUI
import SwiftData
import FoundationModels
import MarkdownUI
import Charts
 
struct HomeView: View {
    @State private var foundationVM = FoundationModelViewModel()
    
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [ExpenseItem]
    let categories = CategoryOptionsModel().category
 
    @AppStorage("budget") private var budget: Double = 1500
    @State private var selectedExpense: ExpenseItem? = nil
 
    private var todaySpent: Double {
        let start = Calendar.current.startOfDay(for: Date())
        return expenses
            .filter { Date(timeIntervalSince1970: $0.date) >= start }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var todaySaved: Double { max(budget - todaySpent, 0) }
   
 
    private func expensesBetween(_ start: Date, _ end: Date) -> [ExpenseItem] {
        let s = Calendar.current.startOfDay(for: start)
        let e = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
        return expenses.filter { exp in
            let d = Date(timeIntervalSince1970: exp.date)
            return d >= s && d <= e
        }
    }
    private var filteredExpenses: [ExpenseItem] {
        let calendar = Calendar.current
        return expenses.filter { exp in
            let date = Date(timeIntervalSince1970: exp.date)
            return calendar.isDateInToday(date)
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
 
    
 
 
    private func spent(for category: String) -> Double {
        filteredExpenses.filter { $0.category.lowercased() == category.lowercased() }
                .reduce(0) { $0 + $1.amount }
    }
 
    @ViewBuilder
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let feedback = foundationVM.generatedResponse{
                if feedback == "null"{
                    ProgressView()
                }else{
                    Markdown(feedback)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                ProgressView()
            }
        }
    }
 
    var body: some View {
        NavigationStack {
            List {
                Section(header: HStack(spacing: 10) {
                    Image(systemName: "bubble.left.fill")
                    Text("Feedback")
                    Spacer()
                }) {
                    feedbackSection
                }
                Section(header: HStack(spacing: 10) {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Expenses")
                    Spacer()
                }) {
                    VStack{
                        if !categoryTotals.isEmpty {
                            VStack(spacing: 12) {
                                Chart(categoryTotals, id: \.category) { item in
                                    SectorMark(
                                        angle: .value("Amount", item.total),
                                        innerRadius: .ratio(0.55),
                                        angularInset: 1
                                    )
                                    .foregroundStyle(item.category.categoryColor)
                                }
                                .frame(width: 200, height: 200)
                                .padding(.leading, 12)
                                
                                VStack(alignment: .leading, spacing: 25) {
                                    ForEach(categoryTotals, id: \.category) { item in
                                        HStack(spacing: 8) {
                                            Image(systemName: item.category.sFSymbol)
                                                .foregroundColor(item.category.categoryColor)
                                                .frame(width: 27, alignment: .leading)
                                                .font(.headline)
                                            Text(item.category.capitalized)
                                                .font(.headline)
                                                .lineLimit(1)
                                            Spacer()
                                            Text("$\(Int(item.total))")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.trailing)
                            }
                        }
                    }
                }
//                Section(header: Text("Expenses today")){
//                    ForEach(expenses, id: \.self) { item in
//                        NavigationLink(destination: ExpenseDetailView(expense: item)) {
//                            HStack {
//                                Image(systemName: item.category.sFSymbol)
//                                    .font(.title2)
//
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(item.name)
//                                        .bold()
//                                }
//
//                                Spacer()
//
//                                Text("$\(item.amount, specifier: "%.2f")")
//                                    .bold()
//
//
//                            }
//                            .frame(maxWidth: .infinity)
//                            .cornerRadius(12)
//                        }
//                        .foregroundStyle(item.category.categoryColor)
//                    }
//
//                }
                
//                Section(header: HStack(spacing: 10) {
//                    Image(systemName: "dollarsign.circle")
//                        .font(.title3)
//                        .foregroundColor(.yellow)
//                    Text("Today's Spending")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                    Spacer()
//                    HStack {
//                        Text("Total: $\(todaySpent, specifier: "%.2f")")
//                            .fontWeight(.bold)
//                    }
//                }) {
//                    ScrollView {
//                        VStack(spacing: 12) {
//
//                        }
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 8)
//                    }
//                }
                
               
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
                
                if foundationVM.generatedResponse == nil {
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
            .onChange(of: expenses) {
                Task { await foundationVM.generateResponse() }
                
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
 
