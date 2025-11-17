//
//  ActionIntent.swift
//  challenge3
//
//  Created by Gautham Dinakaran on 17/11/25.
//

import Foundation
import AppIntents
import UIKit
@available(iOS 18.0, *)

struct LaunchAddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Add Expense"
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = true
    @MainActor
    func perform() async throws -> some IntentResult  {
        guard let url = URL(string: "moneymapr://expenses/add") else{
            print("Cant be created")
            return .result()
        }
        await UIApplication.shared.open(url)
        return .result()
    }
}
