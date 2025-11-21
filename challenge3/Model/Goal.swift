//
//  Goal.swift
//  challenge3
//
//  Created by Aletheus Ang on 14/11/25.
//

import Foundation
import SwiftData

@Model
final class GoalItem: Identifiable {
    var id = UUID()
    var title: String
    var current: Double
    var target: Double
    var dateCreated: Date
    var isComplete: Bool {
        current >= target
    }
    init(title: String, current: Double, target: Double) {
        self.title = title
        self.current = current
        self.target = target
        self.dateCreated = Date()
    }
}

