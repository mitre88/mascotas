//
//  PetClassifier.swift
//  Mascotas
//
//  Created by Claude on 22/10/2025.
//

import SwiftUI
import Vision
import UIKit

@Observable
class PetClassifier {
    var currentPrediction: String = ""
    var confidence: Double = 0.0
    var isProcessing: Bool = false
    var errorMessage: String?

    private let predictionQueue = DispatchQueue(label: "com.mascotas.prediction", qos: .userInitiated)

    // Función para clasificar la imagen usando Vision framework
    func classifyImage(_ image: UIImage) {
        guard !isProcessing else { return }

        isProcessing = true
        errorMessage = nil

        predictionQueue.async { [weak self] in
            guard let self = self else { return }

            guard let ciImage = CIImage(image: image) else {
                DispatchQueue.main.async {
                    self.errorMessage = "No se pudo procesar la imagen"
                    self.isProcessing = false
                }
                return
            }

            // Usar el clasificador de imágenes nativo de Apple (VNClassifyImageRequest)
            // Este clasificador usa modelos pre-entrenados incluidos en iOS
            let request = VNClassifyImageRequest { [weak self] request, error in
                guard let self = self else { return }

                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error en clasificación: \(error.localizedDescription)"
                        self.isProcessing = false
                    }
                    return
                }

                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No se encontraron resultados"
                        self.isProcessing = false
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.processPrediction(topResult, allResults: results)
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

    // Procesar y filtrar predicciones para encontrar razas de perros y gatos
    private func processPrediction(_ topResult: VNClassificationObservation, allResults: [VNClassificationObservation]) {
        // Filtrar resultados para encontrar razas de perros y gatos
        let petResults = allResults.filter { observation in
            let identifier = observation.identifier.lowercased()
            return isDogBreed(identifier) || isCatBreed(identifier)
        }

        if let bestPet = petResults.first {
            let breedName = formatBreedName(bestPet.identifier)
            currentPrediction = breedName
            confidence = Double(bestPet.confidence)
        } else {
            // Si no encontramos mascotas específicas, usar el resultado general
            currentPrediction = formatBreedName(topResult.identifier)
            confidence = Double(topResult.confidence)
        }
    }

    // Verificar si es una raza de perro
    private func isDogBreed(_ identifier: String) -> Bool {
        let dogKeywords = ["dog", "puppy", "retriever", "bulldog", "poodle", "shepherd",
                          "terrier", "spaniel", "hound", "setter", "pointer", "collie",
                          "husky", "corgi", "beagle", "chihuahua", "dachshund", "pug",
                          "rottweiler", "doberman", "boxer", "mastiff", "schnauzer"]
        return dogKeywords.contains { identifier.contains($0) }
    }

    // Verificar si es una raza de gato
    private func isCatBreed(_ identifier: String) -> Bool {
        let catKeywords = ["cat", "kitten", "tabby", "persian", "siamese", "egyptian",
                          "tiger_cat", "lynx"]
        return catKeywords.contains { identifier.contains($0) }
    }

    // Formatear el nombre de la raza
    private func formatBreedName(_ identifier: String) -> String {
        // Remover números y guiones bajos, capitalizar
        let cleaned = identifier
            .components(separatedBy: ",").first ?? identifier
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")

        // Capitalizar cada palabra
        return cleaned
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    func reset() {
        currentPrediction = ""
        confidence = 0.0
        errorMessage = nil
    }
}
