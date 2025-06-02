#!/bin/bash

# 🚀 Auto-Optimización de Rendimiento para Sesiones Largas
# Ejecuta optimizaciones automáticas cada cierto tiempo

AUTO_OPTIMIZE_LOG="/tmp/auto-optimize.log"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_action() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$AUTO_OPTIMIZE_LOG"
}

# Función para verificar si necesita optimización
needs_optimization() {
    local needs=false
    
    # Verificar memoria de Extension Host
    local ext_mem=$(ps aux | grep -E "(extensionHost|Extension Host)" | grep -v grep | awk '{sum+=$6} END {printf "%.0f", sum/1024}')
    if [ "${ext_mem:-0}" -gt 1000 ]; then
        log_action "🔴 Extension Host usando ${ext_mem}MB (límite: 1000MB)"
        needs=true
    fi
    
    # Verificar carga de CPU
    local cpu_load=$(cat /proc/loadavg | awk '{print $1}')
    local cpu_percent=$(echo "$cpu_load * 100 / $(nproc)" | bc -l 2>/dev/null || echo "0")
    if (( $(echo "$cpu_percent > 70" | bc -l 2>/dev/null) )); then
        log_action "🔴 Carga CPU alta: ${cpu_percent}%"
        needs=true
    fi
    
    # Verificar memoria total
    local mem_percent=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    if [ "$mem_percent" -gt 80 ]; then
        log_action "🔴 Memoria alta: ${mem_percent}%"
        needs=true
    fi
    
    if [ "$needs" = true ]; then
        return 0
    else
        return 1
    fi
}

# Función de optimización ligera
light_optimization() {
    log_action "🧹 Ejecutando optimización ligera..."
    
    # Limpiar cachés temporales
    rm -rf /tmp/vscode-* 2>/dev/null
    rm -rf ~/.cache/typescript/* 2>/dev/null
    find /tmp -name "*tic-tac-toe*" -mtime +0 -delete 2>/dev/null
    
    # Liberar buffers
    sync
    
    log_action "✅ Optimización ligera completada"
}

# Función de optimización profunda
deep_optimization() {
    log_action "🔧 Ejecutando optimización profunda..."
    
    # Ejecutar limpieza completa
    ./monitor-latency.sh --clean >/dev/null 2>&1
    
    # Limpiar logs extensos
    find /tmp -name "*.log" -size +10M -delete 2>/dev/null
    
    # Optimizar Git (si hay repo)
    if [ -d ".git" ]; then
        git gc --prune=now >/dev/null 2>&1
    fi
    
    log_action "✅ Optimización profunda completada"
}

# Función principal
auto_optimize() {
    local check_interval=${1:-300}  # 5 minutos por defecto
    local optimization_level=${2:-light}  # light|deep
    
    echo -e "${BLUE}🚀 AUTO-OPTIMIZACIÓN INICIADA${NC}"
    echo -e "   Intervalo: ${check_interval}s | Nivel: ${optimization_level}"
    echo -e "   Log: ${AUTO_OPTIMIZE_LOG}"
    echo ""
    
    log_action "🚀 Auto-optimización iniciada (intervalo: ${check_interval}s, nivel: ${optimization_level})"
    
    while true; do
        if needs_optimization; then
            echo -e "${YELLOW}⚠️  Sistema necesita optimización...${NC}"
            
            if [ "$optimization_level" = "deep" ]; then
                deep_optimization
            else
                light_optimization
            fi
            
            echo -e "${GREEN}✅ Optimización completada${NC}"
            
            # Mostrar recomendación si la optimización no es suficiente
            if needs_optimization; then
                echo -e "${RED}🔔 RECOMENDACIÓN: Considera recargar VS Code (Ctrl+Shift+P > 'Developer: Reload Window')${NC}"
                log_action "🔔 Recomendación de recarga de VS Code enviada"
            fi
        else
            echo -e "${GREEN}✅ Sistema optimizado ($(date '+%H:%M:%S'))${NC}"
        fi
        
        sleep "$check_interval"
    done
}

# Función para mostrar estadísticas
show_stats() {
    echo -e "${BLUE}📊 ESTADÍSTICAS DEL SISTEMA${NC}"
    echo "=========================="
    
    # Extension Host
    local ext_mem=$(ps aux | grep -E "(extensionHost|Extension Host)" | grep -v grep | awk '{sum+=$6} END {printf "%.0f", sum/1024}')
    echo "Extension Host: ${ext_mem:-0}MB"
    
    # Memoria total
    local mem_percent=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    echo "Memoria total: ${mem_percent}%"
    
    # CPU Load
    local cpu_load=$(cat /proc/loadavg | awk '{print $1}')
    echo "CPU Load: ${cpu_load}"
    
    # Procesos pesados
    echo ""
    echo "🔍 Top 3 procesos por memoria:"
    ps aux --sort=-%mem | head -4 | tail -3 | awk '{printf "  %s: %.1fMB\n", $11, $6/1024}'
}

# Función de configuración rápida
quick_setup() {
    echo -e "${BLUE}⚡ CONFIGURACIÓN RÁPIDA PARA SESIONES LARGAS${NC}"
    echo "============================================="
    
    # Crear configuración optimizada de VS Code
    local vscode_settings="{
  \"typescript.preferences.includePackageJsonAutoImports\": \"off\",
  \"typescript.suggest.autoImports\": false,
  \"typescript.disableAutomaticTypeAcquisition\": true,
  \"editor.quickSuggestions\": {\"other\": false, \"comments\": false, \"strings\": false},
  \"editor.parameterHints.enabled\": false,
  \"editor.wordBasedSuggestions\": \"off\",
  \"github.copilot.enable\": {\"*\": true, \"plaintext\": false, \"markdown\": false},
  \"files.watcherExclude\": {
    \"**/.git/objects/**\": true,
    \"**/.git/subtree-cache/**\": true,
    \"**/node_modules/**\": true,
    \"**/.hg/store/**\": true,
    \"**/tmp/**\": true,
    \"**/*.log\": true
  }
}"
    
    echo "$vscode_settings" > .vscode/settings.json
    echo "✅ Configuración optimizada aplicada en .vscode/settings.json"
    
    # Configurar auto-optimización ligera cada 5 minutos
    echo "⚡ Para activar auto-optimización:"
    echo "   ./auto-optimize.sh start"
    echo ""
    echo "📋 Comandos disponibles:"
    echo "   ./auto-optimize.sh start [intervalo] [nivel]  - Iniciar auto-optimización"
    echo "   ./auto-optimize.sh stats                      - Mostrar estadísticas"
    echo "   ./auto-optimize.sh clean                      - Limpiar una vez"
    echo "   ./auto-optimize.sh setup                      - Configuración inicial"
}

# Programa principal
case "${1:-help}" in
    start)
        auto_optimize "${2:-300}" "${3:-light}"
        ;;
    stats)
        show_stats
        ;;
    clean)
        light_optimization
        ;;
    setup)
        quick_setup
        ;;
    *)
        echo "🚀 Auto-Optimización para Sesiones Largas"
        echo "======================================="
        echo ""
        echo "Uso: $0 <comando> [opciones]"
        echo ""
        echo "Comandos:"
        echo "  start [intervalo] [nivel]  - Iniciar auto-optimización (300s, light)"
        echo "  stats                      - Mostrar estadísticas del sistema"
        echo "  clean                      - Ejecutar limpieza una vez"
        echo "  setup                      - Configuración inicial optimizada"
        echo ""
        echo "Ejemplos:"
        echo "  $0 setup                   - Configurar para sesiones largas"
        echo "  $0 start                   - Auto-optimización cada 5 min (ligera)"
        echo "  $0 start 180 deep         - Auto-optimización cada 3 min (profunda)"
        echo "  $0 stats                   - Ver estado actual del sistema"
        ;;
esac
