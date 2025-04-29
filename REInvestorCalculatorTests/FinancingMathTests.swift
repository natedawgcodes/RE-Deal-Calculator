import XCTest
@testable import REInvestorCalculator

final class FinancingMathTests: XCTestCase {
    var viewModel: FinancingViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = FinancingViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testBasicFinancingCalculation() {
        // Test case from requirements:
        // Purchase $200,000, Down 25%, Rate 6%, Term 30y
        // Rent $2,000, Expenses (tax $250, ins $90, HOA $50)
        viewModel.propertyInputs.purchasePrice = 200_000
        viewModel.propertyInputs.monthlyRent = 2_000
        viewModel.propertyInputs.propertyTax = 3_000 // $250 * 12
        viewModel.propertyInputs.insurance = 1_080 // $90 * 12
        viewModel.propertyInputs.hoaFees = 50
        viewModel.propertyInputs.maintenance = 0
        viewModel.propertyInputs.vacancy = 0
        viewModel.propertyInputs.propertyManagement = 0
        
        viewModel.financingInputs.downPaymentPercent = 25
        viewModel.financingInputs.interestRate = 6
        viewModel.financingInputs.loanTermYears = 30
        viewModel.financingInputs.closingCosts = 0
        
        viewModel.calculate()
        
        // Expected results
        XCTAssertEqual(viewModel.results.monthlyPI, 899.33, accuracy: 0.01)
        XCTAssertEqual(viewModel.results.monthlyExpenses, 390, accuracy: 0.01) // ($3000 + $1080)/12 + $50
        XCTAssertEqual(viewModel.results.monthlyCashFlow, 710.67, accuracy: 0.01)
        XCTAssertEqual(viewModel.results.capRate, 8.22, accuracy: 0.01)
        XCTAssertEqual(viewModel.results.cashOnCashReturn, 17.06, accuracy: 0.01)
        XCTAssertEqual(viewModel.results.totalInvestment, 50_000, accuracy: 0.01)
    }
    
    func testZeroPurchasePrice() {
        viewModel.propertyInputs.purchasePrice = 0
        viewModel.calculate()
        XCTAssertNotNil(viewModel.error)
    }
    
    func testZeroInterestRate() {
        viewModel.propertyInputs.purchasePrice = 100_000
        viewModel.financingInputs.downPaymentPercent = 20
        viewModel.financingInputs.interestRate = 0
        viewModel.financingInputs.loanTermYears = 30
        
        viewModel.calculate()
        
        // With 0% interest, monthly payment should be loan amount / number of payments
        let expectedMonthlyPayment = (100_000 * 0.8) / (30 * 12)
        XCTAssertEqual(viewModel.results.monthlyPI, expectedMonthlyPayment, accuracy: 0.01)
    }
    
    func testHighVacancyAndManagement() {
        viewModel.propertyInputs.purchasePrice = 200_000
        viewModel.propertyInputs.monthlyRent = 2_000
        viewModel.propertyInputs.vacancy = 10 // 10% vacancy
        viewModel.propertyInputs.propertyManagement = 8 // 8% management fee
        
        viewModel.financingInputs.downPaymentPercent = 20
        viewModel.financingInputs.interestRate = 5
        viewModel.financingInputs.loanTermYears = 30
        
        viewModel.calculate()
        
        // Vacancy should reduce effective rent by 10%
        // Management should take 8% of remaining rent
        let expectedVacancyLoss = 200 // 10% of $2000
        let expectedManagementFee = 144 // 8% of ($2000 - $200)
        let totalExpenses = expectedVacancyLoss + expectedManagementFee
        XCTAssertEqual(viewModel.results.monthlyExpenses, totalExpenses, accuracy: 0.01)
    }
} 