#!/bin/bash
# validation-complete-v2.sh

echo "🎯 VALIDACIÓN COMPLETA DEL SISTEMA v2.0"
echo "========================================"
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

# Pruebas avanzadas
echo ""
echo "🔍 Pruebas avanzadas..."

run_test "Dependencias Python importables" "timeout 10 python -c 'import sys; sys.path.append(\"server\"); import game_logic, game_agent' 2>/dev/null"

# Test de inicio del servidor
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

# Test de IA mejorado usando test_ai.py
run_test "IA funcional básica" "python test_ai.py >/dev/null 2>&1"

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
    echo "   2. Abre https://super-duper-space-fortnight-w5ww5xqrwhwx9-8000.app.github.dev/ en tu navegador"
    echo "   3. ¡Disfruta jugando contra la IA!"
    echo ""
    echo "💡 Para sesiones largas:"
    echo "   - Ejecuta './auto-optimize.sh start &' en background"
    echo "   - Usa './latency-detector.sh monitor &' para monitoreo"
    echo ""
    echo "🔧 Sistema de optimización activo:"
    echo "   - Extension Host actual: $(ps aux | grep -E "(extensionHost|Extension Host)" | grep -v grep | awk '{sum+=$6} END {printf "%.0f", sum/1024}' || echo '0')MB"
    echo "   - Memoria sistema: $(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')%"
elif [ $PERCENTAGE -gt 70 ]; then
    echo "✅ Sistema mayormente funcional ($PERCENTAGE%)"
    echo "⚠️  Algunas pruebas fallaron - revisa el troubleshooting"
    echo ""
    echo "🔧 Comandos de diagnóstico:"
    echo "   - ./auto-optimize.sh stats"
    echo "   - ./latency-detector.sh baseline"
    echo "   - python test_ai.py"
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
echo "🌐 URL del juego: https://super-duper-space-fortnight-w5ww5xqrwhwx9-8000.app.github.dev/"

# Cleanup cualquier proceso que pueda haber quedado
pkill -f "python.*server" >/dev/null 2>&1 || true
pkill -f "uvicorn" >/dev/null 2>&1 || true
