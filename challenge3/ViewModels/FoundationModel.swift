//
//  FoundationModel.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//
//
//import Foundation
//import FoundationModels
//import Combine
//import SwiftData
//
//@Generable
//struct ModelResponse{
//    @Guide(description: "The main response you have to the user's query")
//    var response: String
//}
//
//struct GetExpenseTool: Tool {
//    var modelContext: ModelContext? = nil
//    var modelContainer: ModelContainer? = nil
//
//    @MainActor
//    init(inMemory: Bool) {
//        do {
//            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
//            let container = try ModelContainer(for: ExpenseItem.self, configurations: configuration)
//            modelContainer = container
//            modelContext = container.mainContext
//            modelContext?.autosaveEnabled = true
//
//        } catch(let error) {
//            print(error)
//            print(error.localizedDescription)
//        }
//    }
//    func save() {
//        guard let modelContext = modelContext else {
//            return
//        }
//        do {
//            try modelContext.save()
//        } catch (let error) {
//            print(error)
//        }
//    }
//    let name = "getExpense"
//    let description = "To collect expenses from expense tracker and get a return on the expenses the user has spent on"
//
//    @Generable
//    struct Arguments {
//        @Guide(description: "Number of days to look back")
//        var daysToLookBack: Int
//
//    }
//
//    func call(arguments: Arguments) async throws -> [String] {
//        return await MainActor.run {
//            guard let modelContext = modelContext else {
//                return []
//            }
//
//            let calendar = Calendar.current
//            let startOfToday = calendar.startOfDay(for: Date())
//            let days = max(arguments.daysToLookBack, 1)
//            let lowerDate = calendar.date(byAdding: .day, value: -(days - 1), to: startOfToday) ?? startOfToday
//            let upperDate = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? startOfToday.addingTimeInterval(86_400)
//
//            let lowerBound = lowerDate.timeIntervalSince1970
//            let upperBound = upperDate.timeIntervalSince1970
//
//            let predicate = #Predicate<ExpenseItem> { item in
//                item.date >= lowerBound && item.date < upperBound
//            }
//
//            let expenseDescriptor = FetchDescriptor<ExpenseItem>(
//                predicate: predicate,
//                sortBy: [SortDescriptor(\ExpenseItem.date, order: .reverse)]
//            )
//
//            do {
//                let expenses = try modelContext.fetch(expenseDescriptor)
//                let formattedExpenses = expenses.map { expense in
//                    "Name: \(expense.name), Amount: \(expense.amount), Category: \(expense.category), Date: \(Date(timeIntervalSince1970: expense.date).formatted())"
//                }
//                print(formattedExpenses)
//                return formattedExpenses
//
//            } catch(let error) {
//                print(error)
//            }
//            return []
//        }
//    }
//}
//
//struct AddExpenseTool: Tool {
//    var modelContext: ModelContext? = nil
//    var modelContainer: ModelContainer? = nil
//
//    @MainActor
//    init(inMemory: Bool) {
//        do {
//            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
//            let container = try ModelContainer(for: ExpenseItem.self, configurations: configuration)
//            modelContainer = container
//            modelContext = container.mainContext
//            modelContext?.autosaveEnabled = true
//
//        } catch(let error) {
//            print(error)
//            print(error.localizedDescription)
//        }
//    }
//    func save() {
//        guard let modelContext = modelContext else {
//            return
//        }
//        do {
//            try modelContext.save()
//        } catch (let error) {
//            print(error)
//        }
//    }
//    let name = "addExpense"
//    let description = "Add an expense to your expense tracker and get a return bool on whether it was successful"
//
//    @Generable
//    struct Arguments {
//        @Guide(description: "The name of the expense")
//        var name: String
//        @Guide(description: "The amount of the expense")
//        var amount: Double
//        @Guide(description: "The category of the expense")
//        var category: String
//
//    }
//    func queryExpenses() -> [ExpenseItem] {
//        guard let modelContext = modelContext else {
//            return []
//        }
//        let expenseDescriptor = FetchDescriptor<ExpenseItem>()
//        do {
//            let expenses = try modelContext.fetch(expenseDescriptor)
//            return expenses
//        } catch(let error) {
//            print(error)
//        }
//        return []
//    }
//
//    func call(arguments: Arguments) async throws -> String {
//        return await MainActor.run {
//            guard let modelContext = modelContext else {
//                print("ERROR")
//                return "false"
//            }
//
//            let newExpense = ExpenseItem(
//                name: arguments.name,
//                amount: arguments.amount,
//                date: Date().timeIntervalSince1970,
//                category: arguments.category
//            )
//            modelContext.insert(newExpense)
//            save()
//            print("SUCCESS!!!")
//            print(queryExpenses())
//
//            return "\(arguments.amount)"
//
//        }
//    }
//}
//struct GetIncomeTool: Tool {
//
//
//
//    let name = "GetIncome"
//    let description = "Get the total income of the user"
//
//    @Generable
//    struct Arguments {
//
//
//    }
//
//
//    func call(arguments: Arguments) async throws -> Int {
//        return await MainActor.run {
//            if let income = UserDefaults.standard.value(forKey: "income") as? Int{
//
//                return income
//            }
//            return -1
//
//
//        }
//    }
//}
//struct GetBudgetsTool: Tool {
//    var modelContext: ModelContext? = nil
//    var modelContainer: ModelContainer? = nil
//
//    @MainActor
//    init(inMemory: Bool) {
//        do {
//            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
//            let container = try ModelContainer(for: BudgetItem.self, configurations: configuration)
//            modelContainer = container
//            modelContext = container.mainContext
//            modelContext?.autosaveEnabled = true
//
//        } catch(let error) {
//            print(error)
//            print(error.localizedDescription)
//        }
//    }
//
//    let name = "getBudgets"
//    let description = "Get a list of all budgets the user has set"
//
//    @Generable
//    struct Arguments {
//
//
//    }
//
//    func call(arguments: Arguments) async throws -> [String] {
//        return await MainActor.run {
//            guard let modelContext = modelContext else {
//                return []
//            }
//
//
//            let budgetsDescriptor = FetchDescriptor<BudgetItem>()
//
//            do {
//                let budgets = try modelContext.fetch(budgetsDescriptor)
//                let formattedBudgets = budgets.map { budget in
//                    "Budget Category: \(budget.category), Budget Cap: \(budget.cap)"
//                }
//                print(formattedBudgets)
//                return formattedBudgets
//
//            } catch(let error) {
//                print(error)
//            }
//            return []
//        }
//    }
//}
//struct GetGoalsTool: Tool {
//    var modelContext: ModelContext? = nil
//    var modelContainer: ModelContainer? = nil
//
//    @MainActor
//    init(inMemory: Bool) {
//        do {
//            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
//            let container = try ModelContainer(for: GoalItem.self, configurations: configuration)
//            modelContainer = container
//            modelContext = container.mainContext
//            modelContext?.autosaveEnabled = true
//
//        } catch(let error) {
//            print(error)
//            print(error.localizedDescription)
//        }
//    }
//
//    let name = "getGoals"
//    let description = "Get all goals the user has set"
//
//    @Generable
//    struct Arguments {
//
//
//    }
//
//    func call(arguments: Arguments) async throws -> [String] {
//        return await MainActor.run {
//            guard let modelContext = modelContext else {
//                return []
//            }
//
//
//            let goalDescriptor = FetchDescriptor<GoalItem>()
//
//            do {
//                let goals = try modelContext.fetch(goalDescriptor)
//                let formattedGoals = goals.map { goals in
//                    "Title: \(goals.title), Current: \(goals.current), Target: \(goals.target)"
//                }
//                print(formattedGoals)
//                return formattedGoals
//
//            } catch(let error) {
//                print(error)
//            }
//            return []
//        }
//    }
//}
//
//@Observable
//class FoundationModelViewModel{
//
//
//
//    var isGenerating: Bool = false
//    var query: String = ""
//    var generatedResponse: String? = nil
//    var showAlert = false
//    var alertMessage: String = ""
//    var chatHistory: [ChatMessage] = []
//    let instructions = """
//                Role
//
//                You are “Bro”, a friendly and professional personal finance assistant.
//                You communicate only in English.
//
//                ⸻
//
//                Objectives
//
//                Your main goal is to help the user manage their personal finances effectively.
//                That includes budgeting, tracking expenses, saving, managing goals, and maintaining healthy cash flow.
//
//                You should:
//                    • Give clear, accurate, and practical financial guidance.
//                    • Track expenses automatically whenever the user mentions or implies a purchase or payment.
//                    • Review spending history to give personalized insights and feedback.
//                    • Help users plan and achieve long-term financial goals using their income and spending habits.
//                    • Keep your advice short, friendly, and actionable — like a knowledgeable friend helping them stay on top of money matters.
//
//                ⸻
//
//                Tool Usage
//
//                AddExpenseTool
//                Use this tool whenever:
//                    • The user mentions or implies a new expense.
//                    • An expense needs to be logged or categorized.
//
//                Before using it, make sure you have:
//                    • Name: what the expense is for
//                    • Amount: numeric value
//                    • Category: \(CategoryOptionsModel().category) (PLEASE CHOOSE FROM THESE CATEGORIES ONLY)
//
//                If any details are missing:
//                    • Infer them logically from context (e.g., “$4 coffee” → name: coffee, category: beverage;
//                      “I spent $300 at IKEA” → name: IKEA, category: shopping).
//                    • If it’s too vague, ask a short follow-up question for clarification.
//
//                After adding an expense:
//                    • Acknowledge it naturally and, if useful, give a quick financial insight or encouragement.
//
//                ⸻
//
//                GetExpenseTool
//                Use this tool whenever:
//                    • The user asks to review, analyze, or get feedback on past expenses.
//                    • The user asks questions like:
//                        – “What did I spend on today?”
//                        – “How much did I spend last week?”
//                        – “Show my transport expenses.”
//                        – “Am I spending too much on food?”
//
//                When you retrieve expenses:
//                    • Summarize the data clearly and briefly.
//                    • Point out patterns or trends (e.g., “You’ve spent more on dining out this week than last.”).
//                    • Offer constructive advice or small adjustments to improve financial habits.
//
//                ⸻
//
//                Goal Planning & Prediction (NEW)
//
//                Bro also helps users achieve financial goals (e.g., buying a car, saving for a trip, emergency fund).
//                The user may set:
//                    • Goal name
//                    • Target amount
//                    • Income per year
//                    • Preferred completion date (optional)
//                    • Frequency of contribution (optional)
//
//                Bro should:
//                    • Estimate how long it will take to reach each goal based on:
//                        – user’s income
//                        – current spending habits
//                        – historical savings (income − expenses)
//                        – contribution frequency (if given)
//                    • Suggest a reasonable monthly or weekly contribution amount.
//                    • If their target completion date is unrealistic:
//                        – Explain why
//                        – Suggest an achievable timeline or an adjusted contribution rate
//                    • If they don’t give a completion date:
//                        – Predict one automatically based on their typical monthly savings
//
//                Bro should always give:
//                    • A predicted completion date
//                    • A recommended contribution strategy
//                    • Tips to help them reach the goal faster (e.g., “If you cut dining out by 12%, you can bring your goal forward by 2 months.”)
//
//                ⸻
//
//                Personalized Financial Insights (NEW)
//
//                Using income, goals, and spending patterns, Bro should give:
//                    • High-level feedback on whether the user’s spending supports or delays their goals
//                    • Warnings if their savings rate is too low for what they want to achieve
//                    • Gentle suggestions for improving financial habits, such as:
//                        – reducing high-impact categories
//                        – restructuring contributions
//                        – spreading big expenses more evenly
//                        – celebrating positive habits (“Nice! You saved more this week than last.”)
//
//                ⸻
//
//                Style
//                    • Be concise, encouraging, and easy to understand.
//                    • Use plain language and concrete examples.
//                    • Avoid financial jargon — if you must use a term, explain it simply.
//                    • Sound friendly and supportive, like a financially savvy buddy who’s got the user’s back.
//
//                ⸻
//
//                Safety and Scope
//                    • Stick to personal finance — budgeting, spending, saving, and debt management.
//                    • Politely steer the user back if they go off-topic.
//                    • Avoid legal, tax, or investment advice, except for broad educational guidance.
//
//                """
//    init() {
//
//    }
//
//
//
//    @ObservationIgnored lazy var session = LanguageModelSession(tools: [AddExpenseTool(inMemory: false), GetExpenseTool(inMemory: false), GetIncomeTool(), GetGoalsTool(inMemory: false), GetBudgetsTool(inMemory: false)], instructions: instructions)
//
//    func generateResponse() async{
//        isGenerating = true
//        let stream = session.streamResponse(to: query)
//        query = ""
//        do{
//            for try await partial in stream {
//                generatedResponse = partial.content
//            }
//            print("Finished generating")
//        }catch{
//            alertMessage = error.localizedDescription
//            showAlert.toggle()
//            print("\(error.localizedDescription)")
//        }
//
////        chatHistory.append(ChatMessage(role: .user, content: query, isPartial: false))
////        chatHistory.append(ChatMessage(role: .assistant, content: generatedResponse?.response ?? "", isPartial: true))
//
//    }
//}

import Foundation
import FoundationModels
import SwiftData

@Generable
struct ModelResponse {
    @Guide(description: "The main response you have to the user's query")
    var response: String
}


struct AddExpenseTool: Tool {
    var modelContext: ModelContext? = nil
   
    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
        self.modelContext?.autosaveEnabled = true
        print("[AddExpenseTool] initialized with shared container")
    }

    func save() {
        guard let context = modelContext else { return }
        do { try context.save() } catch { print("[AddExpenseTool] save error:", error.localizedDescription) }
    }

    let name = "addExpense"
    let description = "Add an expense to your tracker and return confirmation"

    @Generable
    struct Arguments {
        @Guide(description: "Name of the expense") var name: String
        @Guide(description: "Amount spent") var amount: Double
        @Guide(description: "Category of the expense") var category: String
    }

    func call(arguments: Arguments) async throws -> String {
        print("[AddExpenseTool] call args:", arguments)
        return await MainActor.run {
            guard let context = modelContext else {
                print("[AddExpenseTool] ERROR - modelContext nil")
                return "Error: Model context unavailable."
            }

            
            if arguments.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                print("[AddExpenseTool] invalid name")
                return "Please provide a name for the expense (what did you buy?)."
            }
            if arguments.amount <= 0 {
                print("[AddExpenseTool] invalid amount:", arguments.amount)
                return "Please provide a valid positive amount for the expense."
            }

            let validCategories = CategoryOptionsModel().category
            if !validCategories.contains(arguments.category) {
                print("[AddExpenseTool] invalid category:", arguments.category, "allowed:", validCategories)
                return "Invalid category. Please choose one of: \(validCategories.joined(separator: ", "))."
            }

            
            let expense = ExpenseItem(
                name: arguments.name.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: arguments.amount,
                date: Date().timeIntervalSince1970,
                category: arguments.category
            )

            context.insert(expense)
            save()
            print("[AddExpenseTool] inserted expense:", expense.name, expense.amount, expense.category)

            
            if let budgets = try? context.fetch(FetchDescriptor<BudgetItem>()),
               let budget = budgets.first(where: { $0.category == arguments.category }),
               arguments.amount > budget.cap {
                print("[AddExpenseTool] budget exceeded for category:", budget.category, "cap:", budget.cap)
                return "Expense added: \(arguments.name) — $\(arguments.amount). Warning: this single expense exceeds your budget cap (\(budget.cap)) for \(arguments.category)."
            }

            return "Expense added: \(arguments.name) — $\(String(format: "%.2f", arguments.amount))."
        }
    }
}



struct GetExpenseTool: Tool {
    var modelContext: ModelContext? = nil

    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
        self.modelContext?.autosaveEnabled = true
        print("[GetExpenseTool] initialized with shared container")
    }

    let name = "getExpense"
    let description = "Retrieve and summarize expenses over a given number of days."

    @Generable
    struct Arguments {
        @Guide(description: "Number of days to look back (1 = today)") var daysToLookBack: Int
    }

    func call(arguments: Arguments) async throws -> [String] {
        print("[GetExpenseTool] call daysToLookBack:", arguments.daysToLookBack)
        return await MainActor.run {
            guard let context = modelContext else {
                print("[GetExpenseTool] ERROR - modelContext nil")
                return ["Error: Model context unavailable."]
            }

            let days = max(arguments.daysToLookBack, 1)
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            let lower = calendar.date(byAdding: .day, value: -(days - 1), to: startOfToday)!
            let upper = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

            let predicate = #Predicate<ExpenseItem> {
                $0.date >= lower.timeIntervalSince1970 && $0.date < upper.timeIntervalSince1970
            }

            let descriptor = FetchDescriptor<ExpenseItem>(predicate: predicate, sortBy: [SortDescriptor(\.date, order: .reverse)])

            do {
                let expenses = try context.fetch(descriptor)
                print("[GetExpenseTool] fetched \(expenses.count) expenses")
                if expenses.isEmpty { return ["No expenses found in that period."] }

                var lines: [String] = []
                var total: Double = 0
                var byCategory: [String: Double] = [:]
                for e in expenses {
                    lines.append("Name: \(e.name), Amount: \(String(format: "%.2f", e.amount)), Category: \(e.category), Date: \(Date(timeIntervalSince1970: e.date).formatted())")
                    total += e.amount
                    byCategory[e.category, default: 0.0] += e.amount
                }

               
                let topCats = byCategory.sorted { $0.value > $1.value }.prefix(3)
                    .map { "\($0.key): $\((String(format: "%.2f", $0.value)))" }
                    .joined(separator: ", ")

                let summary = "Found \(expenses.count) expense(s) — total $\(String(format: "%.2f", total)). Top categories: \(topCats)"
                lines.insert(summary, at: 0)
                return lines
            } catch {
                print("[GetExpenseTool] fetch error:", error.localizedDescription)
                return ["Error fetching expenses: \(error.localizedDescription)"]
            }
        }
    }
}



struct GetBudgetsTool: Tool {
    var modelContext: ModelContext? = nil

    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
        self.modelContext?.autosaveEnabled = true
        print("[GetBudgetsTool] initialized with shared container")
    }

    let name = "getBudgets"
    let description = "Retrieve all budgets and their caps."

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> [String] {
        print("[GetBudgetsTool] call")
        return await MainActor.run {
            guard let context = modelContext else {
                print("[GetBudgetsTool] ERROR - modelContext nil")
                return ["Error: Model context unavailable."]
            }

            do {
                let budgets = try context.fetch(FetchDescriptor<BudgetItem>())
                print("[GetBudgetsTool] fetched \(budgets.count) budgets")
                if budgets.isEmpty { return ["No budgets set."] }
                return budgets.map { "Category: \($0.category), Cap: \($0.cap)" }
            } catch {
                print("[GetBudgetsTool] fetch error:", error.localizedDescription)
                return ["Error fetching budgets: \(error.localizedDescription)"]
            }
        }
    }
}



struct GetGoalsTool: Tool {
    var modelContext: ModelContext? = nil

    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
        self.modelContext?.autosaveEnabled = true
        print("[GetGoalsTool] initialized with shared container")
    }

    let name = "getGoals"
    let description = "Retrieve all goals and show progress."

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> [String] {
        print("[GetGoalsTool] call")
        return await MainActor.run {
            guard let context = modelContext else {
                print("[GetGoalsTool] ERROR - modelContext nil")
                return ["Error: Model context unavailable."]
            }

            do {
                let goals = try context.fetch(FetchDescriptor<GoalItem>())
                print("[GetGoalsTool] fetched \(goals.count) goals")
                if goals.isEmpty { return ["No goals set."] }
                return goals.map { goal in
                    let pct = goal.target > 0 ? (goal.current / goal.target * 100.0) : 0.0
                    return "Title: \(goal.title), Current: \(goal.current), Target: \(goal.target) — \(String(format: "%.1f", pct))% done"
                }
            } catch {
                print("[GetGoalsTool] fetch error:", error.localizedDescription)
                return ["Error fetching goals: \(error.localizedDescription)"]
            }
        }
    }
}



struct GetIncomeTool: Tool {
    let name = "getIncome"
    let description = "Get user's total income"

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> Int {
        print("[GetIncomeTool] call")
        return await MainActor.run {
            let income = UserDefaults.standard.integer(forKey: "income")
            print("[GetIncomeTool] income:", income)
          
            return income == 0 ? -1 : income
        }
    }
}



@Observable
class FoundationModelViewModel {
    var query: String = ""
    var generatedResponse: String? = nil
    var isGenerating: Bool = false
    var showAlert = false
    var alertMessage: String = ""

    // ----- Instructions (kept as you provided, minor formatting) -----
    let instructions = """
                       Role
                       
                       You are “Bro”, a friendly, professional personal finance assistant. Communicate clearly in English and act as a knowledgeable, supportive buddy.
                       
                       Core responsibilities
                       - Track expenses, budgets, goals, and income.
                       - Use the provided tools whenever you need to read or write persistent data.
                         Tools available: addExpense, getExpense, getBudgets, getGoals, getIncome.
                       - NEVER assume missing values. If a user message lacks required details (e.g., amount, category, goal target), ask a single, concise clarifying question before performing any write operation.
                       - Validate all inputs you will write: amounts must be > 0, categories must be from the approved list (CategoryOptionsModel().category), names should be non-empty.
                       - When adding an expense, confirm the entered values back to the user and mention immediate budget/goal impact if applicable.
                       
                       Tool usage rules
                       - AddExpenseTool:
                         • Use only when you have: name, amount (numeric > 0), category (one of CategoryOptionsModel().category).
                         • If any detail is missing or ambiguous, ask the user to clarify first. Examples of clarifying prompts:
                             - "How much was the gelato (amount)?"
                             - "Which category should I use for this purchase? (e.g., food, transport)"
                         • After adding, mention if the expense caused an over-budget condition or materially affected any goal progress.
                       
                       - GetExpenseTool:
                         • Use to fetch expenses for a date range (days to look back).
                         • Summarize count, total spent, and top categories; then list individual items if needed.
                         • Example: "You had 4 expenses totaling $82. Top category: Dining — $45."
                       
                       - GetBudgetsTool:
                         • Use to fetch all budgets. When giving feedback, compare spending-to-budget for the current period and warn when near/over cap.
                       
                       - GetGoalsTool:
                         • Use to fetch goals and progress. When advising, compute projected completion based on typical monthly savings (income minus monthly average expenses).
                       
                       - GetIncomeTool:
                         • Use to fetch stored income (UserDefaults integer). If income is not set, ask the user for their annual income before making goal projections.
                       
                       Insights & advice
                       - Always reference user data when making claims (e.g., "Based on your last 30 days of spending, you spend ~$X/month on groceries.").
                       - Offer 1-2 actionable suggestions (e.g., "Try cutting dining out by 10% to save $Y/month") and a realistic contribution recommendation for goals.
                       - Use plain language; avoid technical finance jargon. If using a term, briefly define it.
                       
                       Safety & scope
                       - Do NOT provide legal, tax, or specific investment advice.
                       - If user asks for such, respond with a brief refusal and suggest seeking a qualified professional.
                       
                       Behavior summary
                       - Always try to read relevant data with the tools before answering.
                       - Never write data unless validated and explicitly requested.
                       - Ask concise follow-ups when required.
                       - Keep responses short, supportive, and actionable.
                       """

   
    @ObservationIgnored
    var sharedContainer: ModelContainer

    @ObservationIgnored
    var session: LanguageModelSession
    
    var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    @MainActor
    init() {
        print("[ViewModel] creating shared ModelContainer")
        self.sharedContainer = try! ModelContainer(for: ExpenseItem.self, GoalItem.self, BudgetItem.self)
        
        print("[ViewModel] initializing LanguageModelSession with tools")
        self.session = LanguageModelSession(
            tools: [
                AddExpenseTool(modelContainer: sharedContainer),
                GetExpenseTool(modelContainer: sharedContainer),
                GetBudgetsTool(modelContainer: sharedContainer),
                GetGoalsTool(modelContainer: sharedContainer),
                GetIncomeTool()
            ],
            instructions: instructions
        )
    }


   
    @MainActor
    func generateResponse() async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            generatedResponse = "Please type a question or command."
            return
        }

        isGenerating = true
        let currentQuery = query
        let stream = session.streamResponse(to: currentQuery)
        
        query = ""
        do {
            for try await partial in stream {
                generatedResponse = partial.content
            }
            print("[ViewModel] finished generating response")
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
            print("[ViewModel] generateResponse error:", error.localizedDescription)
        }
        isGenerating = false
    }
}
