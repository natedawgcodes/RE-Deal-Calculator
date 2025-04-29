//
//  ContentView.swift
//  REInvestorCalculator
//
//  Created by Nate on 4/28/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        TabView {
            FinancingView()
                .tabItem {
                    Label("Deal Calculator", systemImage: "dollarsign.circle.fill")
                }
            
            FlipCalculatorView()
                .tabItem {
                    Label("Flip", systemImage: "house.circle.fill")
                }
            
            MAOCalculatorView()
                .tabItem {
                    Label("MAO", systemImage: "chart.bar.doc.horizontal.fill")
                }
            
            ComparisonView()
                .tabItem {
                    Label("Compare", systemImage: "arrow.triangle.2.circlepath.circle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environmentObject(appState)
    }
}

#Preview {
    ContentView()
}
