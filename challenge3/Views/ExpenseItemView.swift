//
//  ExpenseItemView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//
 
import SwiftUI
 
struct ExpenseItemView: View {
    let title: String
    let date: Date
    let amount: Double
    let category: String
    
    private var categoryColor: Color {
        switch category.lowercased() {
        case "food": return .green
        case "transport": return .blue
        case "shopping": return .pink
        case "subscriptons": return .purple
        case "lifestyle": return .orange
        case "others": return .yellow
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", amount))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(categoryColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: categoryColor.opacity(0.25), radius: 6, x: 0, y: 3)
    }
}
 
 
