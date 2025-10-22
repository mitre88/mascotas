//
//  ContentView.swift
//  Mascotas
//
//  Created by Claude on 22/10/2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var cameraManager = CameraManager()
    @State private var classifier = PetClassifier()
    @State private var showResult = false
    @State private var capturedImage: UIImage?
    @State private var isFlashing = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradiente de fondo animado
                AnimatedGradientBackground()
                    .ignoresSafeArea()

                if cameraManager.isAuthorized, let session = cameraManager.session {
                    // Vista de cámara
                    CameraView(session: session)
                        .ignoresSafeArea()
                        .onAppear {
                            cameraManager.startSession()
                        }
                        .onDisappear {
                            cameraManager.stopSession()
                        }

                    // Overlay de interfaz con liquid glass
                    VStack {
                        // Header con efecto liquid glass
                        headerView
                            .padding(.top, geometry.safeAreaInsets.top)

                        Spacer()

                        // Resultados con liquid glass
                        if showResult {
                            resultView
                                .transition(.scale.combined(with: .opacity))
                        }

                        Spacer()

                        // Botones de control
                        controlButtons
                            .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showResult)

                    // Efecto de flash
                    if isFlashing {
                        Color.white
                            .ignoresSafeArea()
                            .opacity(0.8)
                            .transition(.opacity)
                    }
                } else {
                    // Vista de permisos
                    permissionView
                }
            }
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "pawprint.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Mascotas")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background {
                LiquidGlassCard()
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Result View
    private var resultView: some View {
        VStack(spacing: 16) {
            // Imagen capturada
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.5), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    }
                    .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            }

            VStack(spacing: 8) {
                if classifier.isProcessing {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                } else if !classifier.currentPrediction.isEmpty {
                    Text(classifier.currentPrediction)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)

                        Text("\(Int(classifier.confidence * 100))% confianza")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                } else if let error = classifier.errorMessage {
                    Text(error)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.red.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(24)
        .background {
            LiquidGlassCard()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 20) {
            if showResult {
                // Botón para nueva foto
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showResult = false
                        capturedImage = nil
                        classifier.reset()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background {
                            LiquidGlassButton(color: .blue)
                        }
                }
            }

            // Botón de captura
            Button {
                captureAndClassify()
            } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 70)
                        .overlay {
                            Circle()
                                .strokeBorder(.white.opacity(0.3), lineWidth: 4)
                                .frame(width: 82, height: 82)
                        }

                    if classifier.isProcessing {
                        ProgressView()
                            .tint(.black)
                    }
                }
                .shadow(color: .white.opacity(0.3), radius: 20, y: 5)
            }
            .disabled(classifier.isProcessing)
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Permission View
    private var permissionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Acceso a Cámara Necesario")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Para identificar razas de perros y gatos, necesitamos acceso a tu cámara")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Abrir Configuración")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background {
                        LiquidGlassButton(color: .blue)
                    }
            }
        }
        .padding(40)
    }

    // MARK: - Actions
    private func captureAndClassify() {
        // Efecto de flash
        withAnimation(.easeOut(duration: 0.15)) {
            isFlashing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeIn(duration: 0.15)) {
                isFlashing = false
            }
        }

        // Capturar foto
        cameraManager.capturePhoto { image in
            guard let image = image else { return }

            capturedImage = image
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showResult = true
            }

            // Clasificar
            classifier.classifyImage(image)
        }
    }
}

// MARK: - Liquid Glass Card Component
struct LiquidGlassCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .white.opacity(0.05),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.2),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
    }
}

// MARK: - Liquid Glass Button Component
struct LiquidGlassButton: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.4),
                                color.opacity(0.2),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.3, green: 0.2, blue: 0.8),
                Color(red: 0.8, green: 0.2, blue: 0.6),
                Color(red: 0.2, green: 0.6, blue: 0.9),
                Color(red: 0.5, green: 0.3, blue: 0.9)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
            ) {
                animateGradient.toggle()
            }
        }
    }
}

#Preview {
    ContentView()
}
