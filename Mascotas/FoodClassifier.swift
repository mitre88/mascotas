//
//  FoodClassifier.swift
//  Conta Calories
//
//  Created by Claude on 22/10/2025.
//
//  FOUNDATION MODELS:
//  - Usa Vision Framework de Apple (Foundation Model nativo de iOS)
//  - VNClassifyImageRequest: Modelo de clasificación de imágenes pre-entrenado
//  - Modelos de ML integrados en el sistema operativo
//  - Optimizado para rendimiento y privacidad en el dispositivo
//

import SwiftUI
import Vision
import UIKit

@Observable
class FoodClassifier {
    var analysisResult: FoodAnalysisResult?
    var isProcessing: Bool = false
    var errorMessage: String?

    private let predictionQueue = DispatchQueue(label: "com.calories.prediction", qos: .userInitiated)
    private let maxResultsToAnalyze = 15 // Analizar top 15 resultados para mejor detección

    // Función principal para analizar imagen usando Vision Framework (Foundation Model)
    func analyzeFood(_ image: UIImage) {
        guard !isProcessing else { return }

        isProcessing = true
        errorMessage = nil
        analysisResult = nil

        predictionQueue.async { [weak self] in
            guard let self = self else { return }

            guard let ciImage = CIImage(image: image) else {
                DispatchQueue.main.async {
                    self.errorMessage = "No se pudo procesar la imagen"
                    self.isProcessing = false
                }
                return
            }

            // ⭐️ FOUNDATION MODEL: VNClassifyImageRequest
            // Este es el modelo de clasificación nativo de Apple Vision Framework
            // Pre-entrenado con miles de categorías de objetos, incluidos alimentos
            // Ejecuta completamente en el dispositivo para privacidad y velocidad
            let request = VNClassifyImageRequest { [weak self] request, error in
                guard let self = self else { return }

                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error en análisis: \(error.localizedDescription)"
                        self.isProcessing = false
                    }
                    return
                }

                guard let results = request.results as? [VNClassificationObservation] else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No se encontraron resultados"
                        self.isProcessing = false
                    }
                    return
                }

                // Procesar resultados de manera concurrente
                let analysisResult = self.processResults(results)

                DispatchQueue.main.async {
                    self.analysisResult = analysisResult
                    self.isProcessing = false
                }
            }

            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error al procesar: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }

    // Procesar resultados y extraer alimentos con calorías
    private func processResults(_ results: [VNClassificationObservation]) -> FoodAnalysisResult {
        var detectedFoods: [FoodItem] = []
        var totalCalories = 0

        // Analizar top resultados
        let topResults = Array(results.prefix(maxResultsToAnalyze))

        // Debug: Imprimir top 10 resultados para ver qué detecta Vision
        print("🔍 Vision detectó:")
        for (index, result) in topResults.prefix(10).enumerated() {
            print("  \(index + 1). \(result.identifier) - \(Int(result.confidence * 100))%")
        }

        // Usar programación funcional para filtrar y mapear alimentos
        let foodObservations = topResults.filter { observation in
            FoodCaloriesDatabase.isFood(observation.identifier)
        }

        print("🍽️ Alimentos detectados: \(foodObservations.count)")

        // Si no encontramos alimentos, retornar resultado negativo
        guard !foodObservations.isEmpty else {
            // Intentar detectar alimentos de forma más agresiva
            // Buscar en TODOS los resultados si alguno tiene palabras relacionadas con comida
            let possibleFoods = topResults.filter { observation in
                let id = observation.identifier.lowercased()
                return id.contains("food") || id.contains("dish") ||
                       id.contains("plate") || id.contains("meal") ||
                       id.contains("snack") || id.contains("dessert") ||
                       observation.confidence > 0.5
            }

            if possibleFoods.isEmpty {
                return FoodAnalysisResult(
                    items: [],
                    totalCalories: 0,
                    isFood: false,
                    message: "⚠️ No se detectaron alimentos en la imagen"
                )
            }

            // Usar los posibles alimentos
            for observation in possibleFoods {
                let identifier = observation.identifier.lowercased()
                let formattedName = FoodCaloriesDatabase.formatFoodName(identifier)

                // Estimar calorías basadas en la categoría genérica
                let estimatedCalories = estimateCalories(for: identifier, confidence: observation.confidence)

                let foodItem = FoodItem(
                    name: formattedName,
                    calories: estimatedCalories,
                    confidence: Double(observation.confidence),
                    portionSize: "porción"
                )

                detectedFoods.append(foodItem)
                totalCalories += estimatedCalories

                if detectedFoods.count >= 5 {
                    break
                }
            }

            if detectedFoods.isEmpty {
                return FoodAnalysisResult(
                    items: [],
                    totalCalories: 0,
                    isFood: false,
                    message: "⚠️ No se detectaron alimentos en la imagen"
                )
            }

            detectedFoods.sort { $0.confidence > $1.confidence }

            return FoodAnalysisResult(
                items: detectedFoods,
                totalCalories: totalCalories,
                isFood: true,
                message: nil
            )
        }

        // Procesar cada alimento detectado
        var processedNames = Set<String>() // Evitar duplicados

        for observation in foodObservations {
            let identifier = observation.identifier.lowercased()

            // Formatear nombre
            let formattedName = FoodCaloriesDatabase.formatFoodName(identifier)

            // Evitar duplicados
            guard !processedNames.contains(formattedName.lowercased()) else { continue }
            processedNames.insert(formattedName.lowercased())

            // Buscar calorías
            if let calorieData = FoodCaloriesDatabase.getCalories(for: identifier) {
                let foodItem = FoodItem(
                    name: formattedName,
                    calories: calorieData.calories,
                    confidence: Double(observation.confidence),
                    portionSize: calorieData.portion
                )

                detectedFoods.append(foodItem)
                totalCalories += calorieData.calories
            } else if observation.confidence > 0.3 {
                // Si no tenemos datos de calorías pero la confianza es alta, usar estimación
                let estimatedCalories = estimateCalories(for: identifier, confidence: observation.confidence)
                let foodItem = FoodItem(
                    name: formattedName,
                    calories: estimatedCalories,
                    confidence: Double(observation.confidence),
                    portionSize: "100g"
                )

                detectedFoods.append(foodItem)
                totalCalories += estimatedCalories
            }

            // Limitar a 8 alimentos para mejor UX
            if detectedFoods.count >= 8 {
                break
            }
        }

        // Ordenar por confianza (mayor a menor)
        detectedFoods.sort { $0.confidence > $1.confidence }

        return FoodAnalysisResult(
            items: detectedFoods,
            totalCalories: totalCalories,
            isFood: !detectedFoods.isEmpty,
            message: nil
        )
    }

    // Estimación de calorías cuando no tenemos datos exactos
    private func estimateCalories(for identifier: String, confidence: Float) -> Int {
        let id = identifier.lowercased()

        // Estimaciones basadas en categorías
        if id.contains("fruit") || id.contains("berry") {
            return 50
        } else if id.contains("vegetable") || id.contains("salad") {
            return 25
        } else if id.contains("meat") || id.contains("chicken") || id.contains("beef") {
            return 250
        } else if id.contains("bread") || id.contains("pasta") || id.contains("rice") {
            return 150
        } else if id.contains("dessert") || id.contains("cake") || id.contains("sweet") {
            return 300
        } else if id.contains("drink") || id.contains("beverage") {
            return 100
        } else {
            // Estimación general basada en confianza
            return Int(150.0 * Double(confidence))
        }
    }

    // Función para resetear
    func reset() {
        analysisResult = nil
        errorMessage = nil
    }
}
