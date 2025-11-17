//
//  Budget.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/17/25.
//

import Foundation
import SwiftData

@Model
final class BudgetItem: Identifiable {
    var id: UUID
    var category: String
    var cap: Double
    
    init(id: UUID = UUID(), category: String, cap: Double) {
        self.id = id
        self.category = category
        self.cap = cap
    }
}

