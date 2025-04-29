import Foundation

public struct Formatters {
    public static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    public static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    public static func formatCurrency(_ value: Double) -> String {
        return currency.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    public static func formatPercent(_ value: Double) -> String {
        return percent.string(from: NSNumber(value: value)) ?? "0%"
    }
}

// Extension for Double to easily format as currency or percent
extension Double {
    public var asCurrency: String {
        Formatters.formatCurrency(self)
    }
    
    public var asPercent: String {
        Formatters.formatPercent(self)
    }
} 