//
//  ContentView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/5/25.
//

import SwiftUI

struct ContentView: View {
    @State var currentTab: Int = 0
    @State var showSheet = false
    var body: some View {
        TabView(){
            
            
            Tab("Home", systemImage: "house"){
                Text("home")
            }

            Tab("Finance", systemImage: "bitcoinsign.circle"){
                Text("finance")
            }

            Tab("Add", systemImage: "plus", role: .search) {
                Text("add")
            }
        }
        .onChange(of: currentTab) { newValue, oldValue in
            if newValue == 2 {
                showSheet = true
                currentTab = oldValue
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            TextField("What would you like to do today?", text: .constant(""))
                .textFieldStyle(.plain)
                .padding()
                
        }
    }
}

#Preview {
    ContentView()
}
