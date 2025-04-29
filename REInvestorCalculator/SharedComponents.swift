import SwiftUI

// MARK: - Enums
enum InputFormat {
    case currency
    case percentage
    case number
}

enum CalculatorError: LocalizedError {
    case invalidLoanAmount
    
    var errorDescription: String? {
        switch self {
        case .invalidLoanAmount:
            return "Loan amount must be greater than 0"
        }
    }
}

// MARK: - Shared Components
struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            content
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
        }
    }
}

struct InputField: View {
    let title: String
    @Binding var value: Double
    let format: InputFormat
    @FocusState private var isFocused: Bool
    
    private var formattedValue: String {
        switch format {
        case .currency:
            return String(format: "%.2f", value)
        case .percentage:
            return String(format: "%.2f", value)
        case .number:
            return String(format: "%.0f", value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                if format == .currency {
                    Text("$")
                        .foregroundColor(.primary)
                }
                
                TextField("0", text: Binding(
                    get: { formattedValue },
                    set: { newValue in
                        if let doubleValue = Double(newValue) {
                            value = doubleValue
                        }
                    }
                ))
                .keyboardType(format == .number ? .numberPad : .decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isFocused)
                
                if format == .percentage {
                    Text("%")
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct ResultRow: View {
    let title: String
    let value: Double
    let format: InputFormat
    
    private var formattedValue: String {
        switch format {
        case .currency:
            return String(format: "$%.2f", value)
        case .percentage:
            return String(format: "%.1f%%", value)
        case .number:
            return String(format: "%.0f", value)
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(formattedValue)
                .font(.headline)
        }
    }
}

// MARK: - Formatters
extension Double {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }
    
    var asPercent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self / 100)) ?? "0.0%"
    }
} 