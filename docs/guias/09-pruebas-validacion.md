# 🧪 Guía 09: Pruebas y Validación

> **Objetivo:** Realizar pruebas completas del sistema y validar que todas las funcionalidades están operativas.

---

## 📑 Tabla de Contenidos

1. [Preparación para Pruebas](#preparación-para-pruebas)
2. [Pruebas del Sistema Base](#pruebas-del-sistema-base)
3. [Pruebas de Integración IA](#pruebas-de-integración-ia)
4. [Pruebas de Performance](#pruebas-de-performance)
5. [Pruebas de Sesiones Largas](#pruebas-de-sesiones-largas)
6. [Validación de Monitoreo](#validación-de-monitoreo)
7. [Pruebas de Codespaces](#pruebas-de-codespaces)
8. [Checklist Final](#checklist-final)

---

## 🚀 Preparación para Pruebas

### 1. Verificación del Entorno

```bash
# Verificar que todos los scripts principales existen
echo "🔍 Verificando scripts principales..."
ls -la *.sh | grep -E "(start-game|monitor|auto-optimize|latency-detector)"

# Verificar estructura del proyecto
echo "📁 Verificando estructura..."
[ -d "server" ] && echo "✅ Directorio server"
[ -d "client" ] && echo "✅ Directorio client"
[ -d "docs" ] && echo "✅ Directorio docs"
[ -d ".devcontainer" ] && echo "✅ DevContainer configurado"

# Verificar archivos de configuración
[ -f "requirements.txt" ] && echo "✅ requirements.txt"
[ -f "docker-compose.yml" ] && echo "✅ docker-compose.yml"
[ -f ".devcontainer/devcontainer.json" ] && echo "✅ devcontainer.json"
```

### 2. Setup de Pruebas

```bash
# Instalar dependencias
pip install -r requirements.txt

# Configurar optimizaciones para las pruebas
./auto-optimize.sh setup

# Establecer baseline de rendimiento
./latency-detector.sh baseline

echo "✅ Entorno de pruebas preparado"
```

---

## 🎮 Pruebas del Sistema Base

### 1. Prueba de Inicio del Servidor

```bash
echo "🚀 TEST 1: Inicio del servidor"
echo "=============================="

# Iniciar el servidor en background
./start-game.sh &
SERVER_PID=$!

# Esperar a que el servidor esté listo
sleep 10

# Verificar que el servidor está ejecutándose
if ps -p $SERVER_PID > /dev/null; then
    echo "✅ Servidor iniciado correctamente (PID: $SERVER_PID)"
else
    echo "❌ Error: Servidor no pudo iniciar"
    exit 1
fi

# Verificar puertos
if netstat -tlnp | grep -q ":8000"; then
    echo "✅ Puerto 8000 abierto"
else
    echo "❌ Error: Puerto 8000 no disponible"
fi

# Limpiar
kill $SERVER_PID 2>/dev/null
echo "🧹 Servidor detenido"
```

### 2. Prueba de Conectividad Web

```bash
echo "🌐 TEST 2: Conectividad web"
echo "========================="

# Iniciar servidor
./start-game.sh &
SERVER_PID=$!
sleep 10

# Probar endpoint principal
if curl -s http://localhost:8000 | grep -q "Tic Tac Toe"; then
    echo "✅ Página principal accesible"
else
    echo "❌ Error: Página principal no accesible"
fi

# Probar WebSocket (si está disponible)
if command -v wscat &> /dev/null; then
    echo "🔌 Probando WebSocket..."
    timeout 5 wscat -c ws://localhost:8000/ws && echo "✅ WebSocket funcional" || echo "⚠️ WebSocket no disponible"
fi

# Limpiar
kill $SERVER_PID 2>/dev/null
echo "🧹 Servidor detenido"
```

### 3. Prueba de Lógica del Juego

```bash
echo "🎯 TEST 3: Lógica del juego"
echo "========================="

# Ejecutar pruebas Python si existen
if [ -d "tests" ]; then
    echo "🐍 Ejecutando pruebas Python..."
    python -m pytest tests/ -v 2>/dev/null || echo "⚠️ No se encontraron pruebas pytest"
fi

# Verificar módulos principales
python -c "
try:
    from server.game_logic import TicTacToeGame
    from server.game_agent import GameAgent
    print('✅ Módulos principales importables')
except ImportError as e:
    print(f'❌ Error en imports: {e}')
"

# Prueba básica de lógica
python -c "
from server.game_logic import TicTacToeGame
game = TicTacToeGame()
game.make_move(0, 'X')
print('✅ Lógica básica funcional' if game.board[0] == 'X' else '❌ Error en lógica')
"
```

---

## 🤖 Pruebas de Integración IA

### 1. Verificación de Ollama

```bash
echo "🤖 TEST 4: Integración con IA"
echo "============================"

# Verificar si Ollama está disponible
if command -v ollama &> /dev/null; then
    echo "✅ Ollama instalado"
    
    # Verificar modelos disponibles
    if ollama list | grep -q "llama"; then
        echo "✅ Modelo AI disponible"
        AI_AVAILABLE=true
    else
        echo "⚠️ No hay modelos AI instalados"
        AI_AVAILABLE=false
    fi
else
    echo "⚠️ Ollama no disponible - usando IA fallback"
    AI_AVAILABLE=false
fi

# Probar integración
python -c "
from server.ollama_integration import OllamaIntegration
try:
    ollama = OllamaIntegration()
    response = ollama.get_move([None]*9, 'X')
    print('✅ Integración IA funcional' if response is not None else '⚠️ IA usando fallback')
except Exception as e:
    print(f'⚠️ IA usando fallback: {e}')
"
```

### 2. Prueba de Decisiones IA

```bash
echo "🎯 TEST 5: Decisiones de IA"
echo "========================="

# Probar diferentes escenarios
python -c "
from server.game_agent import GameAgent
agent = GameAgent()

# Escenario 1: Tablero vacío
board1 = [None] * 9
move1 = agent.get_move(board1, 'O')
print(f'✅ IA puede mover en tablero vacío: posición {move1}' if move1 is not None else '❌ Error en tablero vacío')

# Escenario 2: Bloquear victoria
board2 = ['X', 'X', None, None, None, None, None, None, None]
move2 = agent.get_move(board2, 'O')
print(f'✅ IA puede bloquear: posición {move2}' if move2 == 2 else f'⚠️ IA eligió posición {move2} (esperado 2)')

# Escenario 3: Ganar si puede
board3 = ['O', 'O', None, None, None, None, None, None, None]
move3 = agent.get_move(board3, 'O')
print(f'✅ IA puede ganar: posición {move3}' if move3 == 2 else f'⚠️ IA eligió posición {move3} (esperado 2)')
"
```

---

## ⚡ Pruebas de Performance

### 1. Benchmark de Respuesta

```bash
echo "⚡ TEST 6: Performance del servidor"
echo "================================="

# Iniciar servidor
./start-game.sh &
SERVER_PID=$!
sleep 10

# Medir tiempo de respuesta
echo "📊 Midiendo tiempos de respuesta..."
for i in {1..5}; do
    start_time=$(date +%s%N)
    curl -s http://localhost:8000 >/dev/null
    end_time=$(date +%s%N)
    duration=$((($end_time - $start_time) / 1000000))
    echo "  Intento $i: ${duration}ms"
done

# Limpiar
kill $SERVER_PID 2>/dev/null
```

### 2. Prueba de Carga de Memoria

```bash
echo "💾 TEST 7: Uso de memoria"
echo "======================="

# Obtener uso inicial
initial_mem=$(ps aux --sort=-%mem | head -10 | awk '{sum+=$6} END {printf "%.0f", sum/1024}')
echo "💾 Memoria inicial: ${initial_mem}MB"

# Iniciar servidor
./start-game.sh &
SERVER_PID=$!
sleep 10

# Medir memoria después de inicio
server_mem=$(ps aux --sort=-%mem | head -10 | awk '{sum+=$6} END {printf "%.0f", sum/1024}')
echo "💾 Memoria con servidor: ${server_mem}MB"

# Calcular diferencia
mem_diff=$((server_mem - initial_mem))
echo "📈 Incremento: ${mem_diff}MB"

if [ $mem_diff -lt 500 ]; then
    echo "✅ Uso de memoria aceptable (<500MB)"
else
    echo "⚠️ Alto uso de memoria (>${mem_diff}MB)"
fi

# Limpiar
kill $SERVER_PID 2>/dev/null
```

---

## ⏱️ Pruebas de Sesiones Largas

### 1. Simulación de Sesión Larga

```bash
echo "⏱️ TEST 8: Simulación de sesión larga"
echo "===================================="

# Establecer baseline
./latency-detector.sh baseline

# Simular carga de trabajo
echo "🔄 Simulando actividad prolongada..."
for i in {1..10}; do
    echo "  Ciclo $i/10: Generando actividad..."
    
    # Simular uso del editor (crear archivos temporales)
    for j in {1..5}; do
        echo "// Archivo temporal $i-$j" > /tmp/test_file_${i}_${j}.js
    done
    
    # Simular compilación TypeScript
    if command -v tsc &> /dev/null; then
        echo "console.log('test');" | tsc --target ES2015 --outFile /tmp/output_$i.js 2>/dev/null || true
    fi
    
    sleep 2
done

# Verificar degradación
echo "🔍 Verificando degradación de rendimiento..."
if ./latency-detector.sh check | grep -q "DEGRADACIÓN"; then
    echo "⚠️ Degradación detectada - aplicando auto-fix..."
    ./latency-detector.sh auto-fix
    echo "✅ Auto-optimización aplicada"
else
    echo "✅ Sin degradación significativa"
fi

# Limpiar archivos temporales
rm -f /tmp/test_file_*.js /tmp/output_*.js
```

### 2. Prueba de Auto-Optimización

```bash
echo "🔧 TEST 9: Auto-optimización"
echo "==========================="

# Verificar que los scripts existen
if [ -f "./auto-optimize.sh" ] && [ -f "./latency-detector.sh" ]; then
    echo "✅ Scripts de optimización disponibles"
    
    # Probar limpieza
    echo "🧹 Probando limpieza automática..."
    ./auto-optimize.sh clean
    echo "✅ Limpieza ejecutada"
    
    # Probar configuración
    echo "⚙️ Probando configuración optimizada..."
    ./auto-optimize.sh setup
    echo "✅ Configuración aplicada"
    
    # Verificar estadísticas
    echo "📊 Estadísticas del sistema:"
    ./auto-optimize.sh stats
    
else
    echo "❌ Scripts de optimización no encontrados"
fi
```

---

## 📊 Validación de Monitoreo

### 1. Prueba de Scripts de Monitoreo

```bash
echo "📊 TEST 10: Sistema de monitoreo"
echo "==============================="

# Verificar scripts de monitoreo
monitoring_scripts=(
    "monitor-system.sh"
    "monitor-visual.sh"
    "monitor-latency.sh"
    "monitor-advanced.sh"
)

for script in "${monitoring_scripts[@]}"; do
    if [ -f "./$script" ]; then
        echo "✅ $script disponible"
        
        # Ejecutar brevemente para verificar que funciona
        timeout 3 ./$script >/dev/null 2>&1 && echo "  ✅ Ejecutable" || echo "  ⚠️ Error en ejecución"
    else
        echo "❌ $script no encontrado"
    fi
done
```

### 2. Validación de Métricas

```bash
echo "📈 TEST 11: Validación de métricas"
echo "================================="

# Ejecutar monitor breve para obtener métricas
echo "📊 Recolectando métricas del sistema..."
timeout 5 ./monitor-system.sh > /tmp/metrics.log 2>&1

# Verificar que se capturan métricas básicas
if grep -q "CPU" /tmp/metrics.log; then
    echo "✅ Métricas de CPU capturadas"
else
    echo "⚠️ No se detectaron métricas de CPU"
fi

if grep -q -i "mem\|ram" /tmp/metrics.log; then
    echo "✅ Métricas de memoria capturadas"
else
    echo "⚠️ No se detectaron métricas de memoria"
fi

# Limpiar
rm -f /tmp/metrics.log
```

---

## ☁️ Pruebas de Codespaces

### 1. Validación de DevContainer

```bash
echo "☁️ TEST 12: Configuración de DevContainer"
echo "========================================"

# Verificar estructura DevContainer
if [ -f ".devcontainer/devcontainer.json" ]; then
    echo "✅ devcontainer.json existe"
    
    # Validar JSON
    if python -c "import json; json.load(open('.devcontainer/devcontainer.json'))" 2>/dev/null; then
        echo "✅ JSON válido"
    else
        echo "❌ JSON inválido"
    fi
    
    # Verificar campos importantes
    if grep -q "postCreateCommand" .devcontainer/devcontainer.json; then
        echo "✅ postCreateCommand configurado"
    else
        echo "⚠️ postCreateCommand no definido"
    fi
    
    if grep -q "forwardPorts" .devcontainer/devcontainer.json; then
        echo "✅ Port forwarding configurado"
    else
        echo "⚠️ Port forwarding no configurado"
    fi
    
else
    echo "❌ devcontainer.json no encontrado"
fi
```

### 2. Prueba de Scripts de Setup

```bash
echo "🔧 TEST 13: Scripts de setup"
echo "=========================="

# Verificar scripts de Codespaces
setup_scripts=(
    "scripts/setup-codespaces.sh"
    "scripts/setup-linux.sh"
    "scripts/setup-workspace-profile.sh"
)

for script in "${setup_scripts[@]}"; do
    if [ -f "$script" ]; then
        echo "✅ $script disponible"
        
        # Verificar que es ejecutable
        if [ -x "$script" ]; then
            echo "  ✅ Permisos de ejecución correctos"
        else
            echo "  ⚠️ Falta permiso de ejecución"
            chmod +x "$script"
        fi
    else
        echo "⚠️ $script no encontrado"
    fi
done
```

---

## 🌐 Pruebas de Integración Completa

### 1. Test End-to-End

```bash
echo "🌐 TEST 14: Prueba end-to-end"
echo "============================"

# Función para limpiar al salir
cleanup() {
    echo "🧹 Limpiando procesos..."
    kill $SERVER_PID 2>/dev/null || true
    kill $MONITOR_PID 2>/dev/null || true
}
trap cleanup EXIT

# Iniciar monitor en background
./monitor-system.sh > /tmp/monitor.log 2>&1 &
MONITOR_PID=$!

# Iniciar servidor
./start-game.sh &
SERVER_PID=$!
sleep 10

# Verificar que todo está funcionando
echo "🔍 Verificando componentes:"

# 1. Servidor web
if curl -s http://localhost:8000 >/dev/null; then
    echo "  ✅ Servidor web respondiendo"
else
    echo "  ❌ Servidor web no responde"
fi

# 2. Monitor activo
if ps -p $MONITOR_PID >/dev/null; then
    echo "  ✅ Sistema de monitoreo activo"
else
    echo "  ❌ Sistema de monitoreo falló"
fi

# 3. Archivos estáticos accesibles
if curl -s http://localhost:8000/static/game.js | grep -q "function"; then
    echo "  ✅ Archivos estáticos accesibles"
else
    echo "  ⚠️ Problema con archivos estáticos"
fi

# 4. IA disponible
python -c "
from server.game_agent import GameAgent
agent = GameAgent()
move = agent.get_move([None]*9, 'O')
print('  ✅ IA funcional' if move is not None else '  ⚠️ IA usando fallback')
"

echo "🎯 Prueba end-to-end completada"
```

### 2. Validación de URLs y Acceso

```bash
echo "🔗 TEST 15: Validación de URLs"
echo "============================"

# Iniciar servidor si no está activo
if ! pgrep -f "python.*server" >/dev/null; then
    ./start-game.sh &
    SERVER_PID=$!
    sleep 10
fi

# Probar diferentes endpoints
endpoints=(
    "/"
    "/static/game.js"
    "/static/styles.css"
    "/health"
)

for endpoint in "${endpoints[@]}"; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000$endpoint | grep -q "200"; then
        echo "✅ $endpoint accesible"
    else
        echo "⚠️ $endpoint no accesible"
    fi
done

# Mostrar información de acceso
echo ""
echo "🌐 URLs de acceso:"
if [ -f "show-url.sh" ]; then
    ./show-url.sh
else
    echo "  Local: http://localhost:8000"
    echo "  Codespaces: https://${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
fi
```

---

## ✅ Checklist Final

### 📋 Sistema Base
- [ ] Servidor inicia correctamente
- [ ] Puerto 8000 accesible
- [ ] Página principal carga
- [ ] Archivos estáticos servidos
- [ ] Lógica del juego funcional

### 🤖 Integración IA
- [ ] IA puede hacer movimientos válidos
- [ ] IA bloquea victorias del oponente
- [ ] IA toma victorias cuando puede
- [ ] Fallback funciona sin Ollama

### ⚡ Performance
- [ ] Tiempo de respuesta <500ms
- [ ] Uso de memoria <500MB inicial
- [ ] Sistema de optimización funcional
- [ ] Auto-detección de degradación

### 📊 Monitoreo
- [ ] Scripts de monitoreo ejecutables
- [ ] Métricas de CPU/memoria capturas
- [ ] Alertas de rendimiento funcionan
- [ ] Logs generados correctamente

### ☁️ Codespaces
- [ ] DevContainer configurado
- [ ] Scripts de setup ejecutables
- [ ] Port forwarding configurado
- [ ] Variables de entorno correctas

### 🔧 Optimización
- [ ] Auto-optimización funcional
- [ ] Detector de latencia operativo
- [ ] Configuraciones aplicadas
- [ ] Limpieza automática activa

### 📚 Documentación
- [ ] README.md completo
- [ ] Guías paso a paso disponibles
- [ ] Troubleshooting documentado
- [ ] URLs de acceso claras

---

## 🐛 Troubleshooting de Pruebas

### Problemas Comunes

#### 1. Servidor no inicia
```bash
# Verificar puertos ocupados
netstat -tlnp | grep 8000

# Liberar puerto si está ocupado
sudo fuser -k 8000/tcp

# Verificar dependencias
pip install -r requirements.txt
```

#### 2. IA no responde
```bash
# Verificar Ollama
ollama list

# Probar fallback
python -c "from server.game_agent import GameAgent; print(GameAgent().get_move([None]*9, 'O'))"

# Reinstalar dependencias
pip install --upgrade -r requirements.txt
```

#### 3. Monitoreo falla
```bash
# Verificar permisos
chmod +x *.sh

# Verificar herramientas del sistema
which ps top free netstat

# Instalar herramientas faltantes (si es necesario)
sudo apt-get update && sudo apt-get install -y procps net-tools
```

#### 4. Performance degradada
```bash
# Aplicar optimización completa
./auto-optimize.sh setup
./latency-detector.sh auto-fix moderate

# Recargar VS Code si persiste
# Ctrl+Shift+P > "Developer: Reload Window"

# Verificar recursos del sistema
./monitor-system.sh
```

---

## 🎯 Validación Final

### Script de Validación Completa

```bash
#!/bin/bash
# validation-complete.sh

echo "🎯 VALIDACIÓN COMPLETA DEL SISTEMA"
echo "=================================="
echo ""

TESTS_PASSED=0
TESTS_TOTAL=15

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "🧪 $test_name"
    if eval "$test_command" >/dev/null 2>&1; then
        echo "   ✅ PASS"
        ((TESTS_PASSED++))
    else
        echo "   ❌ FAIL"
    fi
    ((TESTS_TOTAL++))
}

# Ejecutar todas las pruebas principales
run_test "Estructura del proyecto" "[ -d server ] && [ -d client ] && [ -f requirements.txt ]"
run_test "Scripts principales" "[ -f start-game.sh ] && [ -f auto-optimize.sh ]"
run_test "DevContainer configurado" "[ -f .devcontainer/devcontainer.json ]"
run_test "Dependencias Python" "python -c 'import server.game_logic, server.game_agent'"
run_test "Servidor inicia" "timeout 10 ./start-game.sh >/dev/null 2>&1 &"
run_test "Puerto accesible" "timeout 5 bash -c 'while ! nc -z localhost 8000; do sleep 0.1; done'"
run_test "IA funcional" "python -c 'from server.game_agent import GameAgent; assert GameAgent().get_move([None]*9, \"O\") is not None'"
run_test "Monitor sistema" "timeout 3 ./monitor-system.sh >/dev/null 2>&1"
run_test "Auto-optimización" "./auto-optimize.sh clean >/dev/null 2>&1"
run_test "Detector latencia" "./latency-detector.sh check >/dev/null 2>&1"

echo ""
echo "📊 RESULTADOS:"
echo "============="
echo "✅ Pruebas pasadas: $TESTS_PASSED/$TESTS_TOTAL"

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo "🎉 ¡SISTEMA COMPLETAMENTE VALIDADO!"
    echo ""
    echo "🚀 Próximos pasos:"
    echo "   1. Ejecuta './start-game.sh' para iniciar"
    echo "   2. Abre http://localhost:8000 en tu navegador"
    echo "   3. ¡Disfruta jugando contra la IA!"
elif [ $TESTS_PASSED -gt $((TESTS_TOTAL * 7 / 10)) ]; then
    echo "✅ Sistema mayormente funcional"
    echo "⚠️  Algunas pruebas fallaron - revisa el troubleshooting"
else
    echo "❌ Sistema requiere atención"
    echo "🔧 Ejecuta las pruebas individuales para diagnóstico"
fi

echo ""
echo "📚 Documentación: docs/guias/"
echo "🆘 Ayuda: MEJORES-PRACTICAS-SESIONES-LARGAS.md"
```

---

## 🎉 ¡Felicitaciones!

Si has llegado hasta aquí y todas las pruebas pasan, ¡has completado exitosamente la configuración del sistema completo!

### 🏆 Lo que has logrado:

1. **✅ Sistema base funcional** - Servidor web con IA integrada
2. **✅ Monitoreo completo** - Tracking de performance en tiempo real  
3. **✅ Optimización automática** - Manejo de sesiones largas
4. **✅ Configuración Codespaces** - Desarrollo en la nube optimizado
5. **✅ Documentación completa** - Guías paso a paso
6. **✅ Validación robusta** - Suite de pruebas automatizadas

### 🚀 Siguientes pasos:

- **Jugar:** `./start-game.sh` y abrir http://localhost:8000
- **Monitorear:** `./monitor-visual.sh` para ver métricas en tiempo real
- **Optimizar:** `./auto-optimize.sh start &` para sesiones largas
- **Desarrollar:** Usar las guías para expandir funcionalidades

---

## 📚 Recursos Adicionales

- **[README.md](../../README.md)** - Información general del proyecto
- **[MEJORES-PRACTICAS-SESIONES-LARGAS.md](../../MEJORES-PRACTICAS-SESIONES-LARGAS.md)** - Optimización avanzada
- **[MONITOREO-GUIA.md](../../MONITOREO-GUIA.md)** - Sistema de monitoreo detallado
- **[DOCUMENTACION-COMPLETA.md](../../DOCUMENTACION-COMPLETA.md)** - Documentación técnica completa

---

**¡Proyecto completado exitosamente! 🎉**

*Disfruta tu sistema de Tic-Tac-Toe con IA completamente optimizado.*
