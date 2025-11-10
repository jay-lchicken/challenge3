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
                HomeView()
            }

            Tab("Finance", systemImage: "bitcoinsign.circle"){
                FinanceView()
            }

            Tab("Add", systemImage: "plus", role: .search) {
                AddExpenseView()
            }
        }
        .font(.custom("Roboto-Regular", size: 16)) // Base app font
        .onChange(of: currentTab) { newValue, oldValue in
            if newValue == 2 {
                showSheet = true
                currentTab = oldValue
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory{
            Button{
                showSheet.toggle()
                
                
            }label:{
                HStack{
                    Text("What would you like to do today?")
                        .foregroundStyle(.gray)
                        .padding()
                    Spacer()
                        
                    Button{
                        
                    }label:{
                        Image(systemName: "arrow.up.circle")
                            .font(.title2)
                            .padding()
                    }

                }

                           
            }
        }
        .sheet(isPresented: $showSheet){
            ChatView()
        }
        
    }
}

#Preview {
    ContentView()
}
