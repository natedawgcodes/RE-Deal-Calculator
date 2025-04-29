//
//  REInvestorCalculatorApp.swift
//  REInvestorCalculator
//
//  Created by Nate on 4/28/25.
//

import SwiftUI

@main
struct REInvestorCalculatorApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}
