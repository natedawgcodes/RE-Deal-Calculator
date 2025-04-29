import SwiftUI

// Make sure this view is accessible from the main module
@available(iOS 15.0, *)
public struct FinancingView: View {
    @StateObject private var viewModel = FinancingViewModel()
    @State private var showingResults = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                propertySection
                financingSection
                calculateButton
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Financing")
        .sheet(isPresented: $showingResults) {
            ResultsView(results: viewModel.results)
        }
    }
    
    private var propertySection: some View {
        VStack(alignment: .leading) {
            Text("Property Details")
                .font(.headline)
            
            VStack {
                CurrencyField(
                    title: "Purchase Price",
                    value: $viewModel.propertyInputs.purchasePrice
                )
                
                CurrencyField(
                    title: "Monthly Rent",
                    value: $viewModel.propertyInputs.monthlyRent
                )
                
                CurrencyField(
                    title: "Annual Property Tax",
                    value: $viewModel.propertyInputs.propertyTax
                )
                
                CurrencyField(
                    title: "Annual Insurance",
                    value: $viewModel.propertyInputs.insurance
                )
                
                CurrencyField(
                    title: "Monthly HOA",
                    value: $viewModel.propertyInputs.hoaFees
                )
                
                CurrencyField(
                    title: "Monthly Maintenance",
                    value: $viewModel.propertyInputs.maintenance
                )
                
                PercentageField(
                    title: "Vacancy Rate",
                    value: $viewModel.propertyInputs.vacancy
                )
                
                PercentageField(
                    title: "Property Management",
                    value: $viewModel.propertyInputs.propertyManagement
                )
            }
            .cardStyle()
        }
    }
    
    private var financingSection: some View {
        VStack(alignment: .leading) {
            Text("Financing Details")
                .font(.headline)
            
            VStack {
                PercentageField(
                    title: "Down Payment",
                    value: $viewModel.financingInputs.downPaymentPercent
                )
                
                PercentageField(
                    title: "Interest Rate",
                    value: $viewModel.financingInputs.interestRate
                )
                
                HStack {
                    Text("Loan Term (Years)")
                    Spacer()
                    Picker("", selection: $viewModel.financingInputs.loanTermYears) {
                        Text("15").tag(15)
                        Text("20").tag(20)
                        Text("30").tag(30)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
                
                CurrencyField(
                    title: "Closing Costs",
                    value: $viewModel.financingInputs.closingCosts
                )
            }
            .cardStyle()
        }
    }
    
    private var calculateButton: some View {
        Button(action: {
            viewModel.calculate()
            showingResults = true
        }) {
            Text("Calculate")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(CornerRadius.medium)
        }
    }
}

struct ResultsView: View {
    @Environment(\.dismiss) var dismiss
    let results: FinancingResults
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    monthlyResultsCard
                    returnsCard
                    investmentCard
                }
                .padding()
            }
            .navigationTitle("Results")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private var monthlyResultsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Monthly Cash Flow")
                .font(.headline)
            
            VStack(spacing: Spacing.small) {
                ResultRow(title: "Principal & Interest", value: results.monthlyPI)
                ResultRow(title: "Expenses", value: results.monthlyExpenses)
                Divider()
                ResultRow(
                    title: "Net Cash Flow",
                    value: results.monthlyCashFlow,
                    isHighlighted: true
                )
            }
        }
        .cardStyle()
    }
    
    private var returnsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Returns")
                .font(.headline)
            
            VStack(spacing: Spacing.small) {
                ResultRow(
                    title: "Cap Rate",
                    value: results.capRate,
                    format: .percent
                )
                ResultRow(
                    title: "Cash on Cash Return",
                    value: results.cashOnCashReturn,
                    format: .percent
                )
            }
        }
        .cardStyle()
    }
    
    private var investmentCard: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Investment")
                .font(.headline)
            
            ResultRow(
                title: "Total Investment Required",
                value: results.totalInvestment,
                isHighlighted: true
            )
        }
        .cardStyle()
    }
}

struct ResultRow: View {
    let title: String
    let value: Double
    var format: Format = .currency
    var isHighlighted = false
    
    enum Format {
        case currency
        case percent
    }
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(formattedValue)
                .bold(isHighlighted)
        }
    }
    
    private var formattedValue: String {
        switch format {
        case .currency:
            return value.asCurrency
        case .percent:
            return value.asPercent
        }
    }
}

struct CurrencyField: View {
    let title: String
    @Binding var value: Double
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", value: $value, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 150)
        }
    }
}

struct PercentageField: View {
    let title: String
    @Binding var value: Double
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
            Text("%")
        }
    }
}

#Preview {
    NavigationView {
        FinancingView()
    }
} 