# 📊 06 - Sistema de Monitoreo

> **Objetivo**: Implementar un sistema de monitoreo de recursos y rendimiento que funcione tanto en desarrollo local como en GitHub Codespaces.

## 📋 Introducción al Monitoreo

### ¿Por qué Monitorear?
- 🔍 **Detección temprana**: Identificar problemas antes de que afecten usuarios
- 📈 **Optimización**: Entender patrones de uso y cuellos de botella
- 🎯 **Resource Management**: Optimizar uso de recursos en Codespaces
- 🚨 **Alertas**: Notificaciones automáticas de problemas críticos

### Métricas Clave a Monitorear
- **CPU**: Uso del procesador
- **Memoria**: RAM utilizada vs disponible
- **Disco**: Espacio usado y I/O
- **Red**: Throughput y latencia
- **Aplicación**: Tiempo de respuesta, errores, logs

## 🛠️ Estructura del Sistema de Monitoreo

```
scripts/monitoring/
├── 📄 monitor.sh              # Script principal de monitoreo
├── 📄 system-stats.sh         # Estadísticas del sistema
├── 📄 app-monitor.sh          # Monitoreo específico de la app
├── 📄 resource-alerts.sh      # Sistema de alertas
├── 📄 performance-report.sh   # Reportes de rendimiento
└── 📂 templates/              # Templates de reportes
    ├── report.html           # Template HTML para reportes
    └── alert.json           # Template para alertas
```

## 📊 Script Principal de Monitoreo

### scripts/monitoring/monitor.sh
```bash
mkdir -p scripts/monitoring/templates
cat > scripts/monitoring/monitor.sh << 'EOF'
#!/bin/bash
# Sistema principal de monitoreo

set -e

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/utils/common.sh"

# Configuración
MONITOR_INTERVAL=30  # segundos
LOG_FILE="logs/monitor.log"
REPORT_DIR="logs/reports"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEMORY=85
ALERT_THRESHOLD_DISK=90

main() {
    case "${1:-start}" in
        start)     start_monitoring ;;
        stop)      stop_monitoring ;;
        status)    show_status ;;
        report)    generate_report ;;
        dashboard) show_dashboard ;;
        *)         show_usage ;;
    esac
}

start_monitoring() {
    print_header "Iniciando Sistema de Monitoreo"
    
    # Verificar dependencias
    check_monitoring_deps
    
    # Crear directorios necesarios
    ensure_dir "logs"
    ensure_dir "$REPORT_DIR"
    
    # Iniciar monitoreo en background
    if [ -f "/tmp/monitor.pid" ]; then
        log_warning "Monitoreo ya está ejecutándose (PID: $(cat /tmp/monitor.pid))"
        return 0
    fi
    
    log_step "Iniciando monitoreo en background..."
    nohup bash -c "monitor_loop" > "$LOG_FILE" 2>&1 &
    echo $! > /tmp/monitor.pid
    
    log_success "Monitoreo iniciado (PID: $!)"
    log_info "Logs: $LOG_FILE"
    log_info "Para ver dashboard: ./scripts/monitoring/monitor.sh dashboard"
}

stop_monitoring() {
    print_header "Deteniendo Sistema de Monitoreo"
    
    if [ -f "/tmp/monitor.pid" ]; then
        local pid=$(cat /tmp/monitor.pid)
        if kill "$pid" 2>/dev/null; then
            log_success "Monitoreo detenido (PID: $pid)"
        else
            log_warning "Proceso no encontrado (PID: $pid)"
        fi
        rm -f /tmp/monitor.pid
    else
        log_warning "Monitoreo no está ejecutándose"
    fi
}

monitor_loop() {
    log_info "=== Monitoreo iniciado: $(date) ==="
    
    while true; do
        # Recopilar métricas
        collect_system_metrics
        collect_app_metrics
        
        # Verificar alertas
        check_alerts
        
        # Esperar siguiente iteración
        sleep "$MONITOR_INTERVAL"
    done
}

collect_system_metrics() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # CPU Usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    
    # Memory Usage
    local memory_info=$(free | grep Mem)
    local memory_total=$(echo $memory_info | awk '{print $2}')
    local memory_used=$(echo $memory_info | awk '{print $3}')
    local memory_percent=$((memory_used * 100 / memory_total))
    
    # Disk Usage
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    # Load Average
    local load_avg=$(uptime | awk -F'load average:' '{print $2}')
    
    # Log metrics
    echo "[$timestamp] SYSTEM | CPU: ${cpu_usage}% | Memory: ${memory_percent}% | Disk: ${disk_usage}% | Load: ${load_avg}"
    
    # Store in variables for alerts
    export CURRENT_CPU="$cpu_usage"
    export CURRENT_MEMORY="$memory_percent"
    export CURRENT_DISK="$disk_usage"
}

collect_app_metrics() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Application-specific metrics
    if pgrep -f "python.*app.py" > /dev/null; then
        collect_python_metrics "$timestamp"
    elif pgrep -f "node.*server.js" > /dev/null; then
        collect_nodejs_metrics "$timestamp"
    fi
}

collect_python_metrics() {
    local timestamp="$1"
    local python_procs=$(pgrep -f "python" | wc -l)
    local python_memory=$(ps -eo pid,comm,%mem | grep python | awk '{sum+=$3} END {print sum}')
    
    echo "[$timestamp] PYTHON | Processes: $python_procs | Memory: ${python_memory:-0}%"
}

collect_nodejs_metrics() {
    local timestamp="$1"
    local node_procs=$(pgrep -f "node" | wc -l)
    local node_memory=$(ps -eo pid,comm,%mem | grep node | awk '{sum+=$3} END {print sum}')
    
    echo "[$timestamp] NODEJS | Processes: $node_procs | Memory: ${node_memory:-0}%"
}

check_alerts() {
    # CPU Alert
    if [ "${CURRENT_CPU%.*}" -gt "$ALERT_THRESHOLD_CPU" ] 2>/dev/null; then
        send_alert "HIGH_CPU" "CPU usage: ${CURRENT_CPU}% (threshold: ${ALERT_THRESHOLD_CPU}%)"
    fi
    
    # Memory Alert
    if [ "$CURRENT_MEMORY" -gt "$ALERT_THRESHOLD_MEMORY" ] 2>/dev/null; then
        send_alert "HIGH_MEMORY" "Memory usage: ${CURRENT_MEMORY}% (threshold: ${ALERT_THRESHOLD_MEMORY}%)"
    fi
    
    # Disk Alert
    if [ "$CURRENT_DISK" -gt "$ALERT_THRESHOLD_DISK" ] 2>/dev/null; then
        send_alert "HIGH_DISK" "Disk usage: ${CURRENT_DISK}% (threshold: ${ALERT_THRESHOLD_DISK}%)"
    fi
}

send_alert() {
    local alert_type="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] ALERT | $alert_type | $message"
    
    # Escribir alerta a archivo separado
    echo "[$timestamp] $alert_type: $message" >> "logs/alerts.log"
    
    # En Codespaces, también mostrar en terminal actual si es posible
    if [ -n "$CODESPACES" ]; then
        echo -e "\n🚨 ALERT: $message" > /proc/1/fd/1 2>/dev/null || true
    fi
}

show_status() {
    print_header "Estado del Monitoreo"
    
    if [ -f "/tmp/monitor.pid" ]; then
        local pid=$(cat /tmp/monitor.pid)
        if kill -0 "$pid" 2>/dev/null; then
            log_success "Monitoreo activo (PID: $pid)"
            
            # Mostrar últimas métricas
            if [ -f "$LOG_FILE" ]; then
                echo ""
                log_info "Últimas métricas:"
                tail -5 "$LOG_FILE" | grep -E "(SYSTEM|PYTHON|NODEJS)" | while read line; do
                    echo "  $line"
                done
            fi
        else
            log_error "Proceso no encontrado (PID: $pid)"
            rm -f /tmp/monitor.pid
        fi
    else
        log_warning "Monitoreo no está ejecutándose"
    fi
    
    # Mostrar alertas recientes
    if [ -f "logs/alerts.log" ]; then
        echo ""
        log_info "Alertas recientes:"
        tail -3 "logs/alerts.log" | while read line; do
            echo "  🚨 $line"
        done
    fi
}

show_dashboard() {
    while true; do
        clear
        print_header "Dashboard de Monitoreo - $(date)"
        
        # Current system stats
        show_current_stats
        
        # Recent alerts
        show_recent_alerts
        
        # Application status
        show_app_status
        
        echo ""
        echo "Actualizando en 5 segundos... (Ctrl+C para salir)"
        sleep 5
    done
}

show_current_stats() {
    log_info "📊 Estadísticas Actuales:"
    
    # CPU
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    echo "  🖥️  CPU: ${cpu_usage}%"
    
    # Memory
    local memory_info=$(free | grep Mem)
    local memory_total=$(echo $memory_info | awk '{print $2}')
    local memory_used=$(echo $memory_info | awk '{print $3}')
    local memory_percent=$((memory_used * 100 / memory_total))
    echo "  🧠 Memory: ${memory_percent}% ($(numfmt --to=iec $((memory_used * 1024))) / $(numfmt --to=iec $((memory_total * 1024))))"
    
    # Disk
    local disk_info=$(df / | tail -1)
    local disk_usage=$(echo $disk_info | awk '{print $5}')
    local disk_used=$(echo $disk_info | awk '{print $3}')
    local disk_total=$(echo $disk_info | awk '{print $2}')
    echo "  💾 Disk: $disk_usage ($(numfmt --to=iec $((disk_used * 1024))) / $(numfmt --to=iec $((disk_total * 1024))))"
    
    # Load
    local load_avg=$(uptime | awk -F'load average:' '{print $2}')
    echo "  ⚖️  Load:$load_avg"
}

show_recent_alerts() {
    if [ -f "logs/alerts.log" ]; then
        log_info "🚨 Alertas Recientes:"
        tail -3 "logs/alerts.log" | while read line; do
            if [ -n "$line" ]; then
                echo "  $line"
            fi
        done
    fi
}

show_app_status() {
    log_info "📱 Estado de la Aplicación:"
    
    # Python processes
    local python_count=$(pgrep -f "python" | wc -l)
    if [ "$python_count" -gt 0 ]; then
        echo "  🐍 Python: $python_count procesos activos"
    fi
    
    # Node processes
    local node_count=$(pgrep -f "node" | wc -l)
    if [ "$node_count" -gt 0 ]; then
        echo "  🟢 Node.js: $node_count procesos activos"
    fi
    
    # Ports listening
    local listening_ports=$(netstat -tlnp 2>/dev/null | grep LISTEN | awk '{print $4}' | grep -E ":(3000|8000|5000)" | wc -l)
    if [ "$listening_ports" -gt 0 ]; then
        echo "  🌐 Puertos activos: $listening_ports"
    fi
}

generate_report() {
    print_header "Generando Reporte de Rendimiento"
    
    local report_file="$REPORT_DIR/performance_$(date +%Y%m%d_%H%M%S).html"
    
    # Generate HTML report
    cat > "$report_file" << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Performance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .metric { background: #f5f5f5; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .alert { background: #ffebee; border-left: 4px solid #f44336; }
        .normal { background: #e8f5e8; border-left: 4px solid #4caf50; }
    </style>
</head>
<body>
    <h1>Performance Report - $(date)</h1>
HTML
    
    # Add current stats to report
    echo "<div class='metric normal'>" >> "$report_file"
    echo "<h3>Current System Stats</h3>" >> "$report_file"
    echo "<p>Generated at: $(date)</p>" >> "$report_file"
    echo "</div>" >> "$report_file"
    
    echo "</body></html>" >> "$report_file"
    
    log_success "Reporte generado: $report_file"
}

check_monitoring_deps() {
    local missing_deps=()
    
    if ! command_exists top; then
        missing_deps+=("top")
    fi
    
    if ! command_exists free; then
        missing_deps+=("free")
    fi
    
    if ! command_exists df; then
        missing_deps+=("df")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Dependencias faltantes para monitoreo: ${missing_deps[*]}"
        exit 1
    fi
}

show_usage() {
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start      - Iniciar monitoreo en background"
    echo "  stop       - Detener monitoreo"
    echo "  status     - Mostrar estado actual"
    echo "  dashboard  - Mostrar dashboard en tiempo real"
    echo "  report     - Generar reporte de rendimiento"
    echo ""
    echo "Ejemplos:"
    echo "  $0 start"
    echo "  $0 dashboard"
    echo "  $0 report"
}

main "$@"
EOF

chmod +x scripts/monitoring/monitor.sh
```

## 📈 Script de Estadísticas del Sistema

### scripts/monitoring/system-stats.sh
```bash
cat > scripts/monitoring/system-stats.sh << 'EOF'
#!/bin/bash
# Recopilación detallada de estadísticas del sistema

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/utils/common.sh"

main() {
    case "${1:-all}" in
        cpu)       show_cpu_stats ;;
        memory)    show_memory_stats ;;
        disk)      show_disk_stats ;;
        network)   show_network_stats ;;
        processes) show_process_stats ;;
        all)       show_all_stats ;;
        *)         show_usage ;;
    esac
}

show_cpu_stats() {
    print_header "Estadísticas de CPU"
    
    # CPU Info
    if [ -f "/proc/cpuinfo" ]; then
        local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        local cpu_cores=$(nproc)
        
        log_info "Modelo: $cpu_model"
        log_info "Cores: $cpu_cores"
    fi
    
    # CPU Usage
    if command_exists top; then
        log_info "Uso actual de CPU:"
        top -bn1 | head -3 | tail -1
    fi
    
    # Load Average
    if [ -f "/proc/loadavg" ]; then
        local load=$(cat /proc/loadavg)
        log_info "Load Average: $load"
    fi
}

show_memory_stats() {
    print_header "Estadísticas de Memoria"
    
    if command_exists free; then
        log_info "Memoria del sistema:"
        free -h
        
        echo ""
        log_info "Resumen:"
        local memory_info=$(free | grep Mem)
        local total=$(echo $memory_info | awk '{print $2}')
        local used=$(echo $memory_info | awk '{print $3}')
        local available=$(echo $memory_info | awk '{print $7}')
        local percent=$((used * 100 / total))
        
        echo "  Total: $(numfmt --to=iec $((total * 1024)))"
        echo "  Usado: $(numfmt --to=iec $((used * 1024))) (${percent}%)"
        echo "  Disponible: $(numfmt --to=iec $((available * 1024)))"
    fi
}

show_disk_stats() {
    print_header "Estadísticas de Disco"
    
    if command_exists df; then
        log_info "Uso de disco:"
        df -h
        
        echo ""
        log_info "Directorios más grandes en /workspace:"
        if [ -d "/workspace" ]; then
            du -sh /workspace/* 2>/dev/null | sort -hr | head -5
        else
            du -sh ./* 2>/dev/null | sort -hr | head -5
        fi
    fi
}

show_network_stats() {
    print_header "Estadísticas de Red"
    
    # Network interfaces
    if command_exists ip; then
        log_info "Interfaces de red:"
        ip addr show | grep -E "^[0-9]+:|inet "
    fi
    
    # Listening ports
    if command_exists netstat; then
        log_info "Puertos en escucha:"
        netstat -tlnp 2>/dev/null | grep LISTEN | head -10
    elif command_exists ss; then
        log_info "Puertos en escucha:"
        ss -tlnp | head -10
    fi
}

show_process_stats() {
    print_header "Estadísticas de Procesos"
    
    # Top processes by CPU
    log_info "Top 5 procesos por CPU:"
    ps aux --sort=-%cpu | head -6
    
    echo ""
    
    # Top processes by Memory
    log_info "Top 5 procesos por Memoria:"
    ps aux --sort=-%mem | head -6
    
    echo ""
    
    # Application processes
    log_info "Procesos de la aplicación:"
    pgrep -fl "python\|node\|npm" || echo "  No se encontraron procesos de aplicación"
}

show_all_stats() {
    show_cpu_stats
    echo ""
    show_memory_stats
    echo ""
    show_disk_stats
    echo ""
    show_network_stats
    echo ""
    show_process_stats
}

show_usage() {
    echo "Uso: $0 [tipo]"
    echo ""
    echo "Tipos disponibles:"
    echo "  cpu        - Estadísticas de CPU"
    echo "  memory     - Estadísticas de memoria"
    echo "  disk       - Estadísticas de disco"
    echo "  network    - Estadísticas de red"
    echo "  processes  - Estadísticas de procesos"
    echo "  all        - Todas las estadísticas (default)"
}

main "$@"
EOF

chmod +x scripts/monitoring/system-stats.sh
```

## 🚨 Script de Alertas

### scripts/monitoring/resource-alerts.sh
```bash
cat > scripts/monitoring/resource-alerts.sh << 'EOF'
#!/bin/bash
# Sistema de alertas para recursos del sistema

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "$SCRIPT_DIR")/utils/common.sh"

# Configuración de umbrales
CPU_WARNING=70
CPU_CRITICAL=85
MEMORY_WARNING=75
MEMORY_CRITICAL=90
DISK_WARNING=80
DISK_CRITICAL=95

ALERT_FILE="logs/alerts.log"

main() {
    case "${1:-check}" in
        check)     check_all_resources ;;
        config)    configure_thresholds ;;
        history)   show_alert_history ;;
        test)      test_alerts ;;
        *)         show_usage ;;
    esac
}

check_all_resources() {
    ensure_dir "logs"
    
    log_step "Verificando recursos del sistema..."
    
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_load_average
}

check_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' | cut -d. -f1)
    
    if [ "$cpu_usage" -ge "$CPU_CRITICAL" ]; then
        create_alert "CRITICAL" "CPU" "CPU usage is critically high: ${cpu_usage}%"
    elif [ "$cpu_usage" -ge "$CPU_WARNING" ]; then
        create_alert "WARNING" "CPU" "CPU usage is high: ${cpu_usage}%"
    fi
}

check_memory_usage() {
    local memory_info=$(free | grep Mem)
    local memory_total=$(echo $memory_info | awk '{print $2}')
    local memory_used=$(echo $memory_info | awk '{print $3}')
    local memory_percent=$((memory_used * 100 / memory_total))
    
    if [ "$memory_percent" -ge "$MEMORY_CRITICAL" ]; then
        create_alert "CRITICAL" "MEMORY" "Memory usage is critically high: ${memory_percent}%"
    elif [ "$memory_percent" -ge "$MEMORY_WARNING" ]; then
        create_alert "WARNING" "MEMORY" "Memory usage is high: ${memory_percent}%"
    fi
}

check_disk_usage() {
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$disk_usage" -ge "$DISK_CRITICAL" ]; then
        create_alert "CRITICAL" "DISK" "Disk usage is critically high: ${disk_usage}%"
    elif [ "$disk_usage" -ge "$DISK_WARNING" ]; then
        create_alert "WARNING" "DISK" "Disk usage is high: ${disk_usage}%"
    fi
}

check_load_average() {
    local load_1min=$(uptime | awk -F'load average:' '{print $2}' | awk -F, '{print $1}' | xargs)
    local cpu_cores=$(nproc)
    local load_per_core=$(echo "scale=2; $load_1min / $cpu_cores" | bc 2>/dev/null || echo "0")
    
    # Alert if load is more than 2x the number of cores
    local threshold=$(echo "$cpu_cores * 2" | bc)
    if (( $(echo "$load_1min > $threshold" | bc -l) )); then
        create_alert "WARNING" "LOAD" "High system load: $load_1min (cores: $cpu_cores)"
    fi
}

create_alert() {
    local level="$1"
    local type="$2"
    local message="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log alert
    echo "[$timestamp] $level $type: $message" >> "$ALERT_FILE"
    
    # Show in console
    case "$level" in
        "CRITICAL")
            log_error "🚨 CRITICAL $type: $message"
            ;;
        "WARNING")
            log_warning "⚠️ WARNING $type: $message"
            ;;
        "INFO")
            log_info "ℹ️ INFO $type: $message"
            ;;
    esac
    
    # En Codespaces, también notificar visualmente
    if [ -n "$CODESPACES" ]; then
        send_codespaces_notification "$level" "$type" "$message"
    fi
}

send_codespaces_notification() {
    local level="$1"
    local type="$2"
    local message="$3"
    
    # Intentar mostrar notificación en terminal principal
    {
        echo ""
        echo "🚨 [$level] $type Alert: $message"
        echo "   Timestamp: $(date)"
        echo ""
    } > /proc/1/fd/1 2>/dev/null || true
}

configure_thresholds() {
    print_header "Configuración de Umbrales de Alerta"
    
    echo "Umbrales actuales:"
    echo "  CPU Warning: $CPU_WARNING%"
    echo "  CPU Critical: $CPU_CRITICAL%"
    echo "  Memory Warning: $MEMORY_WARNING%"
    echo "  Memory Critical: $MEMORY_CRITICAL%"
    echo "  Disk Warning: $DISK_WARNING%"
    echo "  Disk Critical: $DISK_CRITICAL%"
    
    if confirm_action "¿Deseas modificar los umbrales?"; then
        CPU_WARNING=$(ask_user "CPU Warning %" "$CPU_WARNING")
        CPU_CRITICAL=$(ask_user "CPU Critical %" "$CPU_CRITICAL")
        MEMORY_WARNING=$(ask_user "Memory Warning %" "$MEMORY_WARNING")
        MEMORY_CRITICAL=$(ask_user "Memory Critical %" "$MEMORY_CRITICAL")
        DISK_WARNING=$(ask_user "Disk Warning %" "$DISK_WARNING")
        DISK_CRITICAL=$(ask_user "Disk Critical %" "$DISK_CRITICAL")
        
        # Save to config file
        cat > "config/alert-thresholds.conf" << EOF
CPU_WARNING=$CPU_WARNING
CPU_CRITICAL=$CPU_CRITICAL
MEMORY_WARNING=$MEMORY_WARNING
MEMORY_CRITICAL=$MEMORY_CRITICAL
DISK_WARNING=$DISK_WARNING
DISK_CRITICAL=$DISK_CRITICAL
EOF
        
        log_success "Configuración guardada en config/alert-thresholds.conf"
    fi
}

show_alert_history() {
    print_header "Historial de Alertas"
    
    if [ -f "$ALERT_FILE" ]; then
        log_info "Últimas 10 alertas:"
        tail -10 "$ALERT_FILE"
        
        echo ""
        log_info "Resumen por tipo:"
        if command_exists awk; then
            awk '{print $3}' "$ALERT_FILE" | sort | uniq -c | sort -nr
        fi
        
        echo ""
        log_info "Alertas de hoy:"
        local today=$(date '+%Y-%m-%d')
        grep "$today" "$ALERT_FILE" | wc -l
    else
        log_info "No hay historial de alertas"
    fi
}

test_alerts() {
    print_header "Probando Sistema de Alertas"
    
    log_step "Enviando alerta de prueba..."
    create_alert "INFO" "TEST" "Sistema de alertas funcionando correctamente"
    
    log_step "Probando umbrales..."
    create_alert "WARNING" "TEST" "Prueba de alerta WARNING"
    create_alert "CRITICAL" "TEST" "Prueba de alerta CRITICAL"
    
    log_success "Pruebas de alertas completadas"
    log_info "Revisa $ALERT_FILE para ver las alertas generadas"
}

show_usage() {
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  check      - Verificar recursos y generar alertas (default)"
    echo "  config     - Configurar umbrales de alerta"
    echo "  history    - Mostrar historial de alertas"
    echo "  test       - Probar sistema de alertas"
}

# Load custom thresholds if exist
if [ -f "config/alert-thresholds.conf" ]; then
    source "config/alert-thresholds.conf"
fi

main "$@"
EOF

chmod +x scripts/monitoring/resource-alerts.sh
```

## 📋 Integración con Scripts Principales

### Actualizar scripts/dev.sh para incluir monitoreo
```bash
cat >> scripts/dev.sh << 'EOF'

# Función para iniciar monitoreo automáticamente
start_monitoring_if_enabled() {
    if [ -f "config/monitoring.conf" ]; then
        source "config/monitoring.conf"
        if [ "$AUTO_MONITOR" == "true" ]; then
            log_info "Iniciando monitoreo automático..."
            ./scripts/monitoring/monitor.sh start
        fi
    fi
}

# Agregar al final de main()
# start_monitoring_if_enabled
EOF
```

### Crear configuración de monitoreo
```bash
mkdir -p config
cat > config/monitoring.conf << 'EOF'
# Configuración del sistema de monitoreo

# Auto-start monitoring when dev server starts
AUTO_MONITOR=true

# Monitoring intervals (seconds)
MONITOR_INTERVAL=30
ALERT_CHECK_INTERVAL=60

# Enable/disable specific monitoring
MONITOR_CPU=true
MONITOR_MEMORY=true
MONITOR_DISK=true
MONITOR_NETWORK=true
MONITOR_PROCESSES=true

# Alert thresholds (percentages)
CPU_WARNING_THRESHOLD=70
CPU_CRITICAL_THRESHOLD=85
MEMORY_WARNING_THRESHOLD=75
MEMORY_CRITICAL_THRESHOLD=90
DISK_WARNING_THRESHOLD=80
DISK_CRITICAL_THRESHOLD=95

# Logging
LOG_RETENTION_DAYS=7
ENABLE_DETAILED_LOGS=true

# Codespaces specific settings
CODESPACES_OPTIMIZE=true
CODESPACES_ALERT_TERMINAL=true
EOF
```

## ❓ FAQ - Sistema de Monitoreo

### P: ¿El monitoreo afecta el rendimiento?
**R**: Mínimamente. Los scripts están optimizados para usar pocos recursos y se ejecutan en intervalos configurables.

### P: ¿Funciona en Windows local?
**R**: Con WSL o Git Bash sí. Para Windows nativo necesitarías adaptar los comandos de sistema.

### P: ¿Puedo personalizar los umbrales?
**R**: Sí, usa `./scripts/monitoring/resource-alerts.sh config` o edita `config/alert-thresholds.conf`.

### P: ¿Las alertas se envían por email?
**R**: Actualmente no, pero puedes extender el script para integrar con servicios de notificación.

## ✅ Checklist de Monitoreo

- [ ] ✅ Scripts de monitoreo creados y ejecutables
- [ ] ✅ Sistema de alertas configurado
- [ ] ✅ Umbrales personalizados definidos
- [ ] ✅ Integración con scripts de desarrollo
- [ ] ✅ Configuración de monitoreo creada
- [ ] ✅ Dashboard de tiempo real funcional
- [ ] ✅ Sistema de reportes implementado
- [ ] ✅ Logs de monitoreo organizados
- [ ] ✅ Pruebas de alertas ejecutadas
- [ ] ✅ Documentación de configuración completa

## ➡️ Siguiente Paso

Con el sistema de monitoreo configurado, continúa con:
👉 **[07-documentacion.md](07-documentacion.md)** - Templates y estructura de documentación
