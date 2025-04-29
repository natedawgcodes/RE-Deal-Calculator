import Foundation

public struct PropertyInputs: Codable {
    public var purchasePrice: Double = 0
    public var monthlyRent: Double = 0
    public var propertyTax: Double = 0
    public var insurance: Double = 0
    public var hoaFees: Double = 0
    public var maintenance: Double = 0
    public var vacancy: Double = 5 // Default 5% vacancy rate
    public var propertyManagement: Double = 0
    
    public init() {}
}

public struct FinancingInputs: Codable {
    public var downPaymentPercent: Double = 20
    public var interestRate: Double = 5
    public var loanTermYears: Int = 30
    public var closingCosts: Double = 0
    
    public init() {}
}

public struct FinancingResults {
    public var monthlyPI: Double = 0
    public var monthlyExpenses: Double = 0
    public var monthlyCashFlow: Double = 0
    public var capRate: Double = 0
    public var cashOnCashReturn: Double = 0
    public var totalInvestment: Double = 0
    
    public var annualCashFlow: Double {
        monthlyCashFlow * 12
    }
    
    public init() {}
}

public enum FinancingError: Error {
    case invalidInput(String)
    case calculationError(String)
} 