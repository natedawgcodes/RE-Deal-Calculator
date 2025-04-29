import SwiftUI

// MARK: - Models
struct ComparisonInputs: Codable {
    var property1Name: String = ""
    var property1Price: Double = 0
    var property1Rent: Double = 0
    var property1Expenses: Double = 0
    
    var property2Name: String = ""
    var property2Price: Double = 0
    var property2Rent: Double = 0
    var property2Expenses: Double = 0
}

struct ComparisonResults {
    var property1CashFlow: Double = 0
    var property2CashFlow: Double = 0
    var property1CapRate: Double = 0
    var property2CapRate: Double = 0
    var property1ROI: Double = 0
    var property2ROI: Double = 0
}

// MARK: - ViewModel
class ComparisonViewModel: ObservableObject {
    @Published var inputs = ComparisonInputs()
    @Published var results = ComparisonResults()
    @Published var error: String?
    
    @AppStorage("savedComparisonInputs") private var savedComparisonInputs: Data?
    
    init() {
        loadSavedData()
    }
    
    func calculate() {
        do {
            guard inputs.property1Price > 0 && inputs.property2Price > 0 else {
                throw CalculatorError.invalidLoanAmount
            }
            
            let property1AnnualNOI = (inputs.property1Rent * 12) - (inputs.property1Expenses * 12)
            let property2AnnualNOI = (inputs.property2Rent * 12) - (inputs.property2Expenses * 12)
            
            let property1CapRate = (property1AnnualNOI / inputs.property1Price) * 100
            let property2CapRate = (property2AnnualNOI / inputs.property2Price) * 100
            
            let property1CashFlow = inputs.property1Rent - inputs.property1Expenses
            let property2CashFlow = inputs.property2Rent - inputs.property2Expenses
            
            let property1ROI = (property1CashFlow * 12) / inputs.property1Price * 100
            let property2ROI = (property2CashFlow * 12) / inputs.property2Price * 100
            
            results = ComparisonResults(
                property1CashFlow: property1CashFlow,
                property2CashFlow: property2CashFlow,
                property1CapRate: property1CapRate,
                property2CapRate: property2CapRate,
                property1ROI: property1ROI,
                property2ROI: property2ROI
            )
            
            error = nil
            saveData()
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func loadSavedData() {
        if let data = savedComparisonInputs,
           let inputs = try? JSONDecoder().decode(ComparisonInputs.self, from: data) {
            self.inputs = inputs
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(inputs) {
            savedComparisonInputs = encoded
        }
    }
    
    func reset() {
        inputs = ComparisonInputs()
        results = ComparisonResults()
        error = nil
        saveData()
    }
}

// MARK: - Views
struct ComparisonView: View {
    @StateObject private var viewModel = ComparisonViewModel()
    @State private var showingResults = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                property1Section
                property2Section
                calculateButton
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Comparison")
        .sheet(isPresented: $showingResults) {
            ComparisonResultsView(results: viewModel.results, inputs: viewModel.inputs)
        }
    }
    
    private var property1Section: some View {
        SectionView(title: "Property 1") {
            VStack(spacing: 15) {
                TextField("Property Name", text: $viewModel.inputs.property1Name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                InputField(
                    title: "Purchase Price",
                    value: $viewModel.inputs.property1Price,
                    format: .currency
                )
                
                InputField(
                    title: "Monthly Rent",
                    value: $viewModel.inputs.property1Rent,
                    format: .currency
                )
                
                InputField(
                    title: "Monthly Expenses",
                    value: $viewModel.inputs.property1Expenses,
                    format: .currency
                )
            }
        }
    }
    
    private var property2Section: some View {
        SectionView(title: "Property 2") {
            VStack(spacing: 15) {
                TextField("Property Name", text: $viewModel.inputs.property2Name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                InputField(
                    title: "Purchase Price",
                    value: $viewModel.inputs.property2Price,
                    format: .currency
                )
                
                InputField(
                    title: "Monthly Rent",
                    value: $viewModel.inputs.property2Rent,
                    format: .currency
                )
                
                InputField(
                    title: "Monthly Expenses",
                    value: $viewModel.inputs.property2Expenses,
                    format: .currency
                )
            }
        }
    }
    
    private var calculateButton: some View {
        Button(action: {
            viewModel.calculate()
            showingResults = true
        }) {
            Text("Compare")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
        }
    }
}

struct ComparisonResultsView: View {
    @Environment(\.dismiss) var dismiss
    let results: ComparisonResults
    let inputs: ComparisonInputs
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    cashFlowSection
                    capRateSection
                    roiSection
                }
                .padding()
            }
            .navigationTitle("Results")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private var cashFlowSection: some View {
        SectionView(title: "Monthly Cash Flow") {
            VStack(spacing: 15) {
                ResultRow(
                    title: inputs.property1Name.isEmpty ? "Property 1" : inputs.property1Name,
                    value: results.property1CashFlow,
                    format: .currency
                )
                
                ResultRow(
                    title: inputs.property2Name.isEmpty ? "Property 2" : inputs.property2Name,
                    value: results.property2CashFlow,
                    format: .currency
                )
            }
        }
    }
    
    private var capRateSection: some View {
        SectionView(title: "Cap Rate") {
            VStack(spacing: 15) {
                ResultRow(
                    title: inputs.property1Name.isEmpty ? "Property 1" : inputs.property1Name,
                    value: results.property1CapRate,
                    format: .percentage
                )
                
                ResultRow(
                    title: inputs.property2Name.isEmpty ? "Property 2" : inputs.property2Name,
                    value: results.property2CapRate,
                    format: .percentage
                )
            }
        }
    }
    
    private var roiSection: some View {
        SectionView(title: "Return on Investment") {
            VStack(spacing: 15) {
                ResultRow(
                    title: inputs.property1Name.isEmpty ? "Property 1" : inputs.property1Name,
                    value: results.property1ROI,
                    format: .percentage
                )
                
                ResultRow(
                    title: inputs.property2Name.isEmpty ? "Property 2" : inputs.property2Name,
                    value: results.property2ROI,
                    format: .percentage
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        ComparisonView()
    }
} 