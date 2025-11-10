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
    let description = "To collect expenses from expense tracker and get a return on all the expenses the user has spent on"
    
    @Generable
    struct Arguments {
        @Guide(description: "The name of the expense")
        var name: String
        @Guide(description: "The amount of the expense")
        var amount: Double
        @Guide(description: "The category of the expense")
        var category: String
    }
    
    func call(arguments: Arguments) async throws -> [String] {
        return await MainActor.run {
            guard let modelContext = modelContext else {
                return []
            }
            let expenseDescriptor = FetchDescriptor<ExpenseItem>()
            do {
                let expenses = try modelContext.fetch(expenseDescriptor)
                let formattedExpenses = expenses.map { expense in
                    "Name: \(expense.name), Amount: \(expense.amount), Category: \(expense.category), Date: \(Date(timeIntervalSince1970: expense.date).formatted())"
                }
                return formattedExpenses
            } catch(let error) {
                
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
            
        }
        return []
    }
    
    func call(arguments: Arguments) async throws -> Bool {
        return await MainActor.run {
            guard let modelContext = modelContext else {
                print("ERROR")
                return false
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
            
            return true
        }
    }
}
@Observable
class FoundationModelViewModel{
    init(){}
    var isGenerating: Bool = false
    var query: String = ""
    var generatedResponse: ModelResponse.PartiallyGenerated?
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
        •    Offer clear, accurate, and practical guidance on personal finance topics — including budgeting, expenses, savings, debt, and cash flow.
        •    If the user brings up topics unrelated to personal finance, politely redirect the conversation back to finance.
        •    When a user mentions or implies a new expense, help them record it using the AddExpenseTool with the appropriate name, amount, and category.
        •    If information is missing or unclear, infer what you reasonably can.
        •    If it’s too vague, ask brief, targeted follow-up questions.
        •    After the expense is added, give concise, constructive feedback (e.g., acknowledgment or a short financial insight).

    ⸻

    Style
        •    Be concise, encouraging, and easy to understand.
        •    Use plain, conversational language with concrete suggestions.
        •    Avoid jargon unless necessary — and explain any financial terms you use.
        •    Maintain a friendly, approachable tone — like a supportive friend who knows their stuff.

    ⸻

    Tool Usage — AddExpenseTool
        •    Use the tool whenever the user wants to log an expense or when it’s clearly appropriate to do so.
        •    Ensure the following fields are valid before calling the tool:
        •    Name (what the expense is)
        •    Amount (numeric value)
        •    Category (e.g., food, transport, entertainment, etc.)
        •    Infer missing details if context allows (e.g., “$4 for coffee” → name: coffee, category: food & drink).
        •    If the tool responds with success or failure, acknowledge the result naturally.

    ⸻

    Safety and Scope
        •    Do not provide legal, tax, or investment advice beyond general education or broad principles.
        •    If the user asks for non-finance-related help, gently steer them back to personal finance.
    """
    @ObservationIgnored lazy var session = LanguageModelSession(tools: [AddExpenseTool(inMemory: false), GetExpenseTool(inMemory: false)], instructions: instructions)
    func generateResponse() async{
        isGenerating = true
        let stream = session.streamResponse(to: query, generating: ModelResponse.self)
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
        chatHistory.append(ChatMessage(role: .user, content: query, isPartial: false))
        chatHistory.append(ChatMessage(role: .assistant, content: generatedResponse?.response ?? "", isPartial: true))
        

        
        
    }
    
}
