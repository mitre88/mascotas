//
//  FoodCaloriesDatabase.swift
//  Conta Calories
//
//  Created by Claude on 22/10/2025.
//

import Foundation

struct FoodCaloriesDatabase {
    // Base de datos de calorías por 100g o porción típica
    static let caloriesData: [String: (calories: Int, portion: String)] = [
        // Frutas
        "apple": (52, "100g"),
        "banana": (89, "100g"),
        "orange": (47, "100g"),
        "strawberry": (32, "100g"),
        "grape": (69, "100g"),
        "watermelon": (30, "100g"),
        "pineapple": (50, "100g"),
        "mango": (60, "100g"),
        "pear": (57, "100g"),
        "peach": (39, "100g"),

        // Verduras
        "broccoli": (34, "100g"),
        "carrot": (41, "100g"),
        "tomato": (18, "100g"),
        "lettuce": (15, "100g"),
        "cucumber": (16, "100g"),
        "pepper": (31, "100g"),
        "onion": (40, "100g"),
        "potato": (77, "100g"),
        "corn": (86, "100g"),
        "mushroom": (22, "100g"),

        // Proteínas
        "chicken": (239, "100g"),
        "beef": (250, "100g"),
        "pork": (242, "100g"),
        "fish": (206, "100g"),
        "salmon": (208, "100g"),
        "tuna": (132, "100g"),
        "egg": (155, "2 unidades"),
        "shrimp": (99, "100g"),

        // Lácteos
        "milk": (61, "1 taza"),
        "cheese": (402, "100g"),
        "yogurt": (59, "100g"),
        "butter": (717, "100g"),
        "cream": (345, "100g"),

        // Carbohidratos
        "bread": (265, "100g"),
        "rice": (130, "100g"),
        "pasta": (158, "100g"),
        "pizza": (266, "1 rebanada"),
        "bagel": (250, "1 unidad"),
        "tortilla": (218, "100g"),
        "oats": (389, "100g"),

        // Comida rápida
        "hamburger": (295, "1 unidad"),
        "hot dog": (290, "1 unidad"),
        "french fries": (312, "100g"),
        "burrito": (206, "1 unidad"),
        "taco": (226, "1 unidad"),
        "sandwich": (250, "1 unidad"),

        // Postres y dulces
        "cake": (257, "1 rebanada"),
        "cookie": (502, "100g"),
        "ice cream": (207, "100g"),
        "chocolate": (546, "100g"),
        "candy": (394, "100g"),
        "doughnut": (452, "1 unidad"),
        "brownie": (466, "1 unidad"),

        // Bebidas
        "coffee": (2, "1 taza"),
        "tea": (1, "1 taza"),
        "juice": (45, "1 taza"),
        "soda": (140, "1 lata"),
        "beer": (153, "1 lata"),
        "wine": (123, "1 copa"),

        // Snacks
        "chips": (536, "100g"),
        "popcorn": (375, "100g"),
        "nuts": (607, "100g"),
        "pretzel": (380, "100g"),

        // Comida mexicana
        "quesadilla": (300, "1 unidad"),
        "enchilada": (235, "1 unidad"),
        "tamale": (126, "1 unidad"),
        "guacamole": (160, "100g"),
        "salsa": (36, "100g"),

        // Asiática
        "sushi": (143, "1 rollo"),
        "ramen": (436, "1 tazón"),
        "fried rice": (163, "100g"),
        "dumpling": (41, "1 unidad"),

        // Otros
        "soup": (39, "1 tazón"),
        "salad": (33, "100g"),
        "wrap": (180, "1 unidad")
    ]

    // Palabras clave de alimentos para detección
    static let foodKeywords: Set<String> = [
        "food", "meal", "dish", "plate", "bowl",
        // Frutas
        "apple", "banana", "orange", "strawberry", "grape", "watermelon",
        "pineapple", "mango", "pear", "peach", "fruit",
        // Verduras
        "broccoli", "carrot", "tomato", "lettuce", "cucumber", "pepper",
        "onion", "potato", "corn", "mushroom", "vegetable",
        // Proteínas
        "chicken", "beef", "pork", "fish", "salmon", "tuna", "egg",
        "shrimp", "meat", "seafood",
        // Lácteos
        "milk", "cheese", "yogurt", "butter", "cream", "dairy",
        // Carbohidratos
        "bread", "rice", "pasta", "pizza", "bagel", "tortilla", "oats",
        "noodle", "cereal",
        // Comida rápida
        "hamburger", "burger", "hot dog", "french fries", "fries",
        "burrito", "taco", "sandwich",
        // Postres
        "cake", "cookie", "ice cream", "chocolate", "candy", "doughnut",
        "brownie", "dessert", "sweet",
        // Bebidas
        "coffee", "tea", "juice", "soda", "beer", "wine", "drink", "beverage",
        // Snacks
        "chips", "popcorn", "nuts", "pretzel", "snack",
        // Comida mexicana
        "quesadilla", "enchilada", "tamale", "guacamole", "salsa",
        // Asiática
        "sushi", "ramen", "fried rice", "dumpling",
        // Otros
        "soup", "salad", "wrap"
    ]

    // Función para buscar calorías de un alimento
    static func getCalories(for foodName: String) -> (calories: Int, portion: String)? {
        let normalizedName = foodName.lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Buscar coincidencia exacta
        if let data = caloriesData[normalizedName] {
            return data
        }

        // Buscar coincidencia parcial
        for (key, value) in caloriesData {
            if normalizedName.contains(key) || key.contains(normalizedName) {
                return value
            }
        }

        return nil
    }

    // Función para verificar si es alimento
    static func isFood(_ identifier: String) -> Bool {
        let normalizedIdentifier = identifier.lowercased()
        return foodKeywords.contains { keyword in
            normalizedIdentifier.contains(keyword)
        }
    }

    // Función para formatear nombre de alimento
    static func formatFoodName(_ identifier: String) -> String {
        let cleaned = identifier
            .components(separatedBy: ",").first ?? identifier
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")

        return cleaned
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}
