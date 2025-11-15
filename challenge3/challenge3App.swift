//
//  challenge3App.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/5/25.
//

import SwiftUI
import SwiftData
import FoundationModels

@main
struct challenge3App: App {
    private let model = SystemLanguageModel.default
    @State private var showAddExpense = false

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
    
    private func handleDeepLink(_ url: URL) {
        // Check if the URL scheme matches
        guard url.scheme == "myapp" else { return }
        
        // Handle the add-expense deep link
        if url.host == "add-expense" {
            showAddExpense = true
        }
    }
}
