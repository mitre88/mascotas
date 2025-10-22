# CaloriesAI

Una aplicación iOS nativa y moderna para analizar alimentos en fotos y calcular calorías usando inteligencia artificial y los frameworks de Apple.

## ✨ Características

- **Análisis de Alimentos**: Identifica automáticamente alimentos en fotos usando Vision Framework
- **Cálculo de Calorías**: Muestra calorías totales y desglose detallado por alimento
- **Cámara en Tiempo Real**: Toma fotos directamente con la cámara para análisis instantáneo
- **Selector de Galería**: Analiza fotos existentes de tu biblioteca sin usar la cámara
- **Detección Inteligente**: Notifica cuando la imagen no contiene alimentos
- **Interfaz Liquid Glass**: Diseño moderno con el estilo liquid glass de iOS 26
- **Base de Datos Extensa**: Incluye datos de calorías para más de 80 alimentos
- **Responsive Design**: Optimizado para iPhone y iPad
- **Animaciones Fluidas**: Transiciones suaves con spring physics

## 🛠 Tecnologías

- **SwiftUI**: Framework nativo de Apple para interfaces declarativas
- **Vision Framework**: Para clasificación de imágenes con Machine Learning nativo
- **AVFoundation**: Para captura de cámara de alta calidad
- **PhotosUI**: Para selección de fotos de la biblioteca
- **Concurrency**: Procesamiento asíncrono con DispatchQueue para máximo rendimiento
- **Programación Funcional**: Uso de filter, map, reduce para código eficiente

## 📱 Requisitos

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Cámara (opcional - también funciona con selector de fotos en simulador)

## 🚀 Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/mitre88/mascotas.git
cd mascotas
```

2. Abre el proyecto en Xcode:
```bash
open Mascotas.xcodeproj
```

3. Selecciona tu dispositivo o simulador

4. Presiona Cmd + R para compilar y ejecutar

### Uso en Simulador

El simulador no tiene cámara física, pero puedes usar la app completa con el selector de fotos:

1. Ejecuta la app en el simulador
2. Toca el botón morado de galería
3. Selecciona una foto de alimentos de tu biblioteca
4. La app analizará los alimentos y mostrará las calorías

Para agregar fotos al simulador, arrastra imágenes a la ventana del simulador o usa Safari para descargar fotos de alimentos.

## 🎨 Diseño

La aplicación utiliza el paradigma liquid glass de iOS 26:

- Efectos de desenfoque con `.ultraThinMaterial`
- Gradientes naranja/rojo vibrantes (tema de energía/calorías)
- Bordes con brillos y gradientes
- Sombras sutiles para profundidad
- Animaciones secuenciales (stagger effect) para resultados
- Spring physics para interacciones naturales

## 🏗 Arquitectura

El proyecto utiliza programación funcional y concurrencia:

- **@Observable**: State management reactivo en SwiftUI
- **Concurrency**: Procesamiento en background con DispatchQueue
- **Functional Programming**: Filter, map, reduce para transformación de datos
- **Separation of Concerns**: Lógica separada en módulos dedicados

### Estructura del Proyecto

```
Mascotas/
├── CaloriesAIApp.swift           # Punto de entrada de la app
├── ContentView.swift              # Vista principal con interfaz liquid glass
├── FoodClassifier.swift           # Clasificador de alimentos con Vision
├── FoodCaloriesDatabase.swift     # Base de datos de calorías (80+ alimentos)
├── FoodItem.swift                 # Modelo de datos para alimentos detectados
├── CameraManager.swift            # Manager para captura de cámara
├── CameraView.swift              # Vista de preview de cámara
├── ImagePicker.swift             # Selector de fotos de la biblioteca
├── Assets.xcassets/              # Recursos e ícono con llama
└── Info.plist                    # Configuración y permisos
```

## 🔐 Permisos

La aplicación solicita dos permisos:
- **Cámara**: Para tomar fotos de alimentos y analizarlas
- **Biblioteca de Fotos**: Para seleccionar fotos existentes de alimentos

Los permisos se solicitan automáticamente al usar cada función.

## 🍽️ Alimentos Soportados

La base de datos incluye información calórica para más de 80 alimentos:

- Frutas y verduras
- Carnes, pollo, pescado
- Pastas y granos
- Lácteos
- Postres y dulces
- Bebidas
- Y muchos más...

Para alimentos no reconocidos, la app proporciona estimaciones basadas en categorías similares.

## ⚡ Performance

- **Procesamiento Concurrente**: Análisis en background thread para UI fluida
- **Filtrado Inteligente**: Analiza top 15 resultados para balance entre precisión y velocidad
- **Límite de Resultados**: Máximo 8 alimentos mostrados para mejor UX
- **Prevención de Duplicados**: Sistema inteligente para evitar alimentos repetidos

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👨‍💻 Autor

Creado con SwiftUI y Vision Framework de Apple

---

**Nota**: Esta aplicación usa VNClassifyImageRequest nativo de Apple para clasificación de imágenes. La precisión de detección depende del modelo de Machine Learning integrado en iOS.
