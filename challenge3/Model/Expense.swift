//
//  Expense.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import Foundation
import SwiftData

@Model
class ExpenseItem: Equatable{
    var name: String
    var amount: Double
    var date: TimeInterval
    var category: String
    init(name: String, amount: Double, date: TimeInterval, category: String) {
        self.name = name
        self.amount = amount
        self.date = date
        self.category = category
    }
}
