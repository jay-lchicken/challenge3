//
//  CategoryOptionsModel.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/15/25.
//

import Foundation
import SwiftUI

struct CategoryOptionsModel{
    let category = ["beverage", "food", "transport", "lifestyle", "subscriptions", "shopping", "others"]
}
extension String {
    var categoryColor: Color {
        switch self.lowercased() {
        case "beverage":
            return .yellow.opacity(0.3)
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
