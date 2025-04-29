import SwiftUI

// MARK: - Models
struct MAOInputs: Codable {
    var arv: Double = 0 // After Repair Value
    var repairCosts: Double = 0
    var desiredProfit: Double = 0
    var holdingCosts: Double = 0
    var sellingCosts: Double = 0
}

struct MAOResults {
    var mao: Double = 0
    var totalCosts: Double = 0
    var profit: Double = 0
}

// MARK: - ViewModel
class MAOViewModel: ObservableObject {
    @Published var inputs = MAOInputs()
    @Published var results = MAOResults()
    @Published var error: String?
    
    @AppStorage("savedMAOInputs") private var savedMAOInputs: Data?
    
    init() {
        loadSavedData()
    }
    
    func calculate() {
        do {
            guard inputs.arv > 0 else {
                throw CalculatorError.invalidLoanAmount
            }
            
            let totalCosts = inputs.repairCosts + inputs.holdingCosts + inputs.sellingCosts + inputs.desiredProfit
            let mao = inputs.arv - totalCosts
            
            results = MAOResults(
                mao: mao,
                totalCosts: totalCosts,
                profit: inputs.desiredProfit
            )
            
            error = nil
            saveData()
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func loadSavedData() {
        if let data = savedMAOInputs,
           let inputs = try? JSONDecoder().decode(MAOInputs.self, from: data) {
            self.inputs = inputs
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(inputs) {
            savedMAOInputs = encoded
        }
    }
    
    func reset() {
        inputs = MAOInputs()
        results = MAOResults()
        error = nil
        saveData()
    }
}

// MARK: - Views
struct MAOCalculatorView: View {
    @StateObject private var viewModel = MAOViewModel()
    @State private var showingResults = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                inputsSection
                calculateButton
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("MAO Calculator")
        .sheet(isPresented: $showingResults) {
            MAOResultsView(results: viewModel.results)
        }
    }
    
    private var inputsSection: some View {
        SectionView(title: "Property Details") {
            VStack(spacing: 15) {
                InputField(
                    title: "After Repair Value (ARV)",
                    value: $viewModel.inputs.arv,
                    format: .currency
                )
                
                InputField(
                    title: "Repair Costs",
                    value: $viewModel.inputs.repairCosts,
                    format: .currency
                )
                
                InputField(
                    title: "Desired Profit",
                    value: $viewModel.inputs.desiredProfit,
                    format: .currency
                )
                
                InputField(
                    title: "Holding Costs",
                    value: $viewModel.inputs.holdingCosts,
                    format: .currency
                )
                
                InputField(
                    title: "Selling Costs",
                    value: $viewModel.inputs.sellingCosts,
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
            Text("Calculate")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
        }
    }
}

struct MAOResultsView: View {
    @Environment(\.dismiss) var dismiss
    let results: MAOResults
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    maoCard
                    costsCard
                    profitCard
                }
                .padding()
            }
            .navigationTitle("Results")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private var maoCard: some View {
        SectionView(title: "Maximum Allowable Offer") {
            ResultRow(
                title: "MAO",
                value: results.mao,
                format: .currency
            )
        }
    }
    
    private var costsCard: some View {
        SectionView(title: "Total Costs") {
            ResultRow(
                title: "Total Costs",
                value: results.totalCosts,
                format: .currency
            )
        }
    }
    
    private var profitCard: some View {
        SectionView(title: "Profit") {
            ResultRow(
                title: "Desired Profit",
                value: results.profit,
                format: .currency
            )
        }
    }
}

#Preview {
    NavigationView {
        MAOCalculatorView()
    }
} 