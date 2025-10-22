# 🐾 Mascotas

Una aplicación iOS nativa y vibrante para identificar razas de perros y gatos usando la cámara y los frameworks de Apple.

## ✨ Características

- **Identificación en Tiempo Real**: Usa la cámara para identificar razas de perros y gatos instantáneamente
- **Selector de Fotos**: Elige imágenes de tu galería para clasificar sin necesidad de cámara
- **Funciona en Simulador**: Prueba la app en el simulador usando fotos de tu biblioteca
- **Interfaz Liquid Glass**: Diseño moderno con el estilo liquid glass de iOS 26
- **Vision Framework**: Utiliza los modelos de Machine Learning nativos de Apple para clasificación de imágenes
- **Responsive Design**: Optimizado para iPhone y iPad (incluyendo iPad de 13 pulgadas)
- **Experiencia Fluida**: Animaciones suaves y transiciones naturales
- **Colores Vibrantes**: Gradientes animados y una paleta de colores dinámica

## 🛠 Tecnologías

- **SwiftUI**: Framework nativo de Apple para interfaces de usuario declarativas
- **Vision Framework**: Para procesamiento de imágenes y clasificación con ML
- **Core ML**: Modelos de Machine Learning optimizados para iOS
- **AVFoundation**: Para captura de cámara de alta calidad
- **PhotosUI**: Para selección de fotos de la biblioteca
- **Concurrency**: Uso de async/await y GCD para operaciones concurrentes

## 📱 Requisitos

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Dispositivo con cámara (opcional - también funciona con selector de fotos en simulador)

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

El simulador no tiene acceso a la cámara física, pero puedes usar la app completa con el selector de fotos:

1. Ejecuta la app en el simulador
2. Toca el botón morado de galería (ícono de foto)
3. Selecciona una foto de perro o gato de tu biblioteca
4. La app clasificará la raza automáticamente

Para agregar fotos al simulador, arrastra imágenes a la ventana del simulador o usa Safari en el simulador para descargar fotos.

## 🎨 Diseño

La aplicación utiliza el paradigma de diseño liquid glass de iOS 26, que incluye:

- Efectos de desenfoque y transparencia (`.ultraThinMaterial`)
- Gradientes suaves y animados
- Bordes con gradientes y brillos
- Sombras sutiles para profundidad
- Animaciones con spring physics para interacciones naturales

## 🏗 Arquitectura

El proyecto sigue principios de programación funcional y utiliza:

- **@Observable**: Para state management reactivo
- **Concurrency**: Operaciones asíncronas con DispatchQueue y async/await
- **Separation of Concerns**: Lógica separada en managers dedicados
- **SwiftUI Best Practices**: Componentes reutilizables y composables

### Estructura del Proyecto

```
Mascotas/
├── MascotasApp.swift          # Punto de entrada de la app
├── ContentView.swift           # Vista principal con interfaz liquid glass
├── CameraManager.swift         # Manager para captura de cámara
├── CameraView.swift           # Vista de preview de cámara
├── ImagePicker.swift          # Selector de fotos de la biblioteca
├── PetClassifier.swift        # Clasificador usando Vision Framework
├── Assets.xcassets/           # Recursos e íconos
└── Info.plist                 # Configuración y permisos
```

## 🔐 Permisos

La aplicación solicita dos permisos opcionales:
- **Cámara**: Para tomar fotos en tiempo real y clasificarlas
- **Biblioteca de Fotos**: Para seleccionar imágenes existentes y clasificarlas

Los permisos se solicitan automáticamente cuando intentas usar cada función.

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👨‍💻 Autor

Creado con ❤️ usando Swift y SwiftUI

---

**Nota**: Esta aplicación usa el modelo MobileNetV2 incluido en Core ML para clasificación de imágenes. Para mejores resultados con mascotas específicas, considera entrenar un modelo personalizado con Core ML Tools.
