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
    
    @State var categoryColours = CategoryOptionsModel()
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing:10){
                    Image(systemName: category.sFSymbol)
                                .font(.system(size: 14))   
                                .foregroundColor(.white)
                                .padding(.vertical, 2)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
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
        .padding()
        .background(category.categoryColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: category.categoryColor.opacity(0.25), radius: 6, x: 0, y: 3)
    }
}
 
 
