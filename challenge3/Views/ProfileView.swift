//
//  ProfileView.swift
//  challenge3
//
//  Created by Gautham Dinakaran on 7/11/25.
//

import SwiftUI
import SwiftData

@Model
class SubscriptionItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var originalExpenseId: UUID
    var isRecurring: Bool
    var frequency: Frequency

    enum Frequency: String, CaseIterable, Codable, Identifiable {
        case weekly, monthly, yearly
        var id: String { rawValue }
    }

    init(expense: ExpenseItem, isRecurring: Bool = true, frequency: Frequency = .monthly) {
        self.id = UUID()
        self.name = expense.name
        self.amount = expense.amount
        self.originalExpenseId = expense.id
        self.isRecurring = isRecurring
        self.frequency = frequency
    }

    var monthlyAmount: Double {
        switch frequency {
        case .weekly: return amount * 4
        case .monthly: return amount
        case .yearly: return amount / 12
        }
    }
}

struct ProfileView: View {
    @AppStorage("name") private var name: String = ""
    @AppStorage("income") private var income: String = ""
    
    @State private var isEditing = false
    @State private var selectedSegment = 0
    
    @Query var expenses: [ExpenseItem]
    @Query var subscriptionItems: [SubscriptionItem]
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Sections", selection: $selectedSegment) {
                    Text("Details").tag(0)
                    Text("Subscriptions").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ScrollView {
                    if selectedSegment == 0 {
                        profileCard
                            .padding(.top)
                    } else {
                        subscriptionSection
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
        HStack(spacing: 16) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 55))
                        .foregroundColor(.blue)
                )
            
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("Name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if isEditing {
                        TextField("Enter name", text: $name)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .font(.title)
                    } else {
                        Text(name.isEmpty ? "Unnamed User" : name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
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
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    struct SubscriptionRowView: View {
        @Bindable var subscription: SubscriptionItem
        var isEditing: Bool
        @Query var expenses: [ExpenseItem]

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subscription.name)
                            .bold()
                            .foregroundColor(.primary)

                        if let expense = expenses.first(where: { $0.id == subscription.originalExpenseId }) {
                            Text(Date(timeIntervalSince1970: expense.date), style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("$\(subscription.amount, specifier: "%.2f")")
                            .bold()
                            .foregroundColor(.green)
                        Text(subscription.frequency.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                if isEditing {
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle(isOn: $subscription.isRecurring) {
                            Text("Automatically renew?")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Picker("Frequency", selection: $subscription.frequency) {
                            ForEach(SubscriptionItem.Frequency.allCases) { freq in
                                Text(freq.rawValue.capitalized).tag(freq)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }

    private var subscriptionSection: some View {
        let subs: [SubscriptionItem] = expenses
            .filter { $0.category.lowercased() == "subscriptions" }
            .map { expense in
                if let existing = subscriptionItems.first(where: { $0.originalExpenseId == expense.id }) {
                    return existing
                } else {
                    let newSub = SubscriptionItem(expense: expense)
                    modelContext.insert(newSub)
                    return newSub
                }
            }

        let totalMonthlyCost = subs.reduce(0) { $0 + $1.monthlyAmount }

        return VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: 40, height: 40)
                        Image(systemName: "creditcard")
                            .foregroundColor(.white)
                    }

                    Text("Subscriptions")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()
                }
                .padding()

                Text("Monthly Spending")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.white)
                    Text("\(totalMonthlyCost, specifier: "%.2f")")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.7))
                .cornerRadius(12)
                .padding()
            }
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 12) {
                    if subs.isEmpty {
                        Text("No subscriptions found")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(subs, id: \.id) { sub in
                            SubscriptionRowView(subscription: sub, isEditing: isEditing)
                        }
                    }
                }
                .padding(.vertical)

                Text("Subscriptions will automatically add each month, unless stated otherwise.")
                    .font(.caption)
                    .foregroundColor(.gray)
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
