import Foundation
import SwiftData
import SwiftUI

struct ProfileView: View {
    @AppStorage("name") private var name: String = ""
    @AppStorage("income") private var income: String = ""
    
    @State private var isEditing = false
    @State private var selectedSegment = 0
    
    // We only need the primary expense query
    @Query var expenses: [ExpenseItem]
    
    var subscriptionExpenses: [ExpenseItem] {
        expenses.filter { $0.category.lowercased() == "subscriptions" }
    }

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
                        profileCard.padding(.top)
                    } else {
                        subscriptionSection
                    }
                }
                .onAppear {
                    for expense in subscriptionExpenses {
                        if expense.isRecurring == nil {
                            expense.isRecurring = true
                        }
                        if expense.frequency == nil {
                            expense.frequency = .monthly
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button() { withAnimation { isEditing.toggle() } } label: {
                        if isEditing { Text("Done") } else { Image(systemName: "pencil") }
                    }
                }
            }
        }
    }

    struct SubscriptionRowView: View {
        @Bindable var expense: ExpenseItem
        var isEditing: Bool

        var body: some View {
            let isRecurringBinding = Binding(
                get: { expense.isRecurring ?? true },
                set: { expense.isRecurring = $0 }
            )

            let frequencyBinding = Binding(
                get: { expense.frequency ?? .monthly },
                set: { expense.frequency = $0 }
            )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(expense.name).bold().foregroundColor(.primary)
                        Text(Date(timeIntervalSince1970: expense.date), style: .date)
                            .font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("$\(expense.amount, specifier: "%.2f")").bold()
                            .foregroundColor(isRecurringBinding.wrappedValue ? .green : .gray)
                        Text(frequencyBinding.wrappedValue.rawValue.capitalized)
                            .font(.caption).foregroundColor(.gray)
                    }
                }

                if isEditing {
                    Toggle(isOn: isRecurringBinding) {
                        Text("Automatically renew?").font(.caption).foregroundColor(.gray)
                    }
                    Picker("Frequency", selection: frequencyBinding) {
                        ForEach(ExpenseItem.Frequency.allCases) { freq in
                            Text(freq.rawValue.capitalized).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
    }


    private var subscriptionSection: some View {
        VStack(spacing: 16) {
            let totalMonthlyCost = subscriptionExpenses.reduce(0) { total, expense in
                expense.frequency?.monthlyAmount(from: expense.amount)
            }

            // Total card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Subscriptions")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Estimated Monthly Cost")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(totalMonthlyCost ?? 0, specifier: "%.2f")")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.green)
                    }
                    Spacer()
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green.opacity(0.7))
                }
                .padding(.vertical, 8)
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 12) {
                    if subscriptionExpenses.isEmpty {
                        Text("No subscriptions found")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(subscriptionExpenses, id: \.id) { expense in
                            SubscriptionRowView(expense: expense, isEditing: isEditing)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)

                Text("Your subscriptions will be automatically added to your expenses if you choose that option.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
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
                    Text("Name").font(.subheadline).foregroundColor(.gray)
                    if isEditing {
                        TextField("Enter name", text: $name)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .font(.title)
                    } else {
                        Text(name.isEmpty ? "Unnamed User" : name)
                            .font(.title).fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                }
                
                VStack(spacing: 4) {
                    Text("Income per Month").font(.subheadline).foregroundColor(.gray)
                    if isEditing {
                        TextField("Enter income", text: $income)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .font(.title2)
                    } else {
                        Text(formattedIncome(income))
                            .font(.title2).fontWeight(.semibold)
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
