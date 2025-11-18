//
//  CategoryOptionsModel.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/15/25.
//

import Foundation
import SwiftUI

struct CategoryOptionsModel{
    let category = ["food", "transport", "lifestyle", "subscriptions", "shopping", "others"]
}
extension String {
    var categoryColor: Color {
        switch self.lowercased() {
        case "food":
            return .green.opacity(0.3)
        case "transport":
            return .blue.opacity(0.3)
        case "lifestyle":
            return .purple.opacity(0.3)
        case "subscriptions":
            return .orange.opacity(0.3)
        case "shopping":
            return .pink.opacity(0.3)
        case "others":
            return .gray.opacity(0.3)
        default:
            return .gray.opacity(0.2)
        }
    }
}
extension String{
    var sFSymbol:  String {
        switch self.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "shopping": return "bag.fill"
        case "lifestyle": return "person.2.fill"
        case "subscriptions": return "creditcard.fill"
        case "others": return "square.grid.2x2"
        default: return "questionmark.circle"
        }
        
    }
}

