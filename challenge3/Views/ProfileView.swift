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
    
    @State private var isEditing = false
    @State private var selectedSegment = 0

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Sections", selection: $selectedSegment) {
                    Text("Details").tag(0)
                    Text("Chat History").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ScrollView {
                    if selectedSegment == 0 {
                        profileCard
                            .padding(.top)
                    } else {
                        chatHistorySection
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button() {
                        withAnimation { isEditing.toggle() }
                    } label: {
                        if isEditing {
                            Text("Done")
                        } else {
                            Image(systemName: "pencil")
                        }
                    }
                }
            }
        }
    }

    private var profileCard: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 55))
                        .foregroundColor(.blue)
                )

            if isEditing {
                Text("Name")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter name", text: $name)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .font(.title)
            } else {
                Text("Name")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(name.isEmpty ? "Unnamed User" : name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 4) {
                Text("Income per Month")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if isEditing {
                    TextField("Enter income", text: $income)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)
                } else {
                    Text(formattedIncome(income))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    // chat section wow
    private var chatHistorySection: some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { i in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chat \(i+1)")
                        .font(.headline)
                    Text("blah blah blah")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
        }
    }

    private func formattedIncome(_ value: String) -> String {
        guard let number = Double(value.replacingOccurrences(of: ",", with: "")) else {
            return value.isEmpty ? "Not set" : value
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: number)) ?? "$0.00"
    }
}



#Preview {
    ProfileView()
}
