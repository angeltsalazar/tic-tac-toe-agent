# 🎮 Tic-Tac-Toe con IA Agent

## ⚠️ CONFIGURACIÓN PARA GITHUB CODESPACES

**Si el tablero no aparece, lee:** [`CODESPACES-SETUP.md`](CODESPACES-SETUP.md)

### 🚀 Inicio Rápido en Codespaces

#### 🌐 Obtener TU URL específica:

**Método 1 - Comando automático:**
```bash
echo "🌐 TU URL: https://${CODESPACE_NAME}-8000.app.github.dev/"
```

**Método 2 - Script completo:**
```bash
./start-game.sh
```

**Método 3 - Panel PORTS:**
- Ve al panel "PORTS" en la parte inferior de VS Code
- Haz clic en el ícono 🌐 del puerto `8000`

#### 📝 Patrón de URLs de GitHub Codespaces:
```
https://[tu-codespace-name]-8000.app.github.dev/
```

**Ejemplos de URLs reales:**
- `https://super-duper-space-fortnight-w5ww5xqrwhwx9-8000.app.github.dev/`
- `https://magical-enigma-abc123xyz-8000.app.github.dev/`
- `https://friendly-invention-def456-8000.app.github.dev/`

#### 🚀 Pasos:

1. **Iniciar servidor:**
   ```bash
   cd server && python server.py
   ```

2. **Obtener tu URL y abrir en navegador:**
   ```bash
   # Esto te dará la URL exacta para TU Codespace:
   echo "https://${CODESPACE_NAME}-8000.app.github.dev/"
   ```

3. **⚠️ Recordatorios importantes:**
   - ✅ **USA** la URL de Codespaces
   - ❌ **NO uses** `localhost:8000` (no funciona en Codespaces)
   - 🔄 La URL es **única** para cada Codespace

---

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

## 📚 Documentación y Ayuda Disponible

### 🚀 Comandos Rápidos:
- **`./show-url.sh`** - Muestra tu URL específica al instante
- **`./start-game.sh`** - Detecta URL e inicia servidor automáticamente

### 📖 Archivos de Documentación:
- **[CODESPACES-SETUP.md](CODESPACES-SETUP.md)** - Guía completa de configuración para GitHub Codespaces
- **[URL-HELPER.md](URL-HELPER.md)** - Cómo encontrar tu URL específica de Codespaces  
- **[url-guide.html](url-guide.html)** - Página web interactiva para detectar tu URL

### 🐛 Debugging y Pruebas:
- **[debug.html](debug.html)** - Página de debugging con logs detallados
- **[test-forced.html](test-forced.html)** - Test del tablero forzado
- **[test-gameover.html](test-gameover.html)** - Test de mensajes de victoria
- **[test-reset.html](test-reset.html)** - Test de funcionalidad reset

### 🆘 Solución de Problemas (en orden):

| Problema | Solución |
|----------|----------|
| 🤔 "¿Cuál es mi URL?" | Ejecuta `./show-url.sh` |
| 📱 "El tablero no aparece" | Lee `CODESPACES-SETUP.md` |
| 🔗 "Error de conexión WebSocket" | Usa `debug.html` |
| 🔄 "El botón reset no funciona" | Usa `test-reset.html` |
| 🏆 "No veo mensajes de victoria" | Usa `test-gameover.html` |

### ⚡ Inicio Ultra-Rápido:
```bash
# Un solo comando para todo:
./start-game.sh

# O si solo quieres la URL:
./show-url.sh
```

## 📊 Monitoreo de Rendimiento del Sistema

### 🎯 ¿Quieres monitorear CPU, memoria, GPU mientras juegas?

**📖 Guía completa:** [`MONITOREO-GUIA.md`](MONITOREO-GUIA.md)

#### ⚡ Comandos Rápidos de Monitoreo:

```bash
# Monitor visual en tiempo real (RECOMENDADO)
./monitor-visual.sh

# Benchmark automático (reposo vs uso)
./benchmark-report.sh

# Monitor completo del sistema
./monitor-system.sh

# Monitor avanzado con herramientas especializadas
./monitor-advanced.sh

# Monitor de latencia del teclado (diagnosticar lentitud)
./monitor-latency.sh
```

#### 📊 Qué se Monitorea:
- **🔥 CPU:** Uso del procesador durante el juego
- **🧠 Memoria:** Consumo de RAM por el servidor y la IA
- **🎮 GPU:** Uso de tarjeta gráfica (si está disponible)
- **🌐 Red:** Conexiones WebSocket del juego
- **🐍 Servidor Python:** Rendimiento del backend
- **🤖 Ollama:** Uso de recursos por la IA
- **⌨️ Latencia:** Diagnóstico de respuesta lenta del teclado

#### 🎯 Casos de Uso:
- **Modo Visual:** Monitor en tiempo real con interfaz bonita
- **Modo Benchmark:** Reporte profesional HTML con gráficos
- **Modo Análisis:** Comparación reposo vs uso del juego
- **Modo Debugging:** Logs detallados para troubleshooting
- **Diagnóstico de Latencia:** Solucionar teclado lento en VS Code

#### ⌨️ ¿Teclado Lento en Sesiones Largas?
**Problema común:** Degradación del rendimiento en sesiones largas de Codespaces

**🚀 Soluciones por prioridad:**
```bash
# 1️⃣ Solución rápida (sin perder contexto)
./auto-optimize.sh clean

# 2️⃣ Monitor inteligente automático  
./latency-detector.sh monitor

# 3️⃣ Configuración optimizada para sesiones largas
./auto-optimize.sh setup

# 4️⃣ Si persiste: Ctrl+Shift+P > "Developer: Reload Window"
```

**🎯 Mejores prácticas:**
- **Prevención:** `./latency-detector.sh baseline` al iniciar
- **Monitoreo:** `./latency-detector.sh monitor` en background  
- **Corrección:** `./latency-detector.sh auto-fix` cuando se detecte
- **Último recurso:** Nueva sesión (solo si las anteriores fallan)

#### 📈 Métricas Típicas Durante el Juego:
- CPU: 10-30% (picos durante decisiones de IA)
- Memoria: +100-500MB adicionales
- Conexiones: 1-2 WebSocket activas
- Procesos: Python server + Ollama ejecutándose

**💡 Tip:** Ejecuta `./monitor-visual.sh` en una ventana separada mientras juegas para ver el impacto en tiempo real.