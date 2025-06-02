#!/bin/bash

# 🎯 Detector Inteligente de Latencia de Teclado
# Detecta automáticamente cuando el rendimiento se degrada

LATENCY_THRESHOLD_FILE="/tmp/latency_baseline.txt"
PERFORMANCE_LOG="/tmp/performance_monitor.log"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Función para establecer baseline de rendimiento
establish_baseline() {
    echo "🎯 Estableciendo baseline de rendimiento..."
    
    local current_time=$(date +%s)
    local ext_host_mem=$(ps aux | grep -E "(extensionHost|Extension Host)" | grep -v grep | awk '{sum+=$6} END {print sum/1024}')
    local total_mem_percent=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    local cpu_load=$(cat /proc/loadavg | awk '{print $1}')
    
    # Guardar baseline
    echo "${current_time},${ext_host_mem:-100},${total_mem_percent},${cpu_load}" > "$LATENCY_THRESHOLD_FILE"
    
    echo "✅ Baseline establecido:"
    echo "   Extension Host: ${ext_host_mem:-100}MB"
    echo "   Memoria total: ${total_mem_percent}%"
    echo "   CPU Load: ${cpu_load}"
}

# Función para detectar degradación
detect_degradation() {
    if [ ! -f "$LATENCY_THRESHOLD_FILE" ]; then
        establish_baseline
        return 1
    fi
    
    # Leer baseline
    local baseline_data=$(cat "$LATENCY_THRESHOLD_FILE")
    local baseline_time=$(echo "$baseline_data" | cut -d',' -f1)
    local baseline_ext_mem=$(echo "$baseline_data" | cut -d',' -f2)
    local baseline_total_mem=$(echo "$baseline_data" | cut -d',' -f3)
    local baseline_cpu=$(echo "$baseline_data" | cut -d',' -f4)
    
    # Obtener métricas actuales
    local current_ext_mem=$(ps aux | grep -E "(extensionHost|Extension Host)" | grep -v grep | awk '{sum+=$6} END {print sum/1024}')
    local current_total_mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    local current_cpu=$(cat /proc/loadavg | awk '{print $1}')
    local current_time=$(date +%s)
    
    # Calcular tiempo desde baseline
    local time_diff=$((current_time - baseline_time))
    local hours_diff=$((time_diff / 3600))
    
    # Detectar degradación significativa
    local degraded=false
    local issues=()
    
    # Extension Host: Aumento >50% o >1GB
    local ext_mem_increase=$(echo "scale=0; (${current_ext_mem:-100} - $baseline_ext_mem) / $baseline_ext_mem * 100" | bc -l 2>/dev/null || echo "0")
    local ext_mem_int=$(printf "%.0f" "${current_ext_mem:-100}")
    local ext_increase_int=$(printf "%.0f" "${ext_mem_increase}")
    if [ "$ext_mem_int" -gt 1000 ] || [ "$ext_increase_int" -gt 50 ]; then
        issues+=("Extension Host: ${ext_mem_int}MB (+${ext_increase_int}%)")
        degraded=true
    fi
    
    # Memoria total: Aumento >20% o >85%
    local mem_increase=$((current_total_mem - baseline_total_mem))
    if [ "$current_total_mem" -gt 85 ] || [ "$mem_increase" -gt 20 ]; then
        issues+=("Memoria total: ${current_total_mem}% (+${mem_increase}%)")
        degraded=true
    fi
    
    # CPU Load: Aumento significativo
    local cpu_increase=$(echo "scale=1; $current_cpu - $baseline_cpu" | bc -l 2>/dev/null || echo "0")
    if (( $(echo "$current_cpu > 2.0" | bc -l 2>/dev/null) )) || (( $(echo "$cpu_increase > 1.0" | bc -l 2>/dev/null) )); then
        issues+=("CPU Load: ${current_cpu} (+${cpu_increase})")
        degraded=true
    fi
    
    # Log performance data
    echo "[$(date '+%H:%M:%S')] ExtHost:${current_ext_mem:-0}MB, Mem:${current_total_mem}%, CPU:${current_cpu}, Issues:${#issues[@]}" >> "$PERFORMANCE_LOG"
    
    if [ "$degraded" = true ]; then
        show_degradation_alert "$hours_diff" "${issues[@]}"
        return 0
    else
        return 1
    fi
}

# Función para mostrar alerta de degradación
show_degradation_alert() {
    local session_hours=$1
    shift
    local issues=("$@")
    
    echo ""
    echo -e "${RED}🚨 DEGRADACIÓN DE RENDIMIENTO DETECTADA${NC}"
    echo "========================================"
    echo -e "⏱️  Tiempo de sesión: ${session_hours}h"
    echo ""
    echo -e "${YELLOW}📊 Problemas detectados:${NC}"
    for issue in "${issues[@]}"; do
        echo "   🔴 $issue"
    done
    echo ""
    
    # Sugerir acciones basadas en la severidad
    local action_level="light"
    if [ ${#issues[@]} -gt 2 ] || [ "$session_hours" -gt 4 ]; then
        action_level="aggressive"
    elif [ ${#issues[@]} -gt 1 ] || [ "$session_hours" -gt 2 ]; then
        action_level="moderate"
    fi
    
    suggest_actions "$action_level"
}

# Función para sugerir acciones
suggest_actions() {
    local level=$1
    
    echo -e "${BLUE}💡 ACCIONES RECOMENDADAS:${NC}"
    echo ""
    
    case "$level" in
        "light")
            echo -e "${GREEN}🧹 Nivel Ligero:${NC}"
            echo "   1. ./auto-optimize.sh clean"
            echo "   2. Cerrar tabs innecesarios"
            echo "   3. Continuar trabajando"
            ;;
        "moderate")
            echo -e "${YELLOW}🔄 Nivel Moderado:${NC}"
            echo "   1. ./auto-optimize.sh clean"
            echo "   2. Ctrl+Shift+P > 'Developer: Reload Window'"
            echo "   3. Cerrar paneles innecesarios"
            echo "   4. Desactivar extensiones temporalmente"
            ;;
        "aggressive")
            echo -e "${RED}🚀 Nivel Agresivo:${NC}"
            echo "   1. Guardar trabajo importante"
            echo "   2. Ctrl+Shift+P > 'Developer: Reload Window'"
            echo "   3. Considerar nueva sesión si persiste"
            echo "   4. ./auto-optimize.sh setup (para prevenir)"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}🤖 Ejecutar automáticamente:${NC}"
    echo "   ./latency-detector.sh auto-fix $level"
}

# Función para auto-fix
auto_fix() {
    local level=${1:-light}
    
    echo -e "${BLUE}🔧 Ejecutando auto-fix nivel: $level${NC}"
    
    case "$level" in
        "light")
            ./auto-optimize.sh clean
            echo "✅ Optimización ligera completada"
            ;;
        "moderate")
            ./auto-optimize.sh clean
            echo "💡 Recarga VS Code recomendada: Ctrl+Shift+P > 'Developer: Reload Window'"
            ;;
        "aggressive")
            ./monitor-latency.sh --clean >/dev/null 2>&1
            echo "💡 Considera recargar VS Code o crear nueva sesión"
            ;;
    esac
}

# Función de monitoreo continuo
continuous_monitor() {
    local interval=${1:-60}  # 1 minuto por defecto
    
    echo -e "${BLUE}🎯 MONITOR CONTINUO DE LATENCIA${NC}"
    echo "Intervalo: ${interval}s | Log: $PERFORMANCE_LOG"
    echo "Ctrl+C para detener"
    echo ""
    
    # Establecer baseline si no existe
    if [ ! -f "$LATENCY_THRESHOLD_FILE" ]; then
        establish_baseline
    fi
    
    while true; do
        if detect_degradation; then
            echo "⏸️  Pausando monitor por 5 minutos para permitir acciones..."
            sleep 300
        else
            echo -e "${GREEN}✅ Rendimiento OK ($(date '+%H:%M:%S'))${NC}"
        fi
        
        sleep "$interval"
    done
}

# Función para mostrar estadísticas detalladas
show_detailed_stats() {
    echo -e "${BLUE}📊 ANÁLISIS DETALLADO DE RENDIMIENTO${NC}"
    echo "===================================="
    echo ""
    
    # Información de baseline
    if [ -f "$LATENCY_THRESHOLD_FILE" ]; then
        local baseline_data=$(cat "$LATENCY_THRESHOLD_FILE")
        local baseline_time=$(echo "$baseline_data" | cut -d',' -f1)
        local session_duration=$(( ($(date +%s) - baseline_time) / 3600 ))
        echo "⏱️  Duración de sesión: ${session_duration}h"
        echo ""
    fi
    
    # Extension Host detallado
    echo "🔍 Extension Host Processes:"
    ps aux | grep -E "(extensionHost|Extension Host)" | grep -v grep | while read line; do
        local mem_mb=$(echo $line | awk '{printf "%.0f", $6/1024}')
        local cpu=$(echo $line | awk '{print $3}')
        local pid=$(echo $line | awk '{print $2}')
        echo "   PID $pid: ${mem_mb}MB, CPU: ${cpu}%"
    done
    echo ""
    
    # TypeScript Language Servers
    echo "📝 TypeScript Servers:"
    ps aux | grep -i typescript | grep -v grep | wc -l | xargs echo "   Instancias activas:"
    echo ""
    
    # Archivos temporales grandes
    echo "📁 Archivos temporales grandes:"
    find /tmp -name "*vscode*" -o -name "*typescript*" -o -name "*.log" | head -5 | while read file; do
        if [ -f "$file" ]; then
            local size=$(du -h "$file" 2>/dev/null | cut -f1)
            echo "   $file: $size"
        fi
    done
    echo ""
    
    # Historial de rendimiento (últimas 10 entradas)
    if [ -f "$PERFORMANCE_LOG" ]; then
        echo "📈 Historial reciente:"
        tail -10 "$PERFORMANCE_LOG" | while read line; do
            echo "   $line"
        done
    fi
}

# Programa principal
case "${1:-help}" in
    monitor)
        continuous_monitor "${2:-60}"
        ;;
    check)
        if detect_degradation; then
            echo ""
            echo "🔧 Para resolver automáticamente: ./latency-detector.sh auto-fix"
        else
            echo -e "${GREEN}✅ Sin degradación detectada${NC}"
        fi
        ;;
    auto-fix)
        auto_fix "${2:-light}"
        ;;
    baseline)
        establish_baseline
        ;;
    stats)
        show_detailed_stats
        ;;
    reset)
        rm -f "$LATENCY_THRESHOLD_FILE" "$PERFORMANCE_LOG"
        echo "✅ Historial de rendimiento limpiado"
        ;;
    *)
        echo "🎯 Detector Inteligente de Latencia de Teclado"
        echo "============================================="
        echo ""
        echo "Uso: $0 <comando> [opciones]"
        echo ""
        echo "Comandos:"
        echo "  monitor [intervalo]  - Monitor continuo (60s por defecto)"
        echo "  check               - Verificar degradación una vez"
        echo "  auto-fix [nivel]    - Aplicar correcciones (light/moderate/aggressive)"
        echo "  baseline            - Establecer nuevo baseline de rendimiento"
        echo "  stats               - Mostrar análisis detallado"
        echo "  reset               - Limpiar historial de rendimiento"
        echo ""
        echo "Ejemplos de uso:"
        echo "  $0 baseline         - Establecer baseline al inicio de sesión"
        echo "  $0 monitor 30       - Monitor cada 30 segundos"
        echo "  $0 check            - Verificación rápida"
        echo "  $0 auto-fix moderate - Aplicar correcciones moderadas"
        echo ""
        echo "💡 Flujo recomendado:"
        echo "  1. $0 baseline      - Al iniciar sesión"
        echo "  2. $0 monitor       - Ejecutar en background"
        echo "  3. $0 auto-fix      - Cuando se detecte degradación"
        ;;
esac
