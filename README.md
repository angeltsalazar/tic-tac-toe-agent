# Características principales:
## 1. Arquitectura WebSocket 
- para comunicación en tiempo real

## 2. Separación de responsabilidades:
- game_agent.py: Lógica del agente AI
- game_logic.py: Reglas del juego
- server.py: Gestión de conexiones
- Frontend separado en HTML, CSS y JavaScript

## 3. Escalabilidad:
- Soporte para múltiples agentes
- Fácil extensión para diferentes niveles de dificultad
- Posibilidad de agregar más características

## 4. Mejores prácticas:
- Uso de TypeScript para mejor mantenimiento (opcional)
- Testing unitario
- Documentación clara
- Manejo de errores robusto

## 5. Recomendaciones de implementación:
- Implementar validación de movimientos
- Agregar sistema de puntuación
- Incluir diferentes niveles de dificultad
- Agregar animaciones para mejor UX
- Implementar modo multijugador

# How to Run

1. Start the FastAPI server
- Open a terminal and navigate to the project directory.
    - cd /Volumes/SSDWD2T/projects/tic-tac-toe-agent/server

- Run the following command to start the FastAPI server:
    - conda activate frame_pydanticai
    - uvicorn server:app --reload

2. Open client/index.html: Open the HTML file in your web browser.
    - http://localhost:8000