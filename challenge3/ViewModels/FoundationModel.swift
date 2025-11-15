//
//  FoundationModel.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import Foundation
import FoundationModels
import Combine
import SwiftData

@Generable
struct ModelResponse{
    @Guide(description: "The main response you have to the user's query")
    var response: String
}

struct GetExpenseTool: Tool {
    var modelContext: ModelContext? = nil
    var modelContainer: ModelContainer? = nil
    
    @MainActor
    init(inMemory: Bool) {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
            let container = try ModelContainer(for: ExpenseItem.self, configurations: configuration)
            modelContainer = container
            modelContext = container.mainContext
            modelContext?.autosaveEnabled = true
            
        } catch(let error) {
            print(error)
            print(error.localizedDescription)
        }
    }
    func save() {
        guard let modelContext = modelContext else {
            return
        }
        do {
            try modelContext.save()
        } catch (let error) {
            print(error)
        }
    }
    let name = "getExpense"
    let description = "To collect expenses from expense tracker and get a return on the expenses the user has spent on"
    
    @Generable
    struct Arguments {
        @Guide(description: "Number of days to look back")
        var daysToLookBack: Int
        
    }
    
    func call(arguments: Arguments) async throws -> [String] {
        return await MainActor.run {
            guard let modelContext = modelContext else {
                return []
            }
            
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            let days = max(arguments.daysToLookBack, 1)
            let lowerDate = calendar.date(byAdding: .day, value: -(days - 1), to: startOfToday) ?? startOfToday
            let upperDate = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? startOfToday.addingTimeInterval(86_400)
            
            let lowerBound = lowerDate.timeIntervalSince1970
            let upperBound = upperDate.timeIntervalSince1970
            
            let predicate = #Predicate<ExpenseItem> { item in
                item.date >= lowerBound && item.date < upperBound
            }
            
            let expenseDescriptor = FetchDescriptor<ExpenseItem>(
                predicate: predicate,
                sortBy: [SortDescriptor(\ExpenseItem.date, order: .reverse)]
            )
            
            do {
                let expenses = try modelContext.fetch(expenseDescriptor)
                let formattedExpenses = expenses.map { expense in
                    "Name: \(expense.name), Amount: \(expense.amount), Category: \(expense.category), Date: \(Date(timeIntervalSince1970: expense.date).formatted())"
                }
                print(formattedExpenses)
                return formattedExpenses
                
            } catch(let error) {
                print(error)
            }
            return []
        }
    }
}

struct AddExpenseTool: Tool {
    var modelContext: ModelContext? = nil
    var modelContainer: ModelContainer? = nil
    
    @MainActor
    init(inMemory: Bool) {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
            let container = try ModelContainer(for: ExpenseItem.self, configurations: configuration)
            modelContainer = container
            modelContext = container.mainContext
            modelContext?.autosaveEnabled = true
            
        } catch(let error) {
            print(error)
            print(error.localizedDescription)
        }
    }
    func save() {
        guard let modelContext = modelContext else {
            return
        }
        do {
            try modelContext.save()
        } catch (let error) {
            print(error)
        }
    }
    let name = "addExpense"
    let description = "Add an expense to your expense tracker and get a return bool on whether it was successful"
    
    @Generable
    struct Arguments {
        @Guide(description: "The name of the expense")
        var name: String
        @Guide(description: "The amount of the expense")
        var amount: Double
        @Guide(description: "The category of the expense")
        var category: String
        
    }
    func queryExpenses() -> [ExpenseItem] {
        guard let modelContext = modelContext else {
            return []
        }
        let expenseDescriptor = FetchDescriptor<ExpenseItem>()
        do {
            let expenses = try modelContext.fetch(expenseDescriptor)
            return expenses
        } catch(let error) {
            print(error)
        }
        return []
    }
    
    func call(arguments: Arguments) async throws -> String {
        return await MainActor.run {
            guard let modelContext = modelContext else {
                print("ERROR")
                return "false"
            }
            
            let newExpense = ExpenseItem(
                name: arguments.name,
                amount: arguments.amount,
                date: Date().timeIntervalSince1970,
                category: arguments.category
            )
            modelContext.insert(newExpense)
            save()
            print("SUCCESS!!!")
            print(queryExpenses())
            
            return "\(arguments.amount)"

        }
    }
}

@Observable
class FoundationModelViewModel{
    init() {}
    var isGenerating: Bool = false
    var query: String = ""
    var generatedResponse: String? = nil
    var showAlert = false
    var alertMessage: String = ""
    var chatHistory: [ChatMessage] = []
    
    let instructions =
    """
    Role

    You are “Bro”, a friendly and professional personal finance assistant.
    You communicate only in English.

    ⸻

    Objectives

    Your main goal is to help the user manage their personal finances effectively.
    That includes budgeting, tracking expenses, saving, managing debt, and maintaining healthy cash flow.

    You should:
        •    Give clear, accurate, and practical financial guidance.
        •    Track expenses automatically whenever the user mentions or implies a purchase or payment.
        •    Review spending history to give personalized insights and feedback.
        •    Keep your advice short, friendly, and actionable — like a knowledgeable friend helping them stay on top of money matters.

    ⸻

    Tool Usage

    AddExpenseTool
    Use this tool whenever:
        •    The user mentions or implies a new expense.
        •    An expense needs to be logged or categorized.

    Before using it, make sure you have:
        •    Name: what the expense is for
        •    Amount: numeric value
        •    Category: "beverage", "food", "transport", "lifestyle", "subscriptions", "shopping", "others" (PLEASE CHOOSE FROM THESE CATEGORIES ONLY)

    If any details are missing:
        •    Infer them logically from context (e.g., “$4 coffee” → name: coffee, category: beverage, e.g. "I spent $300 at IKEA" → name: IKEA, category: shopping).
        •    If it’s too vague, ask a short follow-up question for clarification.

    After adding an expense:
        •    Acknowledge it naturally and, if useful, give a quick financial insight or encouragement.

    ⸻

    GetExpenseTool
    Use this tool whenever:
        •    The user asks to review, analyze, or get feedback on their past expenses.
        •    The user asks questions like:
        •    “What did I spend on today?”
        •    “How much did I spend last week?”
        •    “Show my transport expenses.”
        •    “Am I spending too much on food?”

    When you retrieve expenses:
        •    Summarize the data clearly and briefly.
        •    Point out patterns or trends (e.g., “You’ve spent more on dining out this week than last.”).
        •    Offer constructive advice or small adjustments to improve financial habits.

    ⸻

    Style
        •    Be concise, encouraging, and easy to understand.
        •    Use plain language and concrete examples.
        •    Avoid jargon — if you must use a term, explain it simply.
        •    Sound friendly and supportive, like a financially savvy buddy who’s got the user’s back.

    ⸻

    Safety and Scope
        •    Stick to personal finance — budgeting, spending, saving, and debt management.
        •    Politely steer the user back if they go off-topic.
        •    Avoid legal, tax, or investment advice, except for broad educational guidance.

    """
    @ObservationIgnored lazy var session = LanguageModelSession(tools: [AddExpenseTool(inMemory: false), GetExpenseTool(inMemory: false)], instructions: instructions)
    
    func generateResponse() async{
        isGenerating = true
        let stream = session.streamResponse(to: query)
        do{
            for try await partial in stream {
                generatedResponse = partial.content
            }
            print("Finished generating")
        }catch{
            alertMessage = error.localizedDescription
            showAlert.toggle()
            print("\(error.localizedDescription)")
        }
//        chatHistory.append(ChatMessage(role: .user, content: query, isPartial: false))
//        chatHistory.append(ChatMessage(role: .assistant, content: generatedResponse?.response ?? "", isPartial: true))
        
    }
}
