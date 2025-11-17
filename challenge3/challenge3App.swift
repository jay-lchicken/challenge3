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
    


    var body: some Scene {
        WindowGroup {
            switch model.availability {
            case .available:
                ContentView()
                    .tint(.yellow)
                    .modelContainer(for: [ExpenseItem.self, GoalItem.self], isUndoEnabled: true)
                    .sheet(isPresented: $showAddExpense) {
                        AddExpenseView()
                    }
                    
                    .onOpenURL { url in
                        handleDeepLink(url)
                    }
                   
                    .onContinueUserActivity("LaunchAddExpenseIntent") { _ in
                        print("Received AppIntent: LaunchAddExpenseIntent")
                        showAddExpense = true
                    }
            case .unavailable(.appleIntelligenceNotEnabled):
                Text("Apple Intelligence is not enabled. Please enable it in Settings.")
            case .unavailable(.deviceNotEligible):
                Text("This device does not support Apple Intelligence.")
            case .unavailable(.modelNotReady):
                Text("Foundation Model is not yet ready. Please try again later.")
            default:
                Text("Foundation Model is unavailable. Check device settings and try again.")
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

