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
            return .green
        case "transport":
            return .blue
        case "lifestyle":
            return .purple
        case "subscriptions":
            return .orange
        case "shopping":
            return .pink
        case "others":
            return .gray
        default:
            return .gray
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

