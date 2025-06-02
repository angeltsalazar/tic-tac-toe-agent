# 🚀 Guía de Mejores Prácticas para Sesiones Largas en Codespaces

## 🎯 Resumen del Problema

La **degradación del rendimiento del teclado** en sesiones largas de VS Code/Codespaces es un problema conocido causado por:

- **Acumulación de memoria** en Extension Host  
- **Múltiples instancias** de TypeScript Language Server
- **Cachés sobrecargados** de extensiones (GitHub Copilot, etc.)
- **Memory leaks** en widgets de chat y diálogos largos
- **I/O intensivo** por logs y archivos temporales

## ⚡ Soluciones por Nivel de Impacto

### 🥇 **Nivel 1: Optimización Sin Interrupciones** ⏱️ 30 segundos
```bash
# Limpieza automática del sistema
./auto-optimize.sh clean

# Verificar mejora
./latency-detector.sh check
```
**✅ Ventajas:** No pierdes contexto, solución rápida  
**❌ Limitaciones:** Puede no resolver problemas profundos

### 🥈 **Nivel 2: Recarga de VS Code** ⏱️ 1-2 minutos
```bash
# Configuración optimizada primero
./auto-optimize.sh setup

# Luego recargar VS Code
Ctrl+Shift+P > "Developer: Reload Window"
```
**✅ Ventajas:** Mantiene sesión de Codespaces, resuelve la mayoría de problemas  
**❌ Limitaciones:** Pierdes estado de debugging/extensiones

### 🥉 **Nivel 3: Nueva Sesión** ⏱️ 3-5 minutos
Solo cuando las anteriores fallan completamente.

## 🛡️ Estrategias Preventivas

### 🎯 **Al Iniciar Sesión Nueva:**
```bash
# 1. Establecer baseline de rendimiento
./latency-detector.sh baseline

# 2. Configurar optimizaciones
./auto-optimize.sh setup

# 3. Iniciar monitor automático (opcional)
./latency-detector.sh monitor &
```

### 🔄 **Durante Trabajo Regular:**
```bash
# Verificación rápida cada hora
./latency-detector.sh check

# Auto-limpieza cuando sea necesario
./auto-optimize.sh clean
```

### 📊 **Para Sesiones de +4 horas:**
```bash
# Monitor agresivo cada 3 minutos
./auto-optimize.sh start 180 deep &

# O detector inteligente cada 30 segundos
./latency-detector.sh monitor 30 &
```

## 🧠 Configuraciones Aplicadas Automáticamente

El script `./auto-optimize.sh setup` crea estas optimizaciones:

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
    "**/node_modules/**": true,
    "**/tmp/**": true,
    "**/*.log": true
  }
}
```

## 📈 Métricas de Rendimiento Normal

| Métrica | 🟢 Normal | 🟡 Atención | 🔴 Crítico |
|---------|------------|--------------|-------------|
| Extension Host | <500MB | 500MB-1GB | >1GB |
| Memoria Total | <70% | 70-85% | >85% |
| CPU Load | <1.0 | 1.0-2.0 | >2.0 |
| TypeScript Servers | 1 proceso | 2 procesos | >2 procesos |

## 🤖 Automatización Recomendada

### 🚀 **Setup Inicial (una vez por workspace):**
```bash
./auto-optimize.sh setup
./latency-detector.sh baseline
```

### 🔄 **Para Sesiones Largas (background):**
```bash
# Opción A: Auto-optimización conservadora
./auto-optimize.sh start &

# Opción B: Detector inteligente (recomendado)
./latency-detector.sh monitor &
```

### ⚡ **Cuando Sientes Latencia:**
```bash
# Verificación y auto-fix
./latency-detector.sh check
./latency-detector.sh auto-fix moderate
```

## 🔍 Debugging Avanzado

### 📊 **Análisis Detallado:**
```bash
# Estadísticas completas del sistema
./latency-detector.sh stats

# Monitor visual en tiempo real
./monitor-visual.sh

# Historial de rendimiento
cat /tmp/performance_monitor.log
```

### 🕵️ **Identificar Culpables:**
```bash
# Procesos pesados de VS Code
ps aux --sort=-%mem | grep -E "(vscode|extensionHost|typescript)"

# Archivos temporales grandes
find /tmp -name "*vscode*" -o -name "*.log" -exec du -h {} \; | sort -hr
```

## 💡 Tips Adicionales

### 🔧 **Configuración Manual (si los scripts no funcionan):**
1. **Desactivar extensiones temporalmente:** GitHub Copilot Chat, formatters pesados
2. **Cerrar tabs innecesarios:** Especialmente archivos grandes o logs
3. **Minimizar paneles:** Terminal, Output, Problems
4. **Configurar Git:** `git config --global core.preloadindex true`

### 🎯 **Indicadores de Que Necesitas Optimización:**
- Delay >200ms entre tecla y carácter en pantalla
- Autocompletado que tarda >2 segundos
- CPU constante >50% sin ejecutar código
- Memoria de Extension Host >1GB

### ⚠️ **Señales de Que Necesitas Nueva Sesión:**
- Recargas de VS Code no mejoran el rendimiento
- Limpieza automática no reduce memoria
- Latencia persiste después de todas las optimizaciones
- Errores de "Extension Host terminated unexpectedly"

## 🎮 Flujo Optimizado para este Proyecto

### 🚀 **Al Iniciar:**
```bash
# Configuración inicial
./auto-optimize.sh setup
./latency-detector.sh baseline

# Iniciar el juego normalmente  
./start-game.sh

# Monitor en background
./latency-detector.sh monitor 60 &
```

### 🎯 **Durante Desarrollo:**
```bash
# Verificación rápida cada hora
./latency-detector.sh check

# Si sientes latencia
./latency-detector.sh auto-fix
```

### 🔧 **Al Final del Día:**
```bash
# Limpiar antes de cerrar
./auto-optimize.sh clean
```

---

## 📞 Resumen de Comandos Clave

| Situación | Comando Recomendado |
|-----------|-------------------|
| **Nueva sesión** | `./auto-optimize.sh setup && ./latency-detector.sh baseline` |
| **Siento latencia** | `./latency-detector.sh auto-fix` |
| **Sesión larga (+4h)** | `./latency-detector.sh monitor &` |
| **Debug profundo** | `./latency-detector.sh stats` |
| **Limpieza rápida** | `./auto-optimize.sh clean` |
| **Último recurso** | `Ctrl+Shift+P > "Developer: Reload Window"` |

**🎯 Regla de oro:** Optimiza preventivamente, no esperes a que se ponga lento.
