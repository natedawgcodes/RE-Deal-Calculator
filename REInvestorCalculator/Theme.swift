import SwiftUI

enum ThemeMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
}

class AppState: ObservableObject {
    @AppStorage("themeMode") var themeMode: ThemeMode = .system
    
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    func resetAllData() {
        // Clear all saved data
        UserDefaults.standard.removeObject(forKey: "savedPropertyInputs")
        UserDefaults.standard.removeObject(forKey: "savedFinancingInputs")
        UserDefaults.standard.removeObject(forKey: "savedFlipInputs")
        UserDefaults.standard.removeObject(forKey: "savedMAOInputs")
        UserDefaults.standard.removeObject(forKey: "savedComparisonInputs")
    }
} 