//
//  challenge3App.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/5/25.
//

import SwiftUI
import SwiftData
@main
struct challenge3App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.yellow)
                .modelContainer(for: ExpenseItem.self)
        }
    }
}
