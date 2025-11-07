//
//  HomeView.swift
//  challenge3
//
//  Created by Lai Hong Yu on 11/7/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack{
            VStack{
                Text("Hello World!")
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
