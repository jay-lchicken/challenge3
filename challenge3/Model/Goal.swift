//
//  Goal.swift
//  challenge3
//
//  Created by Aletheus Ang on 14/11/25.
//

import SwiftData
import Foundation

@Model
class GoalItem: Identifiable {
    var title: String
    var current: Double
    var target: Double
    var dateCreated: Date
    
    init(title: String, current: Double, target: Double) {
        self.title = title
        self.current = current
        self.target = target
        self.dateCreated = Date()
    }
}
