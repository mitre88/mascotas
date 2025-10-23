//
//  SplashView.swift
//  Conta Calories
//
//  Created by Claude on 22/10/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotateFlame = false
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            // Gradiente de fondo animado
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.3, blue: 0.2),
                    Color(red: 1.0, green: 0.5, blue: 0.1),
                    Color(red: 0.9, green: 0.3, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Logo con llama animada
                ZStack {
                    // Resplandor exterior
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .orange.opacity(0.5),
                                    .red.opacity(0.3),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: 20)
                        .scaleEffect(scale)

                    // Círculo de fondo con glass effect
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 160, height: 160)
                        .overlay {
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.8),
                                            .white.opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        }
                        .shadow(color: .black.opacity(0.3), radius: 30, y: 15)

                    // Icono de llama
                    Image(systemName: "flame.fill")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red, .pink],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(rotateFlame ? -10 : 10))
                        .shadow(color: .orange.opacity(0.6), radius: 20)
                }
                .scaleEffect(scale)
                .opacity(opacity)

                // Nombre de la app
                VStack(spacing: 12) {
                    Text("Conta Calories")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)

                    Text("Analiza calorías con IA")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(opacity)

                // Indicador de carga
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.3)
                    .opacity(opacity)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            // Animación de entrada
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }

            // Animación de llama
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                rotateFlame.toggle()
            }

            // Transición a la app después de 2.5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isActive = false
                }
            }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(false))
}
