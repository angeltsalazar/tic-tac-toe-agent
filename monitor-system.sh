#!/bin/bash

# 📊 Monitor de Sistema para Tic-Tac-Toe con IA
# Monitorea CPU, Memoria, GPU, Disco y Red durante el juego

echo "📊 MONITOR DE SISTEMA - TIC-TAC-TOE CON IA"
echo "=========================================="
echo ""

# Función para mostrar timestamp
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Función para obtener info del sistema
get_system_info() {
    echo "🖥️  INFORMACIÓN DEL SISTEMA"
    echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
    echo "RAM: $(free -h | grep 'Mem:' | awk '{print $2}')"
    echo "OS: $(lsb_release -d | cut -d':' -f2 | xargs)"
    echo "Kernel: $(uname -r)"
    echo ""
}

# Función para CPU y Memoria
monitor_cpu_memory() {
    echo "⚡ CPU y MEMORIA $(timestamp)"
    echo "----------------------------------------"
    
    # CPU usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "🔥 CPU Usage: ${cpu_usage}%"
    
    # Load average
    load=$(uptime | awk -F'load average:' '{print $2}')
    echo "📈 Load Average:${load}"
    
    # Memory usage
    echo "🧠 MEMORIA:"
    free -h | grep -E "Mem:|Swap:"
    
    # Top processes by CPU
    echo ""
    echo "🏆 TOP 5 PROCESOS POR CPU:"
    ps aux --sort=-%cpu | head -6 | awk '{printf "%-10s %5s %5s %s\n", $1, $3, $4, $11}'
    
    echo ""
}

# Función para GPU (si está disponible)
monitor_gpu() {
    echo "🎮 GPU $(timestamp)"
    echo "----------------------------------------"
    
    # Verificar si nvidia-smi está disponible
    if command -v nvidia-smi &> /dev/null; then
        echo "🟢 NVIDIA GPU detectada:"
        nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits | while IFS=',' read name gpu_util mem_used mem_total temp; do
            echo "  GPU: $name"
            echo "  Utilización: $gpu_util%"
            echo "  Memoria: $mem_used MB / $mem_total MB"
            echo "  Temperatura: $temp°C"
        done
    elif command -v rocm-smi &> /dev/null; then
        echo "🔴 AMD GPU detectada:"
        rocm-smi --showuse --showtemp --showmeminfo
    elif lspci | grep -i vga &> /dev/null; then
        echo "🟡 GPU integrada detectada:"
        lspci | grep -i vga
        echo "  (Monitoreo limitado para GPU integrada)"
    else
        echo "❌ No se detectó GPU dedicada"
    fi
    
    echo ""
}

# Función para Disco
monitor_disk() {
    echo "💾 ALMACENAMIENTO $(timestamp)"
    echo "----------------------------------------"
    
    echo "📊 Uso de disco:"
    df -h | grep -E "^/dev|^tmpfs" | awk '{printf "%-20s %5s %5s %5s %s\n", $1, $2, $3, $5, $6}'
    
    echo ""
    echo "📈 I/O de disco:"
    if command -v iostat &> /dev/null; then
        iostat -d 1 1 | tail -n +4
    else
        echo "  (iostat no disponible - instalar con: sudo apt install sysstat)"
    fi
    
    echo ""
}

# Función para Red
monitor_network() {
    echo "🌐 RED $(timestamp)"
    echo "----------------------------------------"
    
    echo "📡 Interfaces de red:"
    ip addr show | grep -E "^[0-9]+:" | awk '{print $2}' | tr -d ':' | while read interface; do
        if [ "$interface" != "lo" ]; then
            echo "  $interface: $(ip addr show $interface | grep 'inet ' | awk '{print $2}' | head -1)"
        fi
    done
    
    echo ""
    echo "📊 Estadísticas de red:"
    cat /proc/net/dev | grep -E "(eth|wlan|enp|wlp)" | while IFS=: read interface stats; do
        echo "  $interface: $(echo $stats | awk '{printf "RX: %s MB, TX: %s MB", $2/1024/1024, $10/1024/1024}')"
    done
    
    echo ""
}

# Función para procesos específicos del juego
monitor_game_processes() {
    echo "🎮 PROCESOS DEL JUEGO $(timestamp)"
    echo "----------------------------------------"
    
    echo "🐍 Procesos Python (servidor del juego):"
    ps aux | grep python | grep -v grep | awk '{printf "PID: %-8s CPU: %5s%% MEM: %5s%% CMD: %s\n", $2, $3, $4, $11}'
    
    echo ""
    echo "🌐 Conexiones de red del juego:"
    if command -v netstat &> /dev/null; then
        netstat -tlnp 2>/dev/null | grep :8000
    elif command -v ss &> /dev/null; then
        ss -tlnp | grep :8000
    fi
    
    echo ""
    echo "🤖 Procesos Ollama (IA):"
    ps aux | grep ollama | grep -v grep | awk '{printf "PID: %-8s CPU: %5s%% MEM: %5s%% CMD: %s\n", $2, $3, $4, $11}'
    
    echo ""
}

# Función principal de monitoreo
run_monitor() {
    local interval=${1:-5}
    local output_file="/tmp/tic-tac-toe-monitor.log"
    
    echo "🔄 Iniciando monitoreo cada $interval segundos..."
    echo "📝 Log guardado en: $output_file"
    echo "⏹️  Presiona Ctrl+C para detener"
    echo ""
    
    # Información inicial del sistema
    get_system_info | tee -a "$output_file"
    
    while true; do
        {
            echo "==============================================="
            monitor_cpu_memory
            monitor_gpu
            monitor_disk
            monitor_network
            monitor_game_processes
            echo "==============================================="
            echo ""
        } | tee -a "$output_file"
        
        sleep $interval
    done
}

# Función para snapshot único
take_snapshot() {
    local output_file="/tmp/tic-tac-toe-snapshot-$(date +%Y%m%d_%H%M%S).log"
    
    echo "📸 Tomando snapshot del sistema..."
    
    {
        echo "📊 SNAPSHOT DEL SISTEMA - $(timestamp)"
        echo "======================================"
        get_system_info
        monitor_cpu_memory
        monitor_gpu
        monitor_disk
        monitor_network
        monitor_game_processes
    } | tee "$output_file"
    
    echo "📁 Snapshot guardado en: $output_file"
}

# Función para comparar reposo vs uso
compare_states() {
    echo "🔍 COMPARACIÓN: REPOSO vs EN USO"
    echo "================================"
    echo ""
    echo "📋 Instrucciones:"
    echo "1. Asegúrate de que el juego NO esté ejecutándose"
    echo "2. Presiona Enter para capturar estado EN REPOSO"
    read -p "   Presiona Enter cuando esté listo..."
    
    echo "📸 Capturando estado EN REPOSO..."
    local baseline_file="/tmp/baseline-$(date +%Y%m%d_%H%M%S).log"
    take_snapshot > "$baseline_file"
    
    echo ""
    echo "🚀 Ahora INICIA el juego y juega por unos minutos"
    echo "3. Cuando hayas jugado, presiona Enter para capturar estado EN USO"
    read -p "   Presiona Enter cuando hayas jugado..."
    
    echo "📸 Capturando estado EN USO..."
    local usage_file="/tmp/usage-$(date +%Y%m%d_%H%M%S).log"
    take_snapshot > "$usage_file"
    
    echo ""
    echo "📊 COMPARACIÓN GUARDADA:"
    echo "  Reposo: $baseline_file"
    echo "  En uso: $usage_file"
    echo ""
    echo "💡 Para ver diferencias, usa:"
    echo "  diff $baseline_file $usage_file"
}

# Menú principal
show_menu() {
    echo "📊 MONITOR DE SISTEMA - OPCIONES"
    echo "================================"
    echo "1. 🔄 Monitoreo continuo (cada 5 segundos)"
    echo "2. ⚡ Monitoreo rápido (cada 2 segundos)"
    echo "3. 📸 Snapshot único"
    echo "4. 🔍 Comparar reposo vs uso"
    echo "5. 📈 Monitoreo específico del juego"
    echo "6. 🚪 Salir"
    echo ""
    read -p "Selecciona una opción (1-6): " choice
    
    case $choice in
        1) run_monitor 5 ;;
        2) run_monitor 2 ;;
        3) take_snapshot ;;
        4) compare_states ;;
        5) monitor_game_specific ;;
        6) echo "👋 ¡Hasta luego!"; exit 0 ;;
        *) echo "❌ Opción inválida"; show_menu ;;
    esac
}

# Función para monitoreo específico del juego
monitor_game_specific() {
    echo "🎮 MONITOREO ESPECÍFICO DEL JUEGO"
    echo "================================="
    echo ""
    
    local interval=3
    local output_file="/tmp/game-specific-monitor.log"
    
    echo "🔄 Monitoreando procesos específicos del juego cada $interval segundos..."
    echo "📝 Log guardado en: $output_file"
    echo "⏹️  Presiona Ctrl+C para detener"
    echo ""
    
    while true; do
        {
            echo "🎮 $(timestamp) - MONITOREO ESPECÍFICO DEL JUEGO"
            echo "================================================"
            
            # Python processes (game server)
            echo "🐍 SERVIDOR PYTHON:"
            ps aux | grep python | grep -E "(server\.py|uvicorn)" | grep -v grep | while read line; do
                echo "  $line"
            done
            
            # Ollama processes (AI)
            echo ""
            echo "🤖 PROCESOS OLLAMA (IA):"
            ps aux | grep ollama | grep -v grep | while read line; do
                echo "  $line"
            done
            
            # Network connections
            echo ""
            echo "🌐 CONEXIONES DEL JUEGO (Puerto 8000):"
            ss -tuln | grep :8000
            
            # WebSocket connections
            echo ""
            echo "🔌 CONEXIONES WEBSOCKET:"
            ss -tu | grep :8000
            
            # Resource usage summary
            echo ""
            echo "📊 RESUMEN DE RECURSOS:"
            echo "  CPU Total: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
            echo "  Memoria: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"
            echo "  Carga: $(uptime | awk -F'load average:' '{print $2}')"
            
            echo ""
            echo "================================================"
            echo ""
        } | tee -a "$output_file"
        
        sleep $interval
    done
}

# Verificar dependencias
check_dependencies() {
    echo "🔧 Verificando dependencias..."
    
    missing_tools=()
    
    if ! command -v htop &> /dev/null; then
        missing_tools+=("htop")
    fi
    
    if ! command -v iostat &> /dev/null; then
        missing_tools+=("sysstat")
    fi
    
    if ! command -v ss &> /dev/null; then
        missing_tools+=("iproute2")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "⚠️  Herramientas opcionales faltantes:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo "💡 Para instalar (opcional):"
        echo "  sudo apt update && sudo apt install ${missing_tools[*]}"
        echo ""
    else
        echo "✅ Todas las herramientas están disponibles"
    fi
}

# Ejecución principal
main() {
    if [ "$1" == "--continuous" ]; then
        run_monitor ${2:-5}
    elif [ "$1" == "--snapshot" ]; then
        take_snapshot
    elif [ "$1" == "--compare" ]; then
        compare_states
    elif [ "$1" == "--game" ]; then
        monitor_game_specific
    else
        check_dependencies
        show_menu
    fi
}

# Ejecutar script
main "$@"
