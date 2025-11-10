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
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Finance")
                    .padding(.top)
                
                Picker("", selection: $selectedTab) {
                    Text("Overview").tag("Overview")
                    Text("Expenses").tag("Expenses")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Picker("", selection: $selectedExpenseTab) {
                                Text("Today’s expenses").tag("Today’s expenses")
                                Text("Monthly Expenses").tag("Monthly Expenses")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            Button("Edit Budget") {}
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recommended").font(.caption)
                            HStack {
                                Capsule().fill(Color.green).frame(width: 120, height: 20)
                                Capsule().fill(Color.red).frame(width: 60, height: 20)
                                Capsule().fill(Color.yellow).frame(width: 80, height: 20)
                            }
                            Text("Current").font(.caption)
                            HStack {
                                Capsule().fill(Color.green).frame(width: 100, height: 20)
                                Capsule().fill(Color.yellow).frame(width: 100, height: 20)
                                Capsule().fill(Color.red).frame(width: 40, height: 20)
                            }
                        }
                        
                        HStack(spacing: 30) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Food: $30")
                                    Circle().fill(Color.green).frame(width: 15)
                                }
                                HStack {
                                    Text("Utilities: $25")
                                    Circle().fill(Color.yellow).frame(width: 15)
                                }
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Transport: $12")
                                    Circle().fill(Color.red).frame(width: 15)
                                }
                                HStack {
                                    Text("Saved: $33")
                                    Circle().stroke(Color.gray, lineWidth: 2).frame(width: 15)
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
