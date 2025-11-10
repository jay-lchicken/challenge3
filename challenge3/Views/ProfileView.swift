//
//  ProfileView.swift
//  challenge3
//
//  Created by Gautham Dinakaran on 7/11/25.
//

import SwiftUI


struct ProfileView: View {
    @AppStorage("name") private var name: String = ""
    @AppStorage("income") private var income: String = ""
    @State private var editingName = false
    @State private var editingIncome = false
    @State private var selectedSegment = 0

    var body: some View {
        NavigationView {
            VStack {
                Picker("Sections", selection: $selectedSegment) {
                    Text("Details").tag(0)
                    Text("Chat History").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedSegment == 0 {
                    VStack(spacing: 30) {
                        HStack {
                            Text("Name:")
                                .font(.headline)
                            if editingName {
                                TextField("Enter name", text: $name)
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit { editingName = false }
                            } else {
                                Text(name.isEmpty ? "Not set" : name)
                                    .onTapGesture { editingName = true }
                            }
                        }
                        .padding(.horizontal)

                        HStack {
                            Text("Income per year:")
                                .font(.headline)
                            if editingIncome {
                                TextField("Enter income", text: $income)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit { editingIncome = false }
                            } else {
                                Text(income.isEmpty ? "Not set" : "$\(income)")
                                    .onTapGesture { editingIncome = true }
                            }
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                } else {
                    List {
                        ForEach(0..<10) { i in
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Chat \(i + 1)")
                                    .font(.headline)
                                Text("blah blah blah")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
              
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}


#Preview {
    ProfileView()
}
