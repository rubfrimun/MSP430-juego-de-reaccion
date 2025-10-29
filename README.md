# MSP430-juego-de-reaccion
Proyecto universitario para el microcontrolador MSP430FR6989. Un juego de reacción de tiempo programado en C y ensamblador.
# Juego de Reacción con Microcontrolador MSP430FR6989

> Proyecto final para la asignatura "Sistemas Basados en Microprocesador" de la Universidad de Sevilla. El objetivo es desarrollar un juego de precisión temporal utilizando programación mixta en C y Ensamblador para la placa de desarrollo MSP-EXP430FR6989.

<img width="640" height="360" alt="msp-exp430fr6989-angled" src="https://github.com/user-attachments/assets/a3ba7ae2-eb67-4de2-bbe0-5067d27f06b8" />

---

### 📝 Descripción del Proyecto

La aplicación consiste en un juego de dos fases:

1.  **Fase de Generación:** Al pulsar el botón SW1, se genera un número pseudoaleatorio entre 10 y 99. Este número, el "objetivo", se muestra en el display LCD.
2.  **Fase de Medición:** El usuario debe mantener pulsado el botón SW2 durante un tiempo que intente igualar el número "objetivo" en segundos. Al soltar el botón, el LCD muestra:
    *   El tiempo que el botón estuvo pulsado.
    *   La diferencia (con signo) entre el tiempo medido y el objetivo.

El proyecto pone en práctica la gestión de periféricos, interrupciones, modos de bajo consumo y la interacción entre código de alto y bajo nivel.

---

### 🛠️ Stack Tecnológico

*   **Lenguajes:** C y Ensamblador (Assembly)
*   **Hardware:** Microcontrolador Texas Instruments MSP430FR6989
*   **Periféricos:**
    *   Display LCD (on-board)
    *   Pulsadores (SW1, SW2) para entrada de usuario
    *   Timer_A para temporización precisa y gestión de interrupciones.
*   **Conceptos Clave:**
    *   Manejo de interrupciones de periféricos (GPIO y Timers).
    *   Modos de bajo consumo (LPM3) para eficiencia energética.
    *   Arquitectura de software basada en un bucle principal (super-loop) y rutinas de servicio de interrupción (ISR).
    *   Generación de números pseudoaleatorios utilizando el `system timer`.

---

### 📂 Estructura del Código

*   `main.c`: Contiene la lógica principal del juego, la inicialización del sistema y el bucle principal.
*   `syst.asm`: Módulo en ensamblador que gestiona el `system timer`, proporcionando una base de tiempo precisa para todo el sistema.
*   `lcd.asm`: Módulo en ensamblador con las rutinas de bajo nivel para controlar el display LCD (inicialización, borrado, escritura de caracteres).
*   `documentacion_tecnica.pdf`: Documento detallado con el análisis de la arquitectura de software, incluyendo la descripción de todas las variables y funciones del programa.

---

### 🚀 Cómo Probarlo

Este proyecto está diseñado para ser compilado y cargado en una placa de desarrollo **MSP-EXP430FR6989 LaunchPad** utilizando un entorno como **Code Composer Studio** de Texas Instruments.
