# 📊 Guía Completa de Monitoreo - Tic-Tac-Toe con IA

## 🎯 Objetivo

Esta guía te ayudará a monitorear el rendimiento del sistema mientras usas el juego Tic-Tac-Toe con IA, tanto en reposo como durante el uso activo.

## 🚀 Inicio Rápido

### ⚡ Comandos Principales

```bash
# Monitor visual en tiempo real (recomendado)
./monitor-visual.sh

# Monitor completo del sistema
./monitor-system.sh

# Monitor avanzado con herramientas especializadas
./monitor-advanced.sh

# Generar reporte de rendimiento automático
./benchmark-report.sh

# Monitor de latencia del teclado (NUEVO)
./monitor-latency.sh
```

## 📊 Tipos de Monitoreo Disponibles

### 1️⃣ Monitor Visual (`monitor-visual.sh`)
**🎯 Mejor para:** Monitoreo en tiempo real con interfaz bonita

**Características:**
- ✨ Interfaz visual con colores y barras de progreso
- 📊 Métricas en tiempo real (CPU, RAM, GPU, Red)
- 🎮 Estado de procesos específicos del juego
- 🏆 Top procesos por CPU/Memoria
- 📱 Modo compacto disponible

**Uso:**
```bash
./monitor-visual.sh              # Menú interactivo
./monitor-visual.sh --visual     # Monitor visual directo
./monitor-visual.sh --compact    # Modo compacto
./monitor-visual.sh --stats      # Estadísticas detalladas
```

### 2️⃣ Monitor del Sistema (`monitor-system.sh`)
**🎯 Mejor para:** Análisis completo y logging

**Características:**
- 📈 Monitoreo de CPU, Memoria, GPU, Disco, Red
- 🎮 Seguimiento específico de procesos del juego
- 📝 Guardado de logs para análisis posterior
- 🔍 Comparación estado reposo vs uso
- 📸 Snapshots únicos del sistema

**Uso:**
```bash
./monitor-system.sh                    # Menú interactivo
./monitor-system.sh --continuous 5     # Monitoreo cada 5 segundos
./monitor-system.sh --snapshot         # Snapshot único
./monitor-system.sh --compare          # Comparar reposo vs uso
```

### 3️⃣ Monitor Avanzado (`monitor-advanced.sh`)
**🎯 Mejor para:** Usuarios experimentados

**Características:**
- 🖥️ Herramientas especializadas (htop, iotop, nethogs, glances)
- 🎮 Monitor específico de GPU (nvtop)
- 📊 Dashboard personalizable
- 📝 Logging continuo en CSV
- 🔧 Instalación automática de herramientas

**Uso:**
```bash
./monitor-advanced.sh              # Menú con opciones
./monitor-advanced.sh --dashboard  # Dashboard directo
./monitor-advanced.sh --install    # Instalar herramientas
./monitor-advanced.sh --log        # Logging a archivo
```

### 4️⃣ Generador de Reportes (`benchmark-report.sh`)
**🎯 Mejor para:** Análisis profesional y reportes

**Características:**
- 📊 Reporte HTML completo con gráficos
- 🔍 Comparación automática reposo vs uso
- 📈 Métricas detalladas en formato JSON
- 💡 Conclusiones automáticas
- 📁 Historial de reportes

**Uso:**
```bash
./benchmark-report.sh           # Wizard interactivo
./benchmark-report.sh --auto    # Benchmark automático
./benchmark-report.sh --reports # Ver reportes anteriores
```

### 5️⃣ Monitor de Latencia del Teclado (`monitor-latency.sh`) 🆕
**🎯 Mejor para:** Diagnosticar y solucionar latencia de entrada

**Características:**
- ⌨️ Diagnóstico específico de latencia del teclado
- 🔍 Identificación de procesos problemáticos
- 🧹 Limpieza automática del sistema
- 💡 Recomendaciones personalizadas
- 📊 Monitor en tiempo real de recursos

**Uso:**
```bash
./monitor-latency.sh            # Monitor en tiempo real
./monitor-latency.sh --clean    # Limpiar sistema
./monitor-latency.sh --help     # Ayuda
```

**Cuándo usar:**
- Sientes que el teclado responde lento
- VS Code se siente "pesado"
- Autocompletado tarda mucho
- Quieres optimizar rendimiento

## ⌨️ Diagnóstico de Latencia del Teclado

### 🔍 Síntomas de Latencia:
- El teclado responde lento al escribir
- Autocompletado tarda en aparecer
- VS Code se siente "pesado"
- Delay entre presionar tecla y ver el carácter

### 📊 Causas Comunes:

| Causa | Impacto | Solución |
|-------|---------|----------|
| Extension Host sobrecargado | 🔴 Alto | Desactivar extensiones no esenciales |
| TypeScript Language Server x2 | 🟡 Medio | Optimizar configuración TS |
| Memoria insuficiente (>85%) | 🔴 Alto | Limpiar procesos, recargar VS Code |
| I/O de disco lento | 🟡 Medio | Limpiar cachés temporales |
| Conexión de red inestable | 🟡 Medio | Verificar conectividad |

### 🛠️ Herramientas de Diagnóstico:

```bash
# Monitor específico de latencia
./monitor-latency.sh

# Limpiar sistema para reducir latencia
./monitor-latency.sh --clean

# Monitor ligero del sistema
./monitor-visual.sh --compact
```

### ⚡ Soluciones Paso a Paso:

#### 1️⃣ **Diagnóstico Inmediato:**
```bash
# Ejecutar diagnóstico
./monitor-latency.sh
```

#### 2️⃣ **Optimización Automática:**
```bash
# Limpiar sistema
./monitor-latency.sh --clean

# Aplicar configuraciones optimizadas (ya aplicado)
# - TypeScript autocompletado desactivado
# - File watchers optimizados
# - Sugerencias rápidas deshabilitadas
```

#### 3️⃣ **Recargar VS Code:**
```
Ctrl+Shift+P > "Developer: Reload Window"
```

#### 4️⃣ **Desactivar Extensiones Temporalmente:**
- GitHub Copilot (si no se usa activamente)
- Linters no esenciales
- Temas pesados
- Extensiones de formateo automático

#### 5️⃣ **Optimización del Workspace:**
- Cerrar archivos/tabs innecesarios
- Cerrar terminales extra
- Minimizar paneles laterales

### 📊 Configuraciones Aplicadas Automáticamente:

```json
{
  "typescript.preferences.includePackageJsonAutoImports": "off",
  "typescript.suggest.autoImports": false,
  "typescript.disableAutomaticTypeAcquisition": true,
  "editor.quickSuggestions": false,
  "editor.parameterHints.enabled": false,
  "editor.wordBasedSuggestions": "off",
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true,
    "**/node_modules/**": true,
    "**/.hg/store/**": true,
    "**/tmp/**": true
  }
}
```

### 🎯 Métricas de Latencia Normal:

| Métrica | Normal | Problemático | Crítico |
|---------|--------|--------------|---------|
| Extension Host CPU | <5% | 5-10% | >10% |
| Extension Host Memoria | <1GB | 1-2GB | >2GB |
| TypeScript Servers | 1 proceso | 2 procesos | >2 procesos |
| Load Average | <1.0 | 1.0-2.0 | >2.0 |
| Memoria Total | <70% | 70-85% | >85% |

### 🔄 Monitoreo Continuo:

```bash
# Monitor en tiempo real (recomendado)
./monitor-latency.sh

# Monitor compacto para uso continuo
./monitor-visual.sh --compact

# Verificación rápida de estado
./monitor-system.sh --snapshot
```

### 💡 Prevención de Latencia:

1. **Reiniciar VS Code diariamente** en sesiones largas
2. **Limpiar cachés periódicamente** con `./monitor-latency.sh --clean`
3. **Monitorear uso de memoria** regularmente
4. **Desactivar extensiones** no esenciales para el proyecto actual
5. **Usar configuración optimizada** para proyectos grandes

---

## 📁 Ubicación de Archivos

### 📝 Logs y Reportes:
- **Monitor del sistema:** `/tmp/tic-tac-toe-monitor.log`
- **Snapshots:** `/tmp/tic-tac-toe-snapshot-TIMESTAMP.log`
- **Reportes HTML:** `/tmp/tic-tac-toe-reports/`
- **Datos JSON:** `/tmp/tic-tac-toe-reports/baseline_*.json`

### 🔧 Scripts de Monitoreo:
- **Monitor visual:** `./monitor-visual.sh`
- **Monitor sistema:** `./monitor-system.sh`  
- **Monitor avanzado:** `./monitor-advanced.sh`
- **Generador reportes:** `./benchmark-report.sh`

## 🚨 Alertas y Umbrales

### ⚠️ Alertas de Rendimiento:

| Condición | Nivel | Acción Recomendada |
|-----------|-------|-------------------|
| CPU > 90% | 🔴 Crítico | Revisar procesos, cerrar aplicaciones |
| Memoria > 85% | 🟡 Advertencia | Monitorear uso, considerar reinicio |
| Load > cores×2 | 🔴 Crítico | Investigar procesos bloqueantes |
| GPU > 95% | 🟡 Advertencia | Normal durante IA intensiva |
| Sin conexiones puerto 8000 | 🔴 Error | Servidor no funcionando |

### 🎮 Comportamiento Normal del Juego:

**En reposo (servidor parado):**
- CPU: 1-5%
- Memoria: Uso base del sistema
- Procesos: Solo sistema operativo

**Durante el juego:**
- CPU: 10-30% (picos durante IA)
- Memoria: +100-500MB
- Procesos: Python server + Ollama activos
- Red: 1-2 conexiones WebSocket

## 💡 Tips y Trucos

### 🚀 Optimización:
1. **Cerrar aplicaciones innecesarias** antes de jugar
2. **Monitorear en pantalla dividida** para observar en tiempo real
3. **Usar modo compacto** para menos consumo de recursos del monitor
4. **Generar reportes** periódicamente para tendencias

### 🐛 Debugging:
1. **Usar snapshots** antes y después de problemas
2. **Revisar logs** en `/tmp/` para errores
3. **Comparar** métricas entre sesiones diferentes
4. **Verificar conexiones** WebSocket si hay problemas de conectividad

### 📊 Análisis:
1. **Generar reportes HTML** para presentaciones
2. **Usar datos JSON** para análisis personalizado
3. **Comparar** diferentes configuraciones del sistema
4. **Documentar** comportamientos anómalos

## 🆘 Solución de Problemas

### ❌ "El monitor no funciona"
```bash
# Verificar dependencias
./monitor-visual.sh
# Opción 5: Instalar dependencias

# O manualmente:
sudo apt install -y bc procps iproute2 coreutils
```

### ❌ "No se detecta GPU"
```bash
# Para NVIDIA:
nvidia-smi

# Para AMD:
lspci | grep -i vga

# Instalar herramientas:
sudo apt install -y nvtop radeontop
```

### ❌ "Los reportes no se generan"
```bash
# Verificar jq:
sudo apt install -y jq bc

# Verificar permisos:
mkdir -p /tmp/tic-tac-toe-reports
chmod 755 /tmp/tic-tac-toe-reports
```

## 📞 Soporte

Si encuentras problemas:
1. **Revisar logs** en `/tmp/`
2. **Ejecutar con debug:** `bash -x ./monitor-visual.sh`
3. **Verificar requisitos** del sistema
4. **Consultar documentación** específica de cada herramienta

---

**🎮 ¡Feliz monitoreo y que disfrutes el juego!**
