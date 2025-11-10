//
//  FinanceView.swift
//  challenge3
//
//  Created by Aletheus Ang on 9/11/25.
//

import SwiftUI

struct FinanceView: View {
    @State private var selectedTab = "Overview"
    @State private var selectedExpenseTab = "Today’s expenses"
    @State private var budget: Double = 1500
    @State private var food: Double = 300
    @State private var utilities: Double = 25
    @State private var transport: Double = 12

    private var totalExpenses: Double {
        food + utilities + transport
    }
    private var saved: Double {
        max(budget - totalExpenses, 0)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Finance")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                Picker("", selection: $selectedTab) {
                    Text("Overview").tag("Overview")
                    Text("Expenses").tag("Expenses")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Picker("", selection: $selectedExpenseTab) {
                                Text("Today’s expenses").tag("Today’s expenses")
                                Text("Monthly Expenses").tag("Monthly Expenses")
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)

                            Button("Edit Budget") {}
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Expense Breakdown").font(.caption)

                            GeometryReader { geometry in
                                let totalWidth = geometry.size.width
                                let total = max(budget, 1)
                                let foodWidth = totalWidth * (food / total)
                                let utilWidth = totalWidth * (utilities / total)
                                let transportWidth = totalWidth * (transport / total)
                                let savedWidth = totalWidth * (saved / total)

                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.gray.opacity(0.2)).frame(height: 20)
                                    HStack(spacing: 0) {
                                        Capsule().fill(Color.green).frame(width: foodWidth, height: 20)
                                        Capsule().fill(Color.yellow).frame(width: utilWidth, height: 20)
                                        Capsule().fill(Color.red).frame(width: transportWidth, height: 20)
                                        Capsule().fill(Color.gray).frame(width: savedWidth, height: 20)
                                    }
                                }
                            }
                            .frame(height: 20)

                            Text("Budget: $\(Int(budget)) | Spent: $\(Int(totalExpenses)) | Saved: $\(Int(saved))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        HStack(spacing: 30) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Food: $\(Int(food))")
                                    Circle().fill(Color.green).frame(width: 15)
                                }
                                HStack {
                                    Text("Utilities: $\(Int(utilities))")
                                    Circle().fill(Color.yellow).frame(width: 15)
                                }
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Transport: $\(Int(transport))")
                                    Circle().fill(Color.red).frame(width: 15)
                                }
                                HStack {
                                    Text("Saved: $\(Int(saved))")
                                    Circle().fill(Color.gray).frame(width: 15)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Goals:")
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Button("Add New") {}
                                    .padding(6)
                                    .background(Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Porsche Car - 75K / 150K")
                                    .font(.headline)
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.orange.opacity(0.5)).frame(height: 20)
                                    HStack(spacing: 0) {
                                        Capsule().fill(Color.green).frame(width: 150, height: 20)
                                        Capsule().fill(Color.red).frame(width: 50, height: 20)
                                    }
                                }
                                Text("Just a little bit more!")
                                    .italic()
                            }
                            .padding()
                            .background(Color.orange.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    FinanceView()
}
