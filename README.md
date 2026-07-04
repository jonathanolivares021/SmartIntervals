# ⏱️ SmartIntervals (Intervalos Inteligentes)

Una aplicación móvil y web intuitiva desarrollada en **Flutter** para la gestión precisa de tiempos de entrenamiento por intervalos (HIIT, rutinas de boxeo, tabata o circuitos funcionales).

---

## 🌟 Características Principales

* 🎯 **Configuración Totalmente Personalizable:** Ajusta de forma rápida los segundos de entrenamiento, segundos de descanso y el número total de rondas.
* 🔔 **Transiciones Auditivas Suaves (Audio Ducking):** Incorpora alertas de campana al finalizar cada intervalo. Gracias al uso de *Audio Ducking*, el sonido notifica al usuario reduciendo transitoriamente el volumen de la música de fondo (Spotify, YouTube Music, etc.) sin interrumpir la reproducción ni molestar con pitidos estridentes.
* 🎨 **Interfaz Dinámica (UI/UX):** Cambio visual en tiempo real de códigos de color entre fases (Naranja para **Entrenamiento**, Azul para **Descanso**) orientando al deportista a simple vista.
* ⏸️ **Control de Flujo:** Capacidad para pausar y reanudar la rutina en cualquier momento mediante temporizadores asíncronos eficientes.
* 📱 **Multiplataforma:** Compilable y optimizada para dispositivos **Android** y navegadores web (**Chrome**).

---

## 🛠️ Tecnologías y Librerías Utilizadas

* **Framework:** [Flutter](https://flutter.dev/) (SDK de UI de Google)
* **Lenguaje:** [Dart](https://dart.dev/)
* **Gestión de Audio:** Paquete externo [`audioplayers: ^6.0.0`](https://pub.dev/packages/audioplayers)
* **Entorno de Desarrollo:** Visual Studio Code & Git

---

## 🚀 Cómo ejecutar este proyecto localmente

Si deseas descargar y probar este código en tu propio computador, sigue estos sencillos pasos:

### 1. Prerrequisitos
Asegúrate de tener instalado y configurado en tu sistema:
* [SDK de Flutter](https://docs.flutter.dev/get-started/install) (agregado a las variables de entorno).
* Un editor de código como **Visual Studio Code** o **Android Studio**.

### 2. Clonar el repositorio
Abre tu terminal y descarga el proyecto:
```bash
git clone [https://github.com/jonathanolivares021/Intervalos-inteligentes.git](https://github.com/jonathanolivares021/Intervalos-inteligentes.git)
cd smart_intervals
