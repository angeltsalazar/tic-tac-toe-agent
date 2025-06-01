#!/bin/bash

# 📊 Monitor Visual en Tiempo Real - Tic-Tac-Toe
# Interfaz visual mejorada para monitoreo continuo

# Configuración de colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Función para dibujar barras de progreso
draw_bar() {
    local value=$1
    local max=$2
    local width=20
    local filled=$(( value * width / max ))
    local empty=$(( width - filled ))
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "]"
}

# Función para obtener color basado en porcentaje
get_color() {
    local value=$1
    if (( $(echo "$value > 80" | bc -l) )); then
        echo -e "$RED"
    elif (( $(echo "$value > 60" | bc -l) )); then
        echo -e "$YELLOW"
    else
        echo -e "$GREEN"
    fi
}

# Función principal del monitor visual
visual_monitor() {
    local update_interval=${1:-2}
    
    while true; do
        clear
        
        # Header con timestamp
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${WHITE}                    🎮 TIC-TAC-TOE MONITOR                        ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}                    $(date '+%Y-%m-%d %H:%M:%S')                    ${CYAN}║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        # Obtener métricas del sistema
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        local cpu_int=${cpu_usage%.*}
        
        local mem_info=$(free | grep Mem)
        local mem_used=$(echo $mem_info | awk '{print $3}')
        local mem_total=$(echo $mem_info | awk '{print $2}')
        local mem_percent=$(echo "scale=1; $mem_used * 100 / $mem_total" | bc)
        local mem_int=${mem_percent%.*}
        
        local load_1min=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
        local load_percent=$(echo "scale=1; $load_1min * 100 / $(nproc)" | bc)
        local load_int=${load_percent%.*}
        
        local disk_usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
        
        # Mostrar recursos del sistema
        echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${WHITE}                        💻 RECURSOS DEL SISTEMA                     ${BLUE}│${NC}"
        echo -e "${BLUE}└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        # CPU
        echo -e "${WHITE}🔥 CPU Usage:${NC} $(get_color $cpu_int)${cpu_usage}%${NC}"
        echo -e "   $(draw_bar $cpu_int 100) $(get_color $cpu_int)${cpu_int}/100${NC}"
        echo ""
        
        # Memoria
        echo -e "${WHITE}🧠 Memory:${NC} $(get_color $mem_int)${mem_percent}%${NC} ($(echo "scale=1; $mem_used/1024/1024" | bc)GB / $(echo "scale=1; $mem_total/1024/1024" | bc)GB)"
        echo -e "   $(draw_bar $mem_int 100) $(get_color $mem_int)${mem_int}/100${NC}"
        echo ""
        
        # Carga del sistema
        echo -e "${WHITE}📈 Load Average:${NC} $(get_color $load_int)${load_1min}${NC} (${load_percent}% de $(nproc) cores)"
        echo -e "   $(draw_bar $load_int 100) $(get_color $load_int)${load_int}/100${NC}"
        echo ""
        
        # Disco
        echo -e "${WHITE}💾 Disk Usage:${NC} $(get_color $disk_usage)${disk_usage}%${NC}"
        echo -e "   $(draw_bar $disk_usage 100) $(get_color $disk_usage)${disk_usage}/100${NC}"
        echo ""
        
        # GPU (si está disponible)
        if command -v nvidia-smi &> /dev/null; then
            local gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
            local gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
            local gpu_mem=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null || echo "0")
            
            echo -e "${WHITE}🎮 GPU:${NC} $(get_color $gpu_usage)${gpu_usage}%${NC} | Temp: ${gpu_temp}°C | VRAM: ${gpu_mem}MB"
            echo -e "   $(draw_bar $gpu_usage 100) $(get_color $gpu_usage)${gpu_usage}/100${NC}"
            echo ""
        fi
        
        # Procesos del juego
        echo -e "${PURPLE}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${PURPLE}│${WHITE}                        🎮 PROCESOS DEL JUEGO                       ${PURPLE}│${NC}"
        echo -e "${PURPLE}└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        # Servidor Python
        local python_proc=$(ps aux | grep -E "(python.*server|uvicorn)" | grep -v grep | head -1)
        if [ -n "$python_proc" ]; then
            local python_cpu=$(echo $python_proc | awk '{print $3}')
            local python_mem=$(echo $python_proc | awk '{print $4}')
            local python_pid=$(echo $python_proc | awk '{print $2}')
            echo -e "${WHITE}🐍 Servidor Python:${NC} ${GREEN}EJECUTÁNDOSE${NC} (PID: $python_pid)"
            echo -e "   CPU: $(get_color ${python_cpu%.*})${python_cpu}%${NC} | RAM: $(get_color ${python_mem%.*})${python_mem}%${NC}"
        else
            echo -e "${WHITE}🐍 Servidor Python:${NC} ${RED}DETENIDO${NC}"
        fi
        echo ""
        
        # Ollama
        local ollama_proc=$(ps aux | grep ollama | grep -v grep | head -1)
        if [ -n "$ollama_proc" ]; then
            local ollama_cpu=$(echo $ollama_proc | awk '{print $3}')
            local ollama_mem=$(echo $ollama_proc | awk '{print $4}')
            local ollama_pid=$(echo $ollama_proc | awk '{print $2}')
            echo -e "${WHITE}🤖 Ollama (IA):${NC} ${GREEN}EJECUTÁNDOSE${NC} (PID: $ollama_pid)"
            echo -e "   CPU: $(get_color ${ollama_cpu%.*})${ollama_cpu}%${NC} | RAM: $(get_color ${ollama_mem%.*})${ollama_mem}%${NC}"
        else
            echo -e "${WHITE}🤖 Ollama (IA):${NC} ${RED}DETENIDO${NC}"
        fi
        echo ""
        
        # Conexiones de red
        local connections=$(ss -tuln | grep :8000 | wc -l)
        local active_conn=$(ss -tu | grep :8000 | wc -l)
        
        echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│${WHITE}                           🌐 RED Y CONEXIONES                       ${CYAN}│${NC}"
        echo -e "${CYAN}└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        echo -e "${WHITE}🔌 Puerto 8000:${NC} $connections conexiones escuchando | $active_conn activas"
        
        if [ $connections -gt 0 ]; then
            echo -e "${WHITE}🌐 Estado del servidor:${NC} ${GREEN}ACTIVO${NC}"
        else
            echo -e "${WHITE}🌐 Estado del servidor:${NC} ${RED}INACTIVO${NC}"
        fi
        echo ""
        
        # Top procesos por CPU
        echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}│${WHITE}                        🏆 TOP 5 PROCESOS POR CPU                   ${YELLOW}│${NC}"
        echo -e "${YELLOW}└─────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        
        ps aux --sort=-%cpu | head -6 | tail -5 | while read line; do
            local cmd=$(echo $line | awk '{print $11}' | cut -c1-30)
            local cpu=$(echo $line | awk '{print $3}')
            local mem=$(echo $line | awk '{print $4}')
            local user=$(echo $line | awk '{print $1}' | cut -c1-8)
            echo -e "${WHITE}${cmd}${NC} | CPU: $(get_color ${cpu%.*})${cpu}%${NC} | RAM: ${mem}% | User: ${user}"
        done
        echo ""
        
        # Footer con controles
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${WHITE} ⏱️  Actualizando cada ${update_interval}s | Ctrl+C para salir | Ctrl+Z para pausar  ${CYAN}║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
        
        sleep $update_interval
    done
}

# Monitor compacto
compact_monitor() {
    while true; do
        clear
        echo -e "${CYAN}🎮 TIC-TAC-TOE MONITOR COMPACTO - $(date '+%H:%M:%S')${NC}"
        echo "═══════════════════════════════════════════════════"
        
        # Métricas básicas en una línea
        local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        local mem=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        local load=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
        
        echo -e "⚡ CPU: $(get_color ${cpu%.*})${cpu}%${NC} | 🧠 RAM: $(get_color ${mem%.*})${mem}%${NC} | 📈 Load: ${load}"
        
        # Estado de procesos
        local python_status="❌"
        local ollama_status="❌"
        
        if ps aux | grep -E "(python.*server|uvicorn)" | grep -v grep &> /dev/null; then
            python_status="✅"
        fi
        
        if ps aux | grep ollama | grep -v grep &> /dev/null; then
            ollama_status="✅"
        fi
        
        echo -e "🐍 Python: $python_status | 🤖 Ollama: $ollama_status | 🌐 Puerto 8000: $(ss -tuln | grep :8000 | wc -l) conexiones"
        
        echo ""
        echo "Presiona Ctrl+C para salir..."
        sleep 3
    done
}

# Función para mostrar estadísticas detalladas
detailed_stats() {
    echo -e "${CYAN}📊 ESTADÍSTICAS DETALLADAS DEL SISTEMA${NC}"
    echo "═══════════════════════════════════════"
    echo ""
    
    # Información del sistema
    echo -e "${WHITE}🖥️  INFORMACIÓN DEL SISTEMA:${NC}"
    echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
    echo "Cores: $(nproc) cores"
    echo "RAM Total: $(free -h | grep 'Mem:' | awk '{print $2}')"
    echo "OS: $(lsb_release -d | cut -d':' -f2 | xargs)"
    echo "Uptime: $(uptime -p)"
    echo ""
    
    # Estadísticas actuales
    echo -e "${WHITE}📊 ESTADÍSTICAS ACTUALES:${NC}"
    echo ""
    
    # CPU detallado
    echo "⚡ CPU:"
    top -bn1 | grep "Cpu(s)" | sed 's/Cpu(s):/  /'
    echo ""
    
    # Memoria detallada
    echo "🧠 MEMORIA:"
    free -h | grep -E "Mem:|Swap:" | sed 's/^/  /'
    echo ""
    
    # Procesos top
    echo "🏆 TOP 10 PROCESOS POR CPU:"
    ps aux --sort=-%cpu | head -11 | tail -10 | awk '{printf "  %-15s %5s%% %5s%% %s\n", $1, $3, $4, $11}'
    echo ""
    
    # Procesos top por memoria
    echo "🧠 TOP 10 PROCESOS POR MEMORIA:"
    ps aux --sort=-%mem | head -11 | tail -10 | awk '{printf "  %-15s %5s%% %5s%% %s\n", $1, $3, $4, $11}'
    echo ""
    
    # Disk I/O
    if command -v iostat &> /dev/null; then
        echo "💾 DISK I/O:"
        iostat -d 1 1 | tail -n +4 | sed 's/^/  /'
        echo ""
    fi
    
    # Network
    echo "🌐 RED:"
    echo "  Interfaces activas:"
    ip addr show | grep -E "^[0-9]+:" | awk '{print "    " $2}' | tr -d ':'
    echo ""
    echo "  Conexiones de red:"
    ss -tuln | grep :8000 | sed 's/^/    /'
    echo ""
}

# Menú principal
show_menu() {
    echo -e "${CYAN}📊 MONITOR VISUAL - TIC-TAC-TOE${NC}"
    echo "══════════════════════════════"
    echo "1. 🎮 Monitor visual completo (actualización cada 2s)"
    echo "2. ⚡ Monitor visual rápido (actualización cada 1s)"
    echo "3. 📱 Monitor compacto"
    echo "4. 📊 Estadísticas detalladas"
    echo "5. 🔧 Instalar dependencias"
    echo "6. 🚪 Salir"
    echo ""
    read -p "Selecciona una opción (1-6): " choice
    
    case $choice in
        1) visual_monitor 2 ;;
        2) visual_monitor 1 ;;
        3) compact_monitor ;;
        4) detailed_stats ;;
        5) install_deps ;;
        6) echo -e "${GREEN}👋 ¡Hasta luego!${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Opción inválida${NC}"; show_menu ;;
    esac
}

# Instalar dependencias
install_deps() {
    echo -e "${YELLOW}🔧 Instalando dependencias para monitoreo...${NC}"
    sudo apt update
    sudo apt install -y bc procps iproute2 coreutils
    echo -e "${GREEN}✅ Dependencias instaladas${NC}"
    echo ""
    show_menu
}

# Verificar dependencias básicas
check_deps() {
    local missing=()
    
    if ! command -v bc &> /dev/null; then
        missing+=("bc")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Dependencias faltantes: ${missing[*]}${NC}"
        echo -e "${YELLOW}💡 Ejecuta la opción 5 para instalar${NC}"
        echo ""
    fi
}

# Ejecución principal
main() {
    # Verificar terminal
    if [ ! -t 0 ]; then
        echo "❌ Este script requiere un terminal interactivo"
        exit 1
    fi
    
    check_deps
    
    if [ "$1" == "--visual" ]; then
        visual_monitor ${2:-2}
    elif [ "$1" == "--compact" ]; then
        compact_monitor
    elif [ "$1" == "--stats" ]; then
        detailed_stats
    else
        show_menu
    fi
}

# Manejar señales
trap 'echo -e "\n${GREEN}👋 Monitor detenido${NC}"; exit 0' INT TERM

# Ejecutar
main "$@"
