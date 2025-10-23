//
//  CaloriesAIApp.swift
//  Conta Calories
//
//  Created by Claude on 22/10/2025.
//

import SwiftUI

@main
struct ContaCaloriesApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView(isActive: $showSplash)
            } else {
                ContentView()
            }
        }
    }
}
