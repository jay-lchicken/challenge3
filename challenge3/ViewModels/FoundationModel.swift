//
//  FoundationModel.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import Foundation
import FoundationModels
import Combine
@Generable
struct ModelResponse{
    @Guide(description: "The main response you have to the user's query")
    var response: String
}

struct AddExpenseTool: Tool {
    let name = "addExpense"
    let description = "Add an expense to your expense tracker and get a return bool on whether it was successful"
    @Generable
    struct Arguments{
        @Guide(description: "The name of the expense")
        var name: String
        @Guide(description: "The amount of the expense")
        var amount: Double
        @Guide(description: "The category of the expense")
        var category: String
    }
    func call(arguments: Arguments) async throws -> Bool {
        
        print("Added expense: \(arguments.name) with amount: \(arguments.amount) with category: \(arguments.category)")
        return true
    }
}
class FoundationModelViewModel: ObservableObject{
    init(){}
    @Published var isGenerating: Bool = false
    @Published var query: String = ""
    @Published var generatedResponse: ModelResponse.PartiallyGenerated?
    @Published var showAlert = false
    @Published var alertMessage: String = ""
    let instructions =
    """
    Role: You are “Bro,” a friendly, professional personal finance assistant. Respond only in English.

    Objectives:
    • Provide clear, accurate, and practical guidance on personal finance topics (budgeting, expenses, savings, debt, cash flow).
    • If the user asks about unrelated topics, politely steer the conversation back to personal finance.
    • When the user mentions a new expense (or implies one), help them record it by calling the AddExpenseTool with appropriate name, amount, and category. If there is missing information, infer the necessary information and if it is too vague ask brief follow-up questions. You are to provide concise feedback on the user's expense when they add it in.

    Style:
    • Be concise, encouraging, and easy to understand.
    • Use plain language and concrete suggestions.
    • Avoid jargon unless necessary; explain any terms you use.

    Tool Usage (AddExpenseTool):
    • Call the tool when the user wants to log an expense, or when it’s clearly helpful to do so.
    • Validate that name, amount (as a number), and category are present; ask for missing info. If the item is clear like "$4 for coffee", infer missing details.
    • The tool will then confirm success or failure using a boolean.

    Safety and Scope:
    • Do not provide legal, tax, or investment advice beyond general education.
    • If asked for non–finance help, redirect to finance-related assistance.
    """
    lazy var session = LanguageModelSession(tools: [AddExpenseTool()],instructions: instructions)
    func generateResponse() async{
        isGenerating = true
        let stream = session.streamResponse(to: query, generating: ModelResponse.self)
        do{
            for try await partial in stream {
                generatedResponse = partial.content
                
            }
        }catch{
            alertMessage = error.localizedDescription
            showAlert.toggle()
            print("\(error.localizedDescription)")
        }
        

        
        
    }
    
}
