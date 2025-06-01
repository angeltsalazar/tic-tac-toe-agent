#!/bin/bash

# 📊 Monitor Avanzado en Tiempo Real para Tic-Tac-Toe
# Usa herramientas especializadas para monitoreo visual

echo "📊 MONITOR AVANZADO - TIC-TAC-TOE"
echo "================================="
echo ""

# Función para verificar e instalar herramientas
install_monitoring_tools() {
    echo "🔧 Instalando herramientas de monitoreo..."
    
    # Actualizar repositorios
    sudo apt update
    
    # Instalar herramientas esenciales
    sudo apt install -y \
        htop \
        iotop \
        nethogs \
        sysstat \
        glances \
        nvtop \
        tree \
        curl \
        jq
    
    echo "✅ Herramientas instaladas"
    echo ""
}

# Monitor visual con htop personalizado
monitor_htop() {
    echo "🖥️  Iniciando monitor visual con htop..."
    echo "Presiona 'q' para salir de htop"
    echo ""
    
    # Configurar htop para mostrar información relevante
    htop -d 10 --sort-key PERCENT_CPU
}

# Monitor de I/O con iotop
monitor_io() {
    echo "💾 Iniciando monitor de I/O..."
    echo "Presiona 'q' para salir"
    echo ""
    
    if command -v iotop &> /dev/null; then
        sudo iotop -o -d 2
    else
        echo "❌ iotop no disponible. Instalando..."
        sudo apt install -y iotop
        sudo iotop -o -d 2
    fi
}

# Monitor de red con nethogs
monitor_network_usage() {
    echo "🌐 Iniciando monitor de uso de red..."
    echo "Presiona 'q' para salir"
    echo ""
    
    if command -v nethogs &> /dev/null; then
        sudo nethogs -d 2
    else
        echo "❌ nethogs no disponible. Instalando..."
        sudo apt install -y nethogs
        sudo nethogs -d 2
    fi
}

# Monitor todo-en-uno con glances
monitor_glances() {
    echo "👀 Iniciando monitor completo con glances..."
    echo "Presiona 'q' para salir"
    echo ""
    
    if command -v glances &> /dev/null; then
        glances -t 2
    else
        echo "❌ glances no disponible. Instalando..."
        sudo apt install -y glances
        glances -t 2
    fi
}

# Monitor GPU con nvtop (si hay GPU NVIDIA)
monitor_gpu_advanced() {
    echo "🎮 Verificando GPU..."
    
    if command -v nvidia-smi &> /dev/null; then
        echo "🟢 GPU NVIDIA detectada. Iniciando nvtop..."
        
        if command -v nvtop &> /dev/null; then
            nvtop
        else
            echo "❌ nvtop no disponible. Instalando..."
            sudo apt install -y nvtop
            nvtop
        fi
    else
        echo "🟡 No se detectó GPU NVIDIA. Mostrando información general..."
        lspci | grep -i vga
        echo ""
        echo "💡 Para GPU AMD, puedes usar: radeontop"
        echo "💡 Para instalar: sudo apt install radeontop"
    fi
}

# Monitor de procesos específicos del juego
monitor_game_processes_live() {
    echo "🎮 Monitor de procesos del juego en tiempo real"
    echo "=============================================="
    echo ""
    
    while true; do
        clear
        echo "🎮 MONITOR DEL JUEGO - $(date)"
        echo "=============================="
        echo ""
        
        echo "🐍 SERVIDOR PYTHON:"
        ps aux | grep -E "(python.*server|uvicorn)" | grep -v grep | head -5
        echo ""
        
        echo "🤖 OLLAMA (IA):"
        ps aux | grep ollama | grep -v grep | head -3
        echo ""
        
        echo "🌐 CONEXIONES RED (Puerto 8000):"
        ss -tuln | grep :8000
        echo ""
        
        echo "📊 RECURSOS DEL SISTEMA:"
        echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
        echo "RAM: $(free | grep Mem | awk '{printf "%.1f%% usado", $3/$2 * 100.0}')"
        echo "Carga: $(uptime | awk -F'load average:' '{print $2}')"
        echo ""
        
        echo "⏱️  Actualizando en 3 segundos... (Ctrl+C para salir)"
        sleep 3
    done
}

# Dashboard personalizado en terminal
show_dashboard() {
    echo "📊 DASHBOARD DE MONITOREO"
    echo "========================="
    echo ""
    
    while true; do
        clear
        
        # Header con timestamp
        echo "🎮 TIC-TAC-TOE DASHBOARD - $(date '+%H:%M:%S')"
        echo "=============================================="
        echo ""
        
        # CPU y Load
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        load_1min=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
        echo "⚡ CPU: ${cpu_usage}% | Load: ${load_1min}"
        
        # Memoria
        mem_info=$(free | grep Mem)
        mem_used=$(echo $mem_info | awk '{printf "%.1f", $3/$2 * 100.0}')
        mem_total=$(echo $mem_info | awk '{printf "%.1f", $2/1024/1024}')
        echo "🧠 RAM: ${mem_used}% usado de ${mem_total}GB"
        
        # Disco
        disk_usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
        echo "💾 Disco: ${disk_usage}% usado"
        
        # GPU (si disponible)
        if command -v nvidia-smi &> /dev/null; then
            gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
            gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
            echo "🎮 GPU: ${gpu_util}% | Temp: ${gpu_temp}°C"
        fi
        
        echo ""
        echo "🎯 PROCESOS DEL JUEGO:"
        echo "---------------------"
        
        # Servidor Python
        python_proc=$(ps aux | grep -E "(python.*server|uvicorn)" | grep -v grep | head -1)
        if [ -n "$python_proc" ]; then
            echo "🐍 Servidor: $(echo $python_proc | awk '{printf "CPU: %s%% MEM: %s%%", $3, $4}')"
        else
            echo "🐍 Servidor: ❌ No ejecutándose"
        fi
        
        # Ollama
        ollama_proc=$(ps aux | grep ollama | grep -v grep | head -1)
        if [ -n "$ollama_proc" ]; then
            echo "🤖 Ollama: $(echo $ollama_proc | awk '{printf "CPU: %s%% MEM: %s%%", $3, $4}')"
        else
            echo "🤖 Ollama: ❌ No ejecutándose"
        fi
        
        # Conexiones
        connections=$(ss -tuln | grep :8000 | wc -l)
        echo "🌐 Conexiones puerto 8000: $connections"
        
        echo ""
        echo "⏱️  Actualizando cada 2 segundos... (Ctrl+C para salir)"
        sleep 2
    done
}

# Función para log continuo en archivo
start_logging() {
    local log_file="/tmp/tic-tac-toe-performance-$(date +%Y%m%d_%H%M%S).log"
    
    echo "📝 Iniciando logging continuo..."
    echo "📁 Archivo: $log_file"
    echo "⏹️  Presiona Ctrl+C para detener"
    echo ""
    
    # Header del log
    echo "timestamp,cpu_percent,mem_percent,load_1min,disk_percent,python_cpu,python_mem,ollama_cpu,ollama_mem,connections" > "$log_file"
    
    while true; do
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        cpu_percent=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        mem_percent=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        load_1min=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
        disk_percent=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
        
        # Procesos específicos
        python_stats=$(ps aux | grep -E "(python.*server|uvicorn)" | grep -v grep | head -1 | awk '{print $3","$4}')
        ollama_stats=$(ps aux | grep ollama | grep -v grep | head -1 | awk '{print $3","$4}')
        connections=$(ss -tuln | grep :8000 | wc -l)
        
        # Si no hay procesos, poner 0
        python_stats=${python_stats:-"0,0"}
        ollama_stats=${ollama_stats:-"0,0"}
        
        echo "$timestamp,$cpu_percent,$mem_percent,$load_1min,$disk_percent,$python_stats,$ollama_stats,$connections" >> "$log_file"
        
        sleep 5
    done
}

# Menú principal
show_main_menu() {
    echo "📊 MONITOR AVANZADO - OPCIONES"
    echo "=============================="
    echo "1. 📊 Dashboard completo en terminal"
    echo "2. 🖥️  Monitor visual (htop)"
    echo "3. 💾 Monitor de I/O (iotop)"
    echo "4. 🌐 Monitor de red (nethogs)"
    echo "5. 👀 Monitor todo-en-uno (glances)"
    echo "6. 🎮 Monitor de GPU (nvtop)"
    echo "7. 🎯 Monitor específico del juego"
    echo "8. 📝 Logging continuo a archivo"
    echo "9. 🔧 Instalar herramientas de monitoreo"
    echo "0. 🚪 Salir"
    echo ""
    read -p "Selecciona una opción (0-9): " choice
    
    case $choice in
        1) show_dashboard ;;
        2) monitor_htop ;;
        3) monitor_io ;;
        4) monitor_network_usage ;;
        5) monitor_glances ;;
        6) monitor_gpu_advanced ;;
        7) monitor_game_processes_live ;;
        8) start_logging ;;
        9) install_monitoring_tools ;;
        0) echo "👋 ¡Hasta luego!"; exit 0 ;;
        *) echo "❌ Opción inválida"; show_main_menu ;;
    esac
}

# Verificar si se pasaron argumentos
if [ "$1" == "--dashboard" ]; then
    show_dashboard
elif [ "$1" == "--install" ]; then
    install_monitoring_tools
elif [ "$1" == "--log" ]; then
    start_logging
elif [ "$1" == "--game" ]; then
    monitor_game_processes_live
else
    show_main_menu
fi
