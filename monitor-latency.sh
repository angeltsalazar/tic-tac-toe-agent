#!/bin/bash

# 📊 Monitor de Latencia de Teclado
# Detecta procesos que causan latencia en tiempo real

echo "⌨️  MONITOR DE LATENCIA DEL TECLADO"
echo "=================================="
echo ""

# Función para verificar carga de CPU
check_cpu_load() {
    local load=$(cat /proc/loadavg | awk '{print $1}')
    local cpu_count=$(nproc)
    local load_percent=$(echo "$load * 100 / $cpu_count" | bc -l 2>/dev/null || echo "0")
    printf "⚡ Carga CPU: %.1f%% " "$load_percent"
    
    if (( $(echo "$load_percent > 70" | bc -l 2>/dev/null) )); then
        echo "🔴 ALTA - Puede causar latencia"
    elif (( $(echo "$load_percent > 40" | bc -l 2>/dev/null) )); then
        echo "🟡 MEDIA"
    else
        echo "🟢 BAJA"
    fi
}

# Función para verificar memoria
check_memory() {
    local mem_info=$(free | grep Mem)
    local total=$(echo $mem_info | awk '{print $2}')
    local used=$(echo $mem_info | awk '{print $3}')
    local percent=$((used * 100 / total))
    
    printf "🧠 Memoria: %d%% " "$percent"
    
    if [ $percent -gt 85 ]; then
        echo "🔴 ALTA - Puede causar latencia"
    elif [ $percent -gt 70 ]; then
        echo "🟡 MEDIA"
    else
        echo "🟢 BAJA"
    fi
}

# Función para verificar procesos problemáticos
check_heavy_processes() {
    echo ""
    echo "🔍 PROCESOS QUE PUEDEN CAUSAR LATENCIA:"
    echo "-------------------------------------"
    
    # Buscar procesos de VS Code con alta CPU/memoria
    ps aux --sort=-%cpu | grep -E "(node|vscode|typescript|copilot)" | grep -v grep | head -3 | while read line; do
        local cpu=$(echo $line | awk '{print $3}')
        local mem=$(echo $line | awk '{print $4}')
        local cmd=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
        
        if (( $(echo "$cpu > 5" | bc -l 2>/dev/null) )) || (( $(echo "$mem > 5" | bc -l 2>/dev/null) )); then
            printf "🔴 CPU:%.1f%% MEM:%.1f%% - %s\n" "$cpu" "$mem" "$cmd"
        fi
    done
}

# Función para verificar I/O de disco
check_disk_io() {
    echo ""
    echo "💾 ESTADO DEL DISCO:"
    echo "------------------"
    
    # Verificar uso de disco
    df -h /workspaces /tmp | tail -2 | while read line; do
        local use=$(echo $line | awk '{print $5}' | sed 's/%//')
        local mount=$(echo $line | awk '{print $6}')
        
        printf "%s: %s%% " "$mount" "$use"
        
        if [ $use -gt 90 ]; then
            echo "🔴 LLENO - Puede causar latencia"
        elif [ $use -gt 80 ]; then
            echo "🟡 ALTO"
        else
            echo "🟢 OK"
        fi
    done
}

# Función para mostrar recomendaciones
show_recommendations() {
    echo ""
    echo "💡 RECOMENDACIONES PARA REDUCIR LATENCIA:"
    echo "========================================="
    echo "1. 🔄 Recargar VS Code: Ctrl+Shift+P > 'Developer: Reload Window'"
    echo "2. 🚫 Desactivar extensiones no esenciales temporalmente"
    echo "3. 📁 Cerrar archivos/tabs no necesarios"
    echo "4. 🧹 Ejecutar: ./monitor-latency.sh --clean"
    echo "5. 🌐 Verificar conexión a internet estable"
    echo ""
    echo "🔧 CONFIGURACIONES APLICADAS:"
    echo "- TypeScript autocompletado desactivado"
    echo "- File watchers optimizados"
    echo "- Sugerencias rápidas deshabilitadas"
}

# Función de limpieza
clean_system() {
    echo "🧹 LIMPIANDO SISTEMA..."
    echo "====================="
    
    # Limpiar cachés de TypeScript
    echo "🗑️  Limpiando caché TypeScript..."
    rm -rf ~/.cache/typescript/* 2>/dev/null
    
    # Limpiar logs temporales de VS Code
    echo "🗑️  Limpiando logs temporales..."
    rm -rf /tmp/vscode-* 2>/dev/null
    
    # Limpiar archivos temporales del proyecto
    echo "🗑️  Limpiando archivos temporales del proyecto..."
    find /tmp -name "*tic-tac-toe*" -mtime +1 -delete 2>/dev/null
    
    # Liberar memoria de buffers
    echo "🗑️  Liberando buffers de memoria..."
    sync
    
    echo "✅ Limpieza completada"
    echo ""
    echo "💡 Recomendado: Recargar VS Code para aplicar cambios"
}

# Programa principal
case "${1:-monitor}" in
    --clean)
        clean_system
        ;;
    --help)
        echo "Uso: $0 [opción]"
        echo ""
        echo "Opciones:"
        echo "  (sin parámetros)  Monitor en tiempo real"
        echo "  --clean          Limpiar sistema para reducir latencia"
        echo "  --help           Mostrar esta ayuda"
        ;;
    *)
        while true; do
            clear
            echo "⌨️  MONITOR DE LATENCIA DEL TECLADO - $(date '+%H:%M:%S')"
            echo "================================================="
            echo ""
            
            check_cpu_load
            check_memory
            check_heavy_processes
            check_disk_io
            show_recommendations
            
            echo ""
            echo "🔄 Actualizando cada 5 segundos... (Ctrl+C para salir)"
            sleep 5
        done
        ;;
esac
