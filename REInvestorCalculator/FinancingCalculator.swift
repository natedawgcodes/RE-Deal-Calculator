import SwiftUI

// MARK: - Models
struct PropertyInputs {
    var purchasePrice: Double
    var afterRepairValue: Double
    var repairCosts: Double
    var closingCosts: Double
    var holdingCosts: Double
    var propertyTaxes: Double
    var insurance: Double
    var customExpenses: [CustomExpense]
}

struct CustomExpense: Identifiable {
    let id = UUID()
    var name: String
    var amount: Double
}

struct FinancingInputs {
    var downPaymentAmount: Double
    var downPaymentPercentage: Double
    var isDownPaymentPercentage: Bool
    var interestRate: Double
    var loanTerm: Int
    var points: Double
    var otherFees: Double
}

struct FinancingResults {
    var loanAmount: Double
    var monthlyPayment: Double
    var totalInterest: Double
    var totalCost: Double
    var cashOnCashReturn: Double
    var returnOnInvestment: Double
}

// MARK: - View Model
class FinancingCalculatorViewModel: ObservableObject {
    @Published var propertyInputs = PropertyInputs(
        purchasePrice: 0,
        afterRepairValue: 0,
        repairCosts: 0,
        closingCosts: 0,
        holdingCosts: 0,
        propertyTaxes: 0,
        insurance: 0,
        customExpenses: []
    )
    
    @Published var financingInputs = FinancingInputs(
        downPaymentAmount: 0,
        downPaymentPercentage: 20,
        isDownPaymentPercentage: true,
        interestRate: 0,
        loanTerm: 30,
        points: 0,
        otherFees: 0
    )
    
    @Published var results: FinancingResults?
    @Published var errorMessage: String?
    @Published var newCustomExpenseName: String = ""
    @Published var newCustomExpenseAmount: Double = 0
    
    func calculate() {
        do {
            let downPayment = financingInputs.isDownPaymentPercentage ?
                (propertyInputs.purchasePrice * financingInputs.downPaymentPercentage / 100) :
                financingInputs.downPaymentAmount
            
            let loanAmount = propertyInputs.purchasePrice - downPayment
            guard loanAmount > 0 else {
                throw CalculatorError.invalidLoanAmount
            }
            
            let monthlyRate = financingInputs.interestRate / 100 / 12
            let numberOfPayments = Double(financingInputs.loanTerm * 12)
            
            let monthlyPayment = (loanAmount * monthlyRate * pow(1 + monthlyRate, numberOfPayments)) / (pow(1 + monthlyRate, numberOfPayments) - 1)
            
            let totalInterest = (monthlyPayment * numberOfPayments) - loanAmount
            let totalCustomExpenses = propertyInputs.customExpenses.reduce(0) { $0 + $1.amount }
            let totalCost = propertyInputs.purchasePrice + 
                           propertyInputs.repairCosts + 
                           propertyInputs.closingCosts + 
                           propertyInputs.holdingCosts + 
                           totalInterest +
                           totalCustomExpenses
            
            let cashOnCashReturn = (propertyInputs.afterRepairValue - totalCost) / downPayment * 100
            let returnOnInvestment = (propertyInputs.afterRepairValue - totalCost) / totalCost * 100
            
            results = FinancingResults(
                loanAmount: loanAmount,
                monthlyPayment: monthlyPayment,
                totalInterest: totalInterest,
                totalCost: totalCost,
                cashOnCashReturn: cashOnCashReturn,
                returnOnInvestment: returnOnInvestment
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            results = nil
        }
    }
    
    func addCustomExpense() {
        guard !newCustomExpenseName.isEmpty else { return }
        let expense = CustomExpense(name: newCustomExpenseName, amount: newCustomExpenseAmount)
        propertyInputs.customExpenses.append(expense)
        newCustomExpenseName = ""
        newCustomExpenseAmount = 0
        calculate()
    }
    
    func removeCustomExpense(_ expense: CustomExpense) {
        propertyInputs.customExpenses.removeAll { $0.id == expense.id }
        calculate()
    }
}

// MARK: - Views
struct FinancingView: View {
    @StateObject private var viewModel = FinancingCalculatorViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var focusedField: Field?
    
    enum Field {
        case purchasePrice, afterRepairValue, repairCosts, closingCosts, holdingCosts
        case propertyTaxes, insurance, customExpenseName, customExpenseAmount
        case downPaymentAmount, downPaymentPercentage, interestRate, loanTerm, points, otherFees
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Property Inputs Section
                SectionView(title: "Property Details") {
                    VStack(spacing: 15) {
                        InputField(
                            title: "Purchase Price",
                            value: $viewModel.propertyInputs.purchasePrice,
                            format: .currency
                        )
                        .focused($focusedField, equals: .purchasePrice)
                        
                        InputField(
                            title: "After Repair Value",
                            value: $viewModel.propertyInputs.afterRepairValue,
                            format: .currency
                        )
                        .focused($focusedField, equals: .afterRepairValue)
                        
                        InputField(
                            title: "Repair Costs",
                            value: $viewModel.propertyInputs.repairCosts,
                            format: .currency
                        )
                        .focused($focusedField, equals: .repairCosts)
                        
                        InputField(
                            title: "Closing Costs",
                            value: $viewModel.propertyInputs.closingCosts,
                            format: .currency
                        )
                        .focused($focusedField, equals: .closingCosts)
                        
                        InputField(
                            title: "Holding Costs",
                            value: $viewModel.propertyInputs.holdingCosts,
                            format: .currency
                        )
                        .focused($focusedField, equals: .holdingCosts)
                        
                        InputField(
                            title: "Property Taxes (Annual)",
                            value: $viewModel.propertyInputs.propertyTaxes,
                            format: .currency
                        )
                        .focused($focusedField, equals: .propertyTaxes)
                        
                        InputField(
                            title: "Insurance (Annual)",
                            value: $viewModel.propertyInputs.insurance,
                            format: .currency
                        )
                        .focused($focusedField, equals: .insurance)
                    }
                }
                
                // Custom Expenses Section
                SectionView(title: "Custom Expenses") {
                    VStack(spacing: 15) {
                        ForEach(viewModel.propertyInputs.customExpenses) { expense in
                            HStack {
                                Text(expense.name)
                                    .font(.subheadline)
                                Spacer()
                                Text(expense.amount.asCurrency)
                                    .font(.subheadline)
                                Button(action: { viewModel.removeCustomExpense(expense) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        HStack {
                            TextField("Expense Name", text: $viewModel.newCustomExpenseName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .customExpenseName)
                            
                            InputField(
                                title: "Amount",
                                value: $viewModel.newCustomExpenseAmount,
                                format: .currency
                            )
                            .focused($focusedField, equals: .customExpenseAmount)
                            
                            Button(action: viewModel.addCustomExpense) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                // Financing Inputs Section
                SectionView(title: "Financing Details") {
                    VStack(spacing: 15) {
                        // Down Payment Toggle
                        HStack {
                            Text("Down Payment")
                            Spacer()
                            Picker("Down Payment Type", selection: $viewModel.financingInputs.isDownPaymentPercentage) {
                                Text("$").tag(false)
                                Text("%").tag(true)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 100)
                        }
                        
                        if viewModel.financingInputs.isDownPaymentPercentage {
                            InputField(
                                title: "Down Payment (%)",
                                value: $viewModel.financingInputs.downPaymentPercentage,
                                format: .percentage
                            )
                            .focused($focusedField, equals: .downPaymentPercentage)
                        } else {
                            InputField(
                                title: "Down Payment ($)",
                                value: $viewModel.financingInputs.downPaymentAmount,
                                format: .currency
                            )
                            .focused($focusedField, equals: .downPaymentAmount)
                        }
                        
                        InputField(
                            title: "Interest Rate",
                            value: $viewModel.financingInputs.interestRate,
                            format: .percentage
                        )
                        .focused($focusedField, equals: .interestRate)
                        
                        InputField(
                            title: "Loan Term (Years)",
                            value: Binding(
                                get: { Double(viewModel.financingInputs.loanTerm) },
                                set: { viewModel.financingInputs.loanTerm = Int($0) }
                            ),
                            format: .number
                        )
                        .focused($focusedField, equals: .loanTerm)
                        
                        InputField(
                            title: "Points",
                            value: $viewModel.financingInputs.points,
                            format: .percentage
                        )
                        .focused($focusedField, equals: .points)
                        
                        InputField(
                            title: "Other Fees",
                            value: $viewModel.financingInputs.otherFees,
                            format: .currency
                        )
                        .focused($focusedField, equals: .otherFees)
                    }
                }
                
                // Calculate Button
                Button(action: {
                    viewModel.calculate()
                }) {
                    Text("Calculate")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if let results = viewModel.results {
                    FinancingResultsView(results: results)
                }
            }
            .padding()
        }
        .navigationTitle("Financing Calculator")
        .background(colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
}

struct FinancingResultsView: View {
    let results: FinancingResults
    
    var body: some View {
        SectionView(title: "Results") {
            VStack(spacing: 15) {
                ResultRow(title: "Loan Amount", value: results.loanAmount, format: .currency)
                ResultRow(title: "Monthly Payment", value: results.monthlyPayment, format: .currency)
                ResultRow(title: "Total Interest", value: results.totalInterest, format: .currency)
                ResultRow(title: "Total Cost", value: results.totalCost, format: .currency)
                ResultRow(title: "Cash on Cash Return", value: results.cashOnCashReturn, format: .percentage)
                ResultRow(title: "Return on Investment", value: results.returnOnInvestment, format: .percentage)
            }
        }
    }
}

#Preview {
    NavigationView {
        FinancingView()
    }
} 