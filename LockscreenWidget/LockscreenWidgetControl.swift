//
//  LockscreenWidgetControl.swift
//  LockscreenWidget
//
//  Created by Gautham Dinakaran on 14/11/25.
//
import WidgetKit
import SwiftUI
import AppIntents


struct LaunchAddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Add Expense"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

@available(iOS 18.0, *)
struct LockscreenWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "LockscreenWidgetControl") {
            ControlWidgetButton(action: LaunchAddExpenseIntent()) {
                Label("Add Expense", systemImage: "plus.circle.fill")
            }
        }
        .displayName("Add Expense Control")
        .description("Quickly add a new expense.")
    }
}
