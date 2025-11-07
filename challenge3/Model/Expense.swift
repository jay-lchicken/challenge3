//
//  Expense.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import Foundation
struct ExpenseItem: Codable, Hashable{
    var name: String
    var amount: Double
    var date: TimeInterval
    var category: String
}
