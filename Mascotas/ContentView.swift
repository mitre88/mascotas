//
//  ContentView.swift
//  Conta Calories
//
//  Created by Claude on 22/10/2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var cameraManager = CameraManager()
    @State private var foodClassifier = FoodClassifier()
    @State private var showResult = false
    @State private var capturedImage: UIImage?
    @State private var isFlashing = false
    @State private var showImagePicker = false
    @State private var showCamera = true
    @State private var animateCalories = false
    @State private var cameraReady = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradiente de fondo animado (siempre visible)
                AnimatedGradientBackground()
                    .ignoresSafeArea()

                // Vista de cámara cuando esté lista y no haya resultados
                if !showResult {
                    if showCamera && cameraReady && cameraManager.isAuthorized, let session = cameraManager.session {
                        CameraView(session: session)
                            .ignoresSafeArea()
                    } else {
                        // Placeholder mientras se carga la cámara o si no hay permisos
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()

                            VStack(spacing: 20) {
                                if !cameraManager.isAuthorized {
                                    // Sin permisos
                                    VStack(spacing: 16) {
                                        Image(systemName: "camera.circle.fill")
                                            .font(.system(size: 64))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.orange, .red],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: .orange.opacity(0.5), radius: 20)

                                        VStack(spacing: 8) {
                                            Text("Acceso a la Cámara")
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)

                                            Text("Necesitamos tu permiso para tomar fotos de tus alimentos")
                                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                                .foregroundColor(.white.opacity(0.8))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 32)
                                        }
                                    }
                                    .padding(32)
                                    .background {
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                                    }
                                    .padding(.horizontal, 24)
                                } else if !cameraReady {
                                    // Cargando cámara
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(1.5)

                                        Text("Preparando cámara...")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                            }
                        }
                    }
                }

                // Overlay de interfaz
                VStack(spacing: 0) {
                    // Header
                    headerView

                    Spacer()

                    // Resultados de análisis
                    if showResult {
                        resultView
                            .transition(.scale.combined(with: .opacity))
                            .padding(.horizontal, 20)
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
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $capturedImage)
                    .onDisappear {
                        if let image = capturedImage {
                            analyzeSelectedImage(image)
                        }
                    }
            }
            .onAppear {
                // Inicializar cámara al aparecer
                initializeCamera()
            }
            .onChange(of: cameraManager.session) { _, newSession in
                if newSession != nil && cameraManager.isAuthorized {
                    cameraReady = true
                    cameraManager.startSession()
                }
            }
            .onChange(of: cameraManager.isAuthorized) { _, isAuth in
                if isAuth && cameraManager.session != nil {
                    cameraReady = true
                    cameraManager.startSession()
                }
            }
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            // Degradado oscuro en la parte superior
            LinearGradient(
                colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.4),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .ignoresSafeArea(edges: .top)
            .overlay(alignment: .bottom) {
                HStack(alignment: .center, spacing: 12) {
                    // Ícono de llama
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.6), radius: 10)

                    // Título en una sola línea
                    Text("Conta Calories")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 8, y: 3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
    }

    // MARK: - Result View
    private var resultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Imagen capturada
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.5), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        }
                        .shadow(color: .black.opacity(0.3), radius: 15, y: 8)
                }

                if foodClassifier.isProcessing {
                    processingView
                } else if let result = foodClassifier.analysisResult {
                    if result.isFood {
                        foodResultView(result: result)
                    } else {
                        notFoodView(message: result.message ?? "No se detectaron alimentos")
                    }
                } else if let error = foodClassifier.errorMessage {
                    errorView(message: error)
                }
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
    }

    // Vista de procesamiento
    private var processingView: some View {
        VStack(spacing: 20) {
            // Spinner con ícono
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 60, height: 60)

                ProgressView()
                    .scaleEffect(1.3)
                    .tint(.white)
            }

            VStack(spacing: 8) {
                Text("Analizando tu comida")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Detectando alimentos y calculando calorías...")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 32)
        .background {
            LiquidGlassCard()
        }
    }

    // Vista de resultados de alimentos
    private func foodResultView(result: FoodAnalysisResult) -> some View {
        VStack(spacing: 16) {
            // Card de calorías totales
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Total de Calorías")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()
                }

                Text("\(result.totalCalories)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(animateCalories ? 1.0 : 0.5)
                    .opacity(animateCalories ? 1.0 : 0)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                            animateCalories = true
                        }
                    }

                Text("kcal")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background {
                LiquidGlassCard()
            }

            // Desglose de alimentos
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "list.bullet.rectangle.fill")
                        .foregroundColor(.white.opacity(0.9))

                    Text("Desglose por Alimento")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 4)

                ForEach(Array(result.items.enumerated()), id: \.element.id) { index, item in
                    FoodItemRow(item: item, index: index)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background {
                LiquidGlassCard()
            }
        }
    }

    // Vista cuando no es comida
    private func notFoodView(message: String) -> some View {
        VStack(spacing: 24) {
            // Ícono animado
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.3), .orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)

                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, value: showResult)
                    .shadow(color: .orange.opacity(0.5), radius: 15)
            }

            VStack(spacing: 12) {
                Text("No Detectamos Alimentos")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Intenta tomar otra foto con mejor iluminación o enfoca directamente a la comida")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 32)
        .background {
            LiquidGlassCard()
        }
    }

    // Vista de error
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            // Ícono de error
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.3), .pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .blur(radius: 10)

                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .red.opacity(0.5), radius: 15)
            }

            VStack(spacing: 8) {
                Text("Algo Salió Mal")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(message)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 32)
        .background {
            LiquidGlassCard()
        }
    }

    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 20) {
            if showResult {
                // Botón para nuevo análisis
                Button {
                    resetAnalysis()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background {
                            LiquidGlassButton(color: .blue)
                        }
                }
            } else {
                // Botón de galería
                Button {
                    showCamera = false
                    showImagePicker = true
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background {
                            LiquidGlassButton(color: .purple)
                        }
                }
                .disabled(foodClassifier.isProcessing)
            }

            // Botón de captura/cámara
            if !showResult {
                Button {
                    if cameraManager.isAuthorized && cameraReady {
                        showCamera = true
                        captureAndAnalyze()
                    } else if !cameraManager.isAuthorized {
                        cameraManager.checkAuthorization()
                    }
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

                        if foodClassifier.isProcessing || !cameraReady {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .shadow(color: .white.opacity(0.3), radius: 20, y: 5)
                }
                .disabled(foodClassifier.isProcessing || !cameraReady)
            }
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Actions
    private func captureAndAnalyze() {
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
            animateCalories = false

            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showResult = true
            }

            // Analizar alimentos
            foodClassifier.analyzeFood(image)
        }
    }

    private func analyzeSelectedImage(_ image: UIImage) {
        animateCalories = false

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showResult = true
        }

        // Analizar imagen seleccionada
        foodClassifier.analyzeFood(image)
    }

    private func resetAnalysis() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showResult = false
            capturedImage = nil
            animateCalories = false
            foodClassifier.reset()
            showCamera = true
        }

        // Reiniciar sesión de cámara
        if cameraManager.isAuthorized {
            cameraManager.startSession()
        }
    }

    private func initializeCamera() {
        // Verificar y solicitar autorización
        if !cameraManager.isAuthorized {
            cameraManager.checkAuthorization()
        }

        // Si ya está autorizado, iniciar la cámara
        if cameraManager.isAuthorized {
            // Dar tiempo para que la sesión se configure
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let _ = cameraManager.session {
                    cameraReady = true
                    cameraManager.startSession()
                }
            }
        }
    }
}

// MARK: - Food Item Row Component
struct FoodItemRow: View {
    let item: FoodItem
    let index: Int

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            // Icono de alimento
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundColor(.orange)

            // Nombre del alimento
            Text(item.name)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            // Calorías
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(item.calories) kcal")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(item.portionSize)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.1))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                }
        )
        .offset(x: appeared ? 0 : -50)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                appeared = true
            }
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
                Color(red: 0.9, green: 0.3, blue: 0.3),
                Color(red: 0.9, green: 0.5, blue: 0.2),
                Color(red: 0.8, green: 0.2, blue: 0.5),
                Color(red: 0.7, green: 0.3, blue: 0.7)
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
