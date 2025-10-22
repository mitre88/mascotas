//
//  FoodClassifier.swift
//  Mascotas
//
//  Created by Claude on 22/10/2025.
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

    // Función principal para analizar imagen
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

            // Usar VNClassifyImageRequest nativo de Apple
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

        // Usar programación funcional para filtrar y mapear alimentos
        let foodObservations = topResults.filter { observation in
            FoodCaloriesDatabase.isFood(observation.identifier)
        }

        // Si no encontramos alimentos, retornar resultado negativo
        guard !foodObservations.isEmpty else {
            return FoodAnalysisResult(
                items: [],
                totalCalories: 0,
                isFood: false,
                message: "⚠️ No se detectaron alimentos en la imagen"
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
