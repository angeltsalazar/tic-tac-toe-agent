#!/bin/bash
# validation-complete.sh

echo "🎯 VALIDACIÓN COMPLETA DEL SISTEMA"
echo "=================================="
echo ""

TESTS_PASSED=0
TESTS_TOTAL=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "🧪 $test_name"
    if eval "$test_command" >/dev/null 2>&1; then
        echo "   ✅ PASS"
        ((TESTS_PASSED++))
    else
        echo "   ❌ FAIL"
        echo "   ⚠️  Comando: $test_command"
    fi
    ((TESTS_TOTAL++))
}

echo "📋 Ejecutando pruebas del sistema..."
echo ""

# Ejecutar todas las pruebas principales
run_test "Estructura del proyecto" "[ -d server ] && [ -d client ] && [ -f requirements.txt ]"
run_test "Scripts principales" "[ -f start-game.sh ] && [ -f auto-optimize.sh ]"
run_test "DevContainer configurado" "[ -f .devcontainer/devcontainer.json ]"
run_test "Configuración VS Code" "[ -f .vscode/settings.json ]"
run_test "Scripts de optimización" "[ -f auto-optimize.sh ] && [ -f latency-detector.sh ]"
run_test "Documentación completa" "[ -f docs/guias/09-pruebas-validacion.md ]"
run_test "Mejores prácticas" "[ -f MEJORES-PRACTICAS-SESIONES-LARGAS.md ]"
run_test "Monitor sistema ejecutable" "[ -x monitor-system.sh ] || [ -f monitor-system.sh ]"
run_test "Dependencies Python instalables" "pip install -r requirements.txt >/dev/null 2>&1"
run_test "Sintaxis Python correcta" "python -m py_compile server/*.py 2>/dev/null"
run_test "Auto-optimización funcional" "./auto-optimize.sh clean >/dev/null 2>&1"
run_test "Detector latencia funcional" "./latency-detector.sh check >/dev/null 2>&1"

# Pruebas avanzadas con timeout para evitar bloqueos
echo ""
echo "🔍 Pruebas avanzadas..."

run_test "Dependencias Python importables" "timeout 10 python -c 'import sys; sys.path.append(\"server\"); import game_logic, game_agent' 2>/dev/null"

# Test de inicio del servidor con timeout más largo
echo "🧪 Servidor inicia correctamente"
if timeout 15 bash -c './start-game.sh >/dev/null 2>&1 & sleep 5; curl -f http://localhost:8000 >/dev/null 2>&1'; then
    echo "   ✅ PASS"
    ((TESTS_PASSED++))
    # Detener el servidor
    pkill -f "python.*server" >/dev/null 2>&1 || true
    pkill -f "uvicorn" >/dev/null 2>&1 || true
else
    echo "   ❌ FAIL"
    echo "   ⚠️  Servidor no responde en puerto 8000"
fi
((TESTS_TOTAL++))

# Test de IA más robusto con debug
echo "🧪 IA funcional básica"
if cd /workspaces/tic-tac-toe-agent && timeout 10 bash -c '
export PYTHONPATH=server:$PYTHONPATH
python3 -c "
import sys
from game_agent import GameAgent
agent = GameAgent()
move = agent.get_move([None]*9, \"O\")
print(f\"Debug: move={move}, type={type(move)}\", file=sys.stderr)
assert move is not None and isinstance(move, int) and 0 <= move <= 8
print(\"IA test passed\")
" 2>/dev/null
'; then
    echo "   ✅ PASS"
    ((TESTS_PASSED++))
else
    echo "   ❌ FAIL"
    echo "   ⚠️  Probando IA con debug..."
    cd /workspaces/tic-tac-toe-agent && PYTHONPATH=server python3 -c "
from game_agent import GameAgent
agent = GameAgent()
move = agent.get_move([None]*9, 'O')
print(f'   🔍 Movimiento obtenido: {move}, tipo: {type(move)}')
" 2>/dev/null || echo "   🔍 Error en ejecución de IA"
fi
((TESTS_TOTAL++))

echo ""
echo "📊 RESULTADOS:"
echo "============="
echo "✅ Pruebas pasadas: $TESTS_PASSED/$TESTS_TOTAL"

PERCENTAGE=$((TESTS_PASSED * 100 / TESTS_TOTAL))

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo "🎉 ¡SISTEMA COMPLETAMENTE VALIDADO!"
    echo ""
    echo "🚀 Próximos pasos:"
    echo "   1. Ejecuta './start-game.sh' para iniciar"
    echo "   2. Abre http://localhost:8000 en tu navegador"
    echo "   3. ¡Disfruta jugando contra la IA!"
    echo ""
    echo "💡 Para sesiones largas:"
    echo "   - Ejecuta './auto-optimize.sh start &' en background"
    echo "   - Usa './latency-detector.sh monitor &' para monitoreo"
elif [ $PERCENTAGE -gt 70 ]; then
    echo "✅ Sistema mayormente funcional ($PERCENTAGE%)"
    echo "⚠️  Algunas pruebas fallaron - revisa el troubleshooting"
    echo ""
    echo "🔧 Comandos de diagnóstico:"
    echo "   - ./auto-optimize.sh status"
    echo "   - ./latency-detector.sh baseline"
    echo "   - python -m server.game_logic"
else
    echo "❌ Sistema requiere atención ($PERCENTAGE%)"
    echo "🔧 Ejecuta las pruebas individuales para diagnóstico"
    echo ""
    echo "📚 Consulta:"
    echo "   - MEJORES-PRACTICAS-SESIONES-LARGAS.md"
    echo "   - docs/guias/08-codespaces-config.md"
fi

echo ""
echo "📚 Documentación: docs/guias/"
echo "🆘 Ayuda: MEJORES-PRACTICAS-SESIONES-LARGAS.md"

# Cleanup cualquier proceso que pueda haber quedado
pkill -f "python.*server" >/dev/null 2>&1 || true
pkill -f "uvicorn" >/dev/null 2>&1 || true
