import Foundation
import SwiftUI

public class FinancingViewModel: ObservableObject {
    @Published public var propertyInputs = PropertyInputs()
    @Published public var financingInputs = FinancingInputs()
    @Published public var results = FinancingResults()
    @Published public var error: String?
    
    @AppStorage("savedPropertyInputs") private var savedPropertyInputs: Data?
    @AppStorage("savedFinancingInputs") private var savedFinancingInputs: Data?
    
    public init() {
        loadSavedData()
    }
    
    public func calculate() {
        do {
            // Validate inputs
            guard propertyInputs.purchasePrice > 0 else {
                throw FinancingError.invalidInput("Purchase price must be greater than 0")
            }
            
            // Calculate loan amount
            let downPayment = propertyInputs.purchasePrice * (financingInputs.downPaymentPercent / 100)
            let loanAmount = propertyInputs.purchasePrice - downPayment
            
            // Calculate monthly P&I payment
            let monthlyRate = financingInputs.interestRate / (12 * 100)
            let numberOfPayments = financingInputs.loanTermYears * 12
            
            let monthlyPI = try calculateMonthlyPI(
                loanAmount: loanAmount,
                monthlyRate: monthlyRate,
                numberOfPayments: numberOfPayments
            )
            
            // Calculate monthly expenses
            let vacancyAmount = propertyInputs.monthlyRent * (propertyInputs.vacancy / 100)
            let managementAmount = propertyInputs.monthlyRent * (propertyInputs.propertyManagement / 100)
            
            let monthlyExpenses = propertyInputs.propertyTax / 12 +
                propertyInputs.insurance / 12 +
                propertyInputs.hoaFees +
                propertyInputs.maintenance +
                vacancyAmount +
                managementAmount
            
            // Calculate cash flow
            let monthlyCashFlow = propertyInputs.monthlyRent - monthlyPI - monthlyExpenses
            
            // Calculate total investment
            let totalInvestment = downPayment + financingInputs.closingCosts
            
            // Calculate returns
            let annualNOI = (propertyInputs.monthlyRent * 12) - (monthlyExpenses * 12)
            let capRate = (annualNOI / propertyInputs.purchasePrice) * 100
            let cashOnCash = ((monthlyCashFlow * 12) / totalInvestment) * 100
            
            // Update results
            results = FinancingResults(
                monthlyPI: monthlyPI,
                monthlyExpenses: monthlyExpenses,
                monthlyCashFlow: monthlyCashFlow,
                capRate: capRate,
                cashOnCashReturn: cashOnCash,
                totalInvestment: totalInvestment
            )
            
            error = nil
            saveData()
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func calculateMonthlyPI(loanAmount: Double, monthlyRate: Double, numberOfPayments: Int) throws -> Double {
        guard monthlyRate > 0 else {
            return loanAmount / Double(numberOfPayments)
        }
        
        let x = pow(1 + monthlyRate, Double(numberOfPayments))
        return loanAmount * (monthlyRate * x) / (x - 1)
    }
    
    private func loadSavedData() {
        if let propertyData = savedPropertyInputs,
           let property = try? JSONDecoder().decode(PropertyInputs.self, from: propertyData) {
            propertyInputs = property
        }
        
        if let financingData = savedFinancingInputs,
           let financing = try? JSONDecoder().decode(FinancingInputs.self, from: financingData) {
            financingInputs = financing
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(propertyInputs) {
            savedPropertyInputs = encoded
        }
        
        if let encoded = try? JSONEncoder().encode(financingInputs) {
            savedFinancingInputs = encoded
        }
    }
    
    func reset() {
        propertyInputs = PropertyInputs()
        financingInputs = FinancingInputs()
        results = FinancingResults()
        error = nil
        saveData()
    }
} 