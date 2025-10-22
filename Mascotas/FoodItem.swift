//
//  FoodItem.swift
//  CaloriesAI
//
//  Created by Claude on 22/10/2025.
//

import Foundation

struct FoodItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let calories: Int
    let confidence: Double
    let portionSize: String

    var caloriesPerServing: String {
        "\(calories) kcal"
    }
}

struct FoodAnalysisResult {
    let items: [FoodItem]
    let totalCalories: Int
    let isFood: Bool
    let message: String?

    var itemsDescription: String {
        items.map { $0.name }.joined(separator: ", ")
    }
}
