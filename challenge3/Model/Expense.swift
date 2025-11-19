import Foundation
import SwiftData

@Model
class ExpenseItem: Identifiable {
    var id = UUID()
    var name: String
    var amount: Double
    var date: TimeInterval
    var category: String

    var isRecurring: Bool? = nil
    var frequency: Frequency? = nil

    enum Frequency: String, CaseIterable, Codable, Identifiable {
        var id: String { rawValue }
        case daily, weekly, monthly, yearly

        func monthlyAmount(from baseAmount: Double) -> Double {
            switch self {
            case .daily: return baseAmount * 30
            case .weekly: return baseAmount * 4
            case .monthly: return baseAmount
            case .yearly: return baseAmount / 12
            }
        }
    }

    init(
        name: String,
        amount: Double,
        date: TimeInterval = Date().timeIntervalSince1970,
        category: String,
        isRecurring: Bool? = nil,
        frequency: Frequency? = nil
    ) {
        self.name = name
        self.amount = amount
        self.date = date
        self.category = category
        self.isRecurring = isRecurring
        self.frequency = frequency
    }
}
