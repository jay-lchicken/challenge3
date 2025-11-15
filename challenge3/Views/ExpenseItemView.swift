//
//  ExpenseItemView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import SwiftUI

struct ExpenseItemView: View {
    @State var title: String
    @State var date: Date
    @State var amount: Double
    @State var category: String
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                
                Text(title)
                    .bold()
                Text(date.formatted())
                
            }
            Spacer()
            HStack (spacing: 0){
                Text("$")
                Text(String(format: "%.2f", amount))
                
            }
            
        }
        .padding()
        .background(category.categoryColor)
        .cornerRadius(12)
    }
}
