//
//  CameraManager.swift
//  Conta Calories
//
//  Created by Claude on 22/10/2025.
//

import SwiftUI
import AVFoundation
import UIKit

@Observable
class CameraManager: NSObject {
    var capturedImage: UIImage?
    var isAuthorized = false
    var session: AVCaptureSession?
    var output: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    private let sessionQueue = DispatchQueue(label: "com.caloriesai.camera")

    override init() {
        super.init()
        checkAuthorization()
    }

    // Verificar autorización de cámara
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            requestAuthorization()
        default:
            isAuthorized = false
        }
    }

    // Solicitar autorización
    private func requestAuthorization() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.sessionQueue.resume()
                    self.setupCamera()
                }
            }
        }
    }

    // Configurar cámara
    func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            let session = AVCaptureSession()
            session.beginConfiguration()

            // Configurar entrada de video
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  session.canAddInput(videoInput) else {
                return
            }

            session.addInput(videoInput)

            // Configurar salida de foto
            let photoOutput = AVCapturePhotoOutput()
            guard session.canAddOutput(photoOutput) else { return }

            session.addOutput(photoOutput)
            session.sessionPreset = .photo

            session.commitConfiguration()

            DispatchQueue.main.async {
                self.session = session
                self.output = photoOutput
            }
        }
    }

    // Iniciar sesión de cámara
    func startSession() {
        sessionQueue.async { [weak self] in
            self?.session?.startRunning()
        }
    }

    // Detener sesión de cámara
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.session?.stopRunning()
        }
    }

    // Capturar foto
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let output = output else {
            completion(nil)
            return
        }

        sessionQueue.async {
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto

            let photoCaptureDelegate = PhotoCaptureDelegate { [weak self] image in
                DispatchQueue.main.async {
                    self?.capturedImage = image
                    completion(image)
                }
            }

            output.capturePhoto(with: settings, delegate: photoCaptureDelegate)
        }
    }
}

// Delegate para captura de fotos
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        super.init()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completion(nil)
            return
        }

        completion(image)
    }
}
