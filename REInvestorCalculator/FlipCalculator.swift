import SwiftUI

// MARK: - Models
struct FlipInputs: Codable {
    var purchasePrice: Double = 0
    var repairCosts: Double = 0
    var holdingCosts: Double = 0
    var sellingPrice: Double = 0
    var sellingCosts: Double = 0
}

struct FlipResults {
    var totalInvestment: Double = 0
    var totalRevenue: Double = 0
    var profit: Double = 0
    var roi: Double = 0
}

// MARK: - ViewModel
class FlipViewModel: ObservableObject {
    @Published var inputs = FlipInputs()
    @Published var results = FlipResults()
    @Published var error: String?
    
    @AppStorage("savedFlipInputs") private var savedFlipInputs: Data?
    
    init() {
        loadSavedData()
    }
    
    func calculate() {
        do {
            guard inputs.purchasePrice > 0 else {
                throw CalculatorError.invalidLoanAmount
            }
            
            let totalInvestment = inputs.purchasePrice + inputs.repairCosts + inputs.holdingCosts
            let totalRevenue = inputs.sellingPrice - inputs.sellingCosts
            let profit = totalRevenue - totalInvestment
            let roi = (profit / totalInvestment) * 100
            
            results = FlipResults(
                totalInvestment: totalInvestment,
                totalRevenue: totalRevenue,
                profit: profit,
                roi: roi
            )
            
            error = nil
            saveData()
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func loadSavedData() {
        if let data = savedFlipInputs,
           let inputs = try? JSONDecoder().decode(FlipInputs.self, from: data) {
            self.inputs = inputs
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(inputs) {
            savedFlipInputs = encoded
        }
    }
    
    func reset() {
        inputs = FlipInputs()
        results = FlipResults()
        error = nil
        saveData()
    }
}

// MARK: - Views
struct FlipCalculatorView: View {
    @StateObject private var viewModel = FlipViewModel()
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
        .navigationTitle("Flip Calculator")
        .sheet(isPresented: $showingResults) {
            FlipResultsView(results: viewModel.results)
        }
    }
    
    private var inputsSection: some View {
        SectionView(title: "Property Details") {
            VStack(spacing: 15) {
                InputField(
                    title: "Purchase Price",
                    value: $viewModel.inputs.purchasePrice,
                    format: .currency
                )
                
                InputField(
                    title: "Repair Costs",
                    value: $viewModel.inputs.repairCosts,
                    format: .currency
                )
                
                InputField(
                    title: "Holding Costs",
                    value: $viewModel.inputs.holdingCosts,
                    format: .currency
                )
                
                InputField(
                    title: "Selling Price",
                    value: $viewModel.inputs.sellingPrice,
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

struct FlipResultsView: View {
    @Environment(\.dismiss) var dismiss
    let results: FlipResults
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    investmentSection
                    revenueSection
                    profitSection
                }
                .padding()
            }
            .navigationTitle("Results")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private var investmentSection: some View {
        SectionView(title: "Total Investment") {
            ResultRow(
                title: "Total Investment",
                value: results.totalInvestment,
                format: .currency
            )
        }
    }
    
    private var revenueSection: some View {
        SectionView(title: "Total Revenue") {
            ResultRow(
                title: "Total Revenue",
                value: results.totalRevenue,
                format: .currency
            )
        }
    }
    
    private var profitSection: some View {
        SectionView(title: "Profit") {
            VStack(spacing: 15) {
                ResultRow(
                    title: "Profit",
                    value: results.profit,
                    format: .currency
                )
                
                ResultRow(
                    title: "ROI",
                    value: results.roi,
                    format: .percentage
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        FlipCalculatorView()
    }
} 