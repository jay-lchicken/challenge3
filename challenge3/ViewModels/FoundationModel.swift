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

//import Foundation
//import FoundationModels
//import SwiftData
//
//@Generable
//struct ModelResponse {
//    @Guide(description: "The main response you have to the user's query")
//    var response: String
//}
//
//
//struct AddExpenseTool: Tool {
//    var modelContext: ModelContext? = nil
//    var modelContainer: ModelContainer? = nil
//    
//    @MainActor
//    init(inMemory: Bool = false) {
//        do {
//            let container = try ModelContainer(for: ExpenseItem.self)
//            modelContainer = container
//            modelContext = container.mainContext
//            modelContext?.autosaveEnabled = true
//        } catch {
//            print("Error initializing AddExpenseTool:", error.localizedDescription)
//        }
//    }
//    
//    func save() {
//        guard let context = modelContext else { return }
//        try? context.save()
//    }
//    
//    let name = "addExpense"
//    let description = "Add an expense to your tracker and return confirmation"
//    
//    @Generable
//    struct Arguments {
//        @Guide(description: "Name of the expense") var name: String
//        @Guide(description: "Amount spent") var amount: Double
//        @Guide(description: "Category of the expense") var category: String
//    }
//    
//    func call(arguments: Arguments) async throws -> String {
//        return await MainActor.run {
//            guard let context = modelContext else { return "Error: Model context unavailable." }
//            
//            // Validate
//            if arguments.amount <= 0 { return "Please provide a valid amount." }
//            let validCategories = CategoryOptionsModel().category
//            if !validCategories.contains(arguments.category) {
//                return "Invalid category. Use one of: \(validCategories.joined(separator: ", "))"
//            }
//            
//            let expense = ExpenseItem(name: arguments.name, amount: arguments.amount, category: arguments.category)
//            context.insert(expense)
//            save()
//            
//            // Budget check
//            if let budgets = try? context.fetch(FetchDescriptor<BudgetItem>()),
//               let budget = budgets.first(where: { $0.category == arguments.category }),
//               arguments.amount > budget.cap {
//                return "Expense added, but you exceeded your budget for \(arguments.category)."
//            }
//            
//            return "Expense added: \(arguments.name) - $\(arguments.amount)"
//        }
//    }
//}
//
//
//struct GetExpenseTool: Tool {
//    var modelContext: ModelContext? = nil
//    var modelContainer: ModelContainer? = nil
//    
//    @MainActor
//    init(inMemory: Bool = false) {
//        do {
//            let container = try ModelContainer(for: ExpenseItem.self)
//            modelContainer = container
//            modelContext = container.mainContext
//            modelContext?.autosaveEnabled = true
//        } catch {
//            print("Error initializing GetExpenseTool:", error.localizedDescription)
//        }
//    }
//    
//    let name = "getExpense"
//    let description = "Retrieve expenses over a given number of days"
//    
//    @Generable
//    struct Arguments {
//        @Guide(description: "Number of days to look back") var daysToLookBack: Int
//    }
//    
//    func call(arguments: Arguments) async throws -> [String] {
//        return await MainActor.run {
//            guard let context = modelContext else { return [] }
//            
//            let calendar = Calendar.current
//            let today = calendar.startOfDay(for: Date())
//            let lower = calendar.date(byAdding: .day, value: -(max(arguments.daysToLookBack, 1) - 1), to: today)!
//            let upper = calendar.date(byAdding: .day, value: 1, to: today)!
//            
//            let predicate = #Predicate<ExpenseItem> { $0.date >= lower.timeIntervalSince1970 && $0.date < upper.timeIntervalSince1970 }
//            let descriptor = FetchDescriptor<ExpenseItem>(predicate: predicate, sortBy: [SortDescriptor(\.date, order: .reverse)])
//            
//            if let expenses = try? context.fetch(descriptor) {
//                if expenses.isEmpty { return ["No expenses found."] }
//                return expenses.map { "Name: \($0.name), Amount: \($0.amount), Category: \($0.category), Date: \(Date(timeIntervalSince1970: $0.date).formatted())" }
//            }
//            return ["Error fetching expenses."]
//        }
//    }
//}
//
//
//struct GetBudgetsTool: Tool {
//    var modelContext: ModelContext? = nil
//    var modelContainer: ModelContainer? = nil
//    
//    @MainActor
//    init(inMemory: Bool = false) {
//        do {
//            let container = try ModelContainer(for: BudgetItem.self)
//            modelContainer = container
//            modelContext = container.mainContext
//            modelContext?.autosaveEnabled = true
//        } catch {
//            print("Error initializing GetBudgetsTool:", error.localizedDescription)
//        }
//    }
//    
//    let name = "getBudgets"
//    let description = "Retrieve all budgets"
//    
//    @Generable
//    struct Arguments {}
//    
//    func call(arguments: Arguments) async throws -> [String] {
//        return await MainActor.run {
//            guard let context = modelContext else { return [] }
//            if let budgets = try? context.fetch(FetchDescriptor<BudgetItem>()) {
//                if budgets.isEmpty { return ["No budgets set."] }
//                return budgets.map { "Category: \($0.category), Cap: \($0.cap)" }
//            }
//            return ["Error fetching budgets."]
//        }
//    }
//}
//
//
//struct GetGoalsTool: Tool {
//    var modelContext: ModelContext? = nil
//    var modelContainer: ModelContainer? = nil
//    
//    @MainActor
//    init(inMemory: Bool = false) {
//        do {
//            let container = try ModelContainer(for: GoalItem.self)
//            modelContainer = container
//            modelContext = container.mainContext
//            modelContext?.autosaveEnabled = true
//        } catch {
//            print("Error initializing GetGoalsTool:", error.localizedDescription)
//        }
//    }
//    
//    let name = "getGoals"
//    let description = "Retrieve all user goals"
//    
//    @Generable
//    struct Arguments {}
//    
//    func call(arguments: Arguments) async throws -> [String] {
//        return await MainActor.run {
//            guard let context = modelContext else { return [] }
//            if let goals = try? context.fetch(FetchDescriptor<GoalItem>()) {
//                if goals.isEmpty { return ["No goals set."] }
//                return goals.map { "Title: \($0.title), Current: \($0.current), Target: \($0.target)" }
//            }
//            return ["Error fetching goals."]
//        }
//    }
//}
//
//
//struct GetIncomeTool: Tool {
//    let name = "getIncome"
//    let description = "Get user's total income"
//    
//    @Generable
//    struct Arguments {}
//    
//    func call(arguments: Arguments) async throws -> Int {
//        return await MainActor.run {
//            if let income = UserDefaults.standard.value(forKey: "income") as? Int {
//                return income
//            }
//            return -1
//        }
//    }
//}
//
//
//@Observable
//class FoundationModelViewModel {
//    var query: String = ""
//    var generatedResponse: String? = nil
//    var isGenerating: Bool = false
//    var showAlert = false
//    var alertMessage: String = ""
//    
//    let instructions = """
//               Role
//               You are “Bro,” a friendly, professional, and intelligent personal finance assistant.
//               You communicate clearly in English and act as a knowledgeable buddy helping users manage money effectively.
//
//               Objectives
//               Your primary goal is to help the user:
//
//               Track and manage expenses.
//
//               Set and monitor budgets.
//
//               Plan and achieve financial goals.
//
//               Maintain healthy cash flow.
//
//               You must:
//
//               Give concise, practical, and actionable guidance.
//
//               Always reference user data: expenses, budgets, goals, and income.
//
//               Never assume missing information. If details are incomplete, ask a clarifying question before taking action.
//
//               Provide feedback based on patterns or trends in the user’s financial data.
//
//               Keep explanations friendly, supportive, and easy to understand.
//
//               Tool Usage
//
//               AddExpenseTool
//
//               Use whenever the user mentions or implies a new expense.
//
//               Required details:
//
//               Name: what the expense is for
//
//               Amount: numeric value
//
//               Category: choose from \(CategoryOptionsModel().category)
//
//               If any detail is missing, ask the user before logging.
//
//               After adding an expense, summarize the impact on their budgets or goals if relevant.
//
//               GetExpenseTool
//
//               Use when the user wants to review or analyze past expenses.
//
//               Summarize trends and highlight overspending or areas to save.
//
//               Example queries:
//
//               “What did I spend today?”
//
//               “How much did I spend on groceries last week?”
//
//               “Am I overspending on entertainment?”
//
//               GetBudgetsTool
//
//               Use to retrieve budget data and provide insights.
//
//               Compare spending against budget caps and warn when overspending.
//
//               GetGoalsTool
//
//               Use to track progress toward goals.
//
//               Predict completion dates, suggest contribution rates, and provide actionable advice.
//
//               GetIncomeTool
//
//               Use to determine the user’s income for calculations related to budgets, expenses, and goals.
//
//               Goal Planning & Prediction
//
//               Calculate time to reach goals based on income, current spending, historical savings, and contributions.
//
//               Suggest a reasonable weekly or monthly contribution.
//
//               Warn if target completion dates are unrealistic and provide adjustments.
//
//               Offer tips to accelerate goal achievement (e.g., reduce discretionary spending).
//
//               Personalized Financial Insights
//
//               Provide actionable feedback based on income, expenses, budgets, and goals.
//
//               Highlight overspending categories, low savings rates, or patterns that delay goals.
//
//               Celebrate positive behavior (e.g., “You spent 15% less on dining out this week — nice job!”).
//
//               Style & Tone
//
//               Concise, encouraging, friendly, and easy to understand.
//
//               Use concrete examples, avoid jargon, or explain it clearly if needed.
//
//               Respond like a supportive friend who understands the user’s financial context.
//
//               Safety & Scope
//
//               Stick strictly to personal finance (expenses, budgets, savings, goals).
//
//               Do not provide legal, tax, or investment advice.
//
//               Politely steer users back to finance-related topics if off-topic.
//
//               Key Rules
//
//               Always use available tools to retrieve or update data.
//
//               Never assume missing information; ask the user first.
//
//               Reference all relevant data in your advice.
//
//               Provide short, actionable feedback with concrete examples.
//
//               Make financial insights practical, personalized, and positive.
//
//"""
//    
//    @ObservationIgnored lazy var session = LanguageModelSession(
//        tools: [
//            AddExpenseTool(),
//            GetExpenseTool(),
//            GetBudgetsTool(),
//            GetGoalsTool(),
//            GetIncomeTool()
//        ],
//        instructions: instructions
//    )
//    
//    func generateResponse() async {
//        isGenerating = true
//        let stream = session.streamResponse(to: query)
//        query = ""
//        do {
//            for try await partial in stream {
//                generatedResponse = partial.content
//            }
//            print("Finished generating")
//        } catch {
//            alertMessage = error.localizedDescription
//            showAlert.toggle()
//        }
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
    var modelContainer: ModelContainer? = nil

    @MainActor
    init(inMemory: Bool = false) {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
            let container = try ModelContainer(for: ExpenseItem.self, configurations: configuration)
            modelContainer = container
            modelContext = container.mainContext
            modelContext?.autosaveEnabled = true
        } catch {
            print("Error initializing AddExpenseTool:", error.localizedDescription)
        }
    }

    func save() {
        guard let context = modelContext else { return }
        try? context.save()
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
        return await MainActor.run {
            guard let context = modelContext else { return "Error: Model context unavailable." }

            
            if arguments.amount <= 0 { return "Please provide a valid amount." }
            let validCategories = CategoryOptionsModel().category
            if !validCategories.contains(arguments.category) {
                return "Invalid category. Use one of: \(validCategories.joined(separator: ", "))"
            }

            let expense = ExpenseItem(
                name: arguments.name,
                amount: arguments.amount,
                date: Date().timeIntervalSince1970,
                category: arguments.category
            )
            context.insert(expense)
            save()

        
            if let budgets = try? context.fetch(FetchDescriptor<BudgetItem>()),
               let budget = budgets.first(where: { $0.category == arguments.category }),
               arguments.amount > budget.cap {
                return "Expense added, but you exceeded your budget for \(arguments.category)."
            }

            return "Expense added: \(arguments.name) - $\(arguments.amount)"
        }
    }
}


struct GetExpenseTool: Tool {
    var modelContext: ModelContext? = nil
    var modelContainer: ModelContainer? = nil

    @MainActor
    init(inMemory: Bool = false) {
        do {
            let container = try ModelContainer(for: ExpenseItem.self)
            modelContainer = container
            modelContext = container.mainContext
            modelContext?.autosaveEnabled = true
        } catch {
            print("Error initializing GetExpenseTool:", error.localizedDescription)
        }
    }

    let name = "getExpense"
    let description = "Retrieve expenses over a given number of days"

    @Generable
    struct Arguments {
        @Guide(description: "Number of days to look back") var daysToLookBack: Int
    }

    func call(arguments: Arguments) async throws -> [String] {
        return await MainActor.run {
            guard let context = modelContext else { return [] }

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let lower = calendar.date(byAdding: .day, value: -(max(arguments.daysToLookBack, 1) - 1), to: today)!
            let upper = calendar.date(byAdding: .day, value: 1, to: today)!

            let predicate = #Predicate<ExpenseItem> {
                $0.date >= lower.timeIntervalSince1970 && $0.date < upper.timeIntervalSince1970
            }
            let descriptor = FetchDescriptor<ExpenseItem>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )

            if let expenses = try? context.fetch(descriptor) {
                if expenses.isEmpty { return ["No expenses found."] }
                return expenses.map {
                    "Name: \($0.name), Amount: \($0.amount), Category: \($0.category), Date: \(Date(timeIntervalSince1970: $0.date).formatted())"
                }
            }
            return ["Error fetching expenses."]
        }
    }
}


struct GetBudgetsTool: Tool {
    var modelContext: ModelContext? = nil
    var modelContainer: ModelContainer? = nil

    @MainActor
    init(inMemory: Bool = false) {
        do {
            let container = try ModelContainer(for: BudgetItem.self)
            modelContainer = container
            modelContext = container.mainContext
            modelContext?.autosaveEnabled = true
        } catch {
            print("Error initializing GetBudgetsTool:", error.localizedDescription)
        }
    }

    let name = "getBudgets"
    let description = "Retrieve all budgets"

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> [String] {
        return await MainActor.run {
            guard let context = modelContext else { return [] }
            if let budgets = try? context.fetch(FetchDescriptor<BudgetItem>()) {
                if budgets.isEmpty { return ["No budgets set."] }
                return budgets.map { "Category: \($0.category), Cap: \($0.cap)" }
            }
            return ["Error fetching budgets."]
        }
    }
}


struct GetGoalsTool: Tool {
    var modelContext: ModelContext? = nil
    var modelContainer: ModelContainer? = nil

    @MainActor
    init(inMemory: Bool = false) {
        do {
            let container = try ModelContainer(for: GoalItem.self)
            modelContainer = container
            modelContext = container.mainContext
            modelContext?.autosaveEnabled = true
        } catch {
            print("Error initializing GetGoalsTool:", error.localizedDescription)
        }
    }

    let name = "getGoals"
    let description = "Retrieve all user goals"

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> [String] {
        return await MainActor.run {
            guard let context = modelContext else { return [] }
            if let goals = try? context.fetch(FetchDescriptor<GoalItem>()) {
                if goals.isEmpty { return ["No goals set."] }
                return goals.map { "Title: \($0.title), Current: \($0.current), Target: \($0.target)" }
            }
            return ["Error fetching goals."]
        }
    }
}


struct GetIncomeTool: Tool {
    let name = "getIncome"
    let description = "Get user's total income"

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> Int {
        return await MainActor.run {
            UserDefaults.standard.integer(forKey: "income")
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

    private(set) var session: LanguageModelSession?

    let instructions = """
    Role
    You are “Bro,” a friendly, professional, and intelligent personal finance assistant.
    You communicate clearly in English and act as a knowledgeable buddy helping users manage money effectively.

    Objectives
    Your primary goal is to help the user:

    Track and manage expenses.

    Set and monitor budgets.

    Plan and achieve financial goals.

    Maintain healthy cash flow.

    You must:

    Give concise, practical, and actionable guidance.

    Always reference user data: expenses, budgets, goals, and income.

    Never assume missing information. If details are incomplete, ask a clarifying question before taking action.

    Provide feedback based on patterns or trends in the user’s financial data.

    Keep explanations friendly, supportive, and easy to understand.

    Tool Usage

    AddExpenseTool

    Use whenever the user mentions or implies a new expense.

    Required details:

    Name: what the expense is for

    Amount: numeric value

    Category: choose from CategoryOptionsModel().category

    If any detail is missing, ask the user before logging.

    After adding an expense, summarize the impact on their budgets or goals if relevant.

    GetExpenseTool

    Use when the user wants to review or analyze past expenses.

    Summarize trends and highlight overspending or areas to save.

    Example queries:

    “What did I spend today?”

    “How much did I spend on groceries last week?”

    “Am I overspending on entertainment?”

    GetBudgetsTool

    Use to retrieve budget data and provide insights.

    Compare spending against budget caps and warn when overspending.

    GetGoalsTool

    Use to track progress toward goals.

    Predict completion dates, suggest contribution rates, and provide actionable advice.

    GetIncomeTool

    Use to determine the user’s income for calculations related to budgets, expenses, and goals.

    Goal Planning & Prediction

    Calculate time to reach goals based on income, current spending, historical savings, and contributions.

    Suggest a reasonable weekly or monthly contribution.

    Warn if target completion dates are unrealistic and provide adjustments.

    Offer tips to accelerate goal achievement (e.g., reduce discretionary spending).

    Personalized Financial Insights

    Provide actionable feedback based on income, expenses, budgets, and goals.

    Highlight overspending categories, low savings rates, or patterns that delay goals.

    Celebrate positive behavior (e.g., “You spent 15% less on dining out this week — nice job!”).

    Style & Tone

    Concise, encouraging, friendly, and easy to understand.

    Use concrete examples, avoid jargon, or explain it clearly if needed.

    Respond like a supportive friend who understands the user’s financial context.

    Safety & Scope

    Stick strictly to personal finance (expenses, budgets, savings, goals).

    Do not provide legal, tax, or investment advice.

    Politely steer users back to finance-related topics if off-topic.

    Key Rules

    Always use available tools to retrieve or update data.

    Never assume missing information; ask the user first.

    Reference all relevant data in your advice.

    Provide short, actionable feedback with concrete examples.

    Make financial insights practical, personalized, and positive.
    """

    @MainActor
    func setupSession() {
        let addExpenseTool = AddExpenseTool(inMemory: false)
        let getExpenseTool = GetExpenseTool(inMemory: false)
        let getBudgetsTool = GetBudgetsTool(inMemory: false)
        let getGoalsTool = GetGoalsTool(inMemory: false)
        let getIncomeTool = GetIncomeTool()

        session = LanguageModelSession(
            tools: [addExpenseTool, getExpenseTool, getBudgetsTool, getGoalsTool, getIncomeTool],
            instructions: instructions
        )
    }

    @MainActor
    func generateResponse() async {
        guard let session else { return }
        isGenerating = true
        let stream = session.streamResponse(to: query)
        query = ""
        do {
            for try await partial in stream {
                generatedResponse = partial.content
            }
            print("Finished generating")
        } catch {
            alertMessage = error.localizedDescription
            showAlert.toggle()
        }
    }
}
