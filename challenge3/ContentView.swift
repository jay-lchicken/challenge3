//
//  ContentView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/5/25.
//

import SwiftUI

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }

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
