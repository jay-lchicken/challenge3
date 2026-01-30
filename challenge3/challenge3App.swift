//
//  challenge3App.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/5/25.
//

import SwiftUI
import SwiftData
import FoundationModels
import AppIntents
import AppIntents

@main
struct challenge3App: App {
    private let model = SystemLanguageModel.default
    @State var showAddExpense = false
    @AppStorage("inteEnabled") var isInteEnabled: Bool = false
    


    var body: some Scene {
        WindowGroup {
            switch model.availability {
            case .available:
                ContentView()
                    .tint(.yellow)
                    .modelContainer(for: [ExpenseItem.self, GoalItem.self, BudgetItem.self], isUndoEnabled: true)
                    .sheet(isPresented: $showAddExpense) {
                        AddExpenseView()
                            .modelContainer(for: [ExpenseItem.self, GoalItem.self, BudgetItem.self], isUndoEnabled: true)

                    }
                    .task{
                        isInteEnabled = true
                        
                    }
                    
                    .onOpenURL { url in
                        handleDeepLink(url)
                    }
                   
                    .onContinueUserActivity("LaunchAddExpenseIntent") { _ in
                        print("Received AppIntent: LaunchAddExpenseIntent")
                        showAddExpense = true
                    }
            default:
                ContentView()
                    .tint(.yellow)
                    .modelContainer(for: [ExpenseItem.self, GoalItem.self, BudgetItem.self], isUndoEnabled: true)
                    .sheet(isPresented: $showAddExpense) {
                        AddExpenseView()
                    }
                    .task{
                        isInteEnabled = false

                    }
                    
                    .onOpenURL { url in
                        handleDeepLink(url)
                    }
                   
                    .onContinueUserActivity("LaunchAddExpenseIntent") { _ in
                        print("Received AppIntent: LaunchAddExpenseIntent")
                        showAddExpense = true
                    }
            }
        }
    }

    func handleDeepLink(_ url: URL) {
        print("Received URL: \(url.absoluteString)")
        if url.scheme == "moneymapr", url.host == "expenses", url.pathComponents.contains("add") {
            print("Presenting AddExpenseView!")
            showAddExpense = true
        }
    }
    
    
}
//DO NOT DELETE

@available(iOS 18.0, *)
struct LaunchAddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Add Expense"
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        print("Called")
        guard let url = URL(string: "moneymapr://expenses/add") else {
            return .result()
        }
        await UIApplication.shared.open(url)
        
        return .result()
    }
}

