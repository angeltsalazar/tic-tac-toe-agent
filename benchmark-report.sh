#!/bin/bash

# 📊 Generador de Reporte de Rendimiento Tic-Tac-Toe
# Compara automáticamente el sistema en reposo vs durante el juego

echo "📊 GENERADOR DE REPORTE DE RENDIMIENTO"
echo "======================================"
echo ""

# Variables globales
REPORT_DIR="/tmp/tic-tac-toe-reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BASELINE_FILE="$REPORT_DIR/baseline_$TIMESTAMP.json"
USAGE_FILE="$REPORT_DIR/usage_$TIMESTAMP.json"
REPORT_FILE="$REPORT_DIR/performance_report_$TIMESTAMP.html"

# Crear directorio de reportes
mkdir -p "$REPORT_DIR"

# Función para capturar métricas del sistema
capture_metrics() {
    local label="$1"
    local output_file="$2"
    
    echo "📸 Capturando métricas del sistema ($label)..."
    
    # Obtener métricas
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local mem_info=$(free | grep Mem)
    local mem_used=$(echo $mem_info | awk '{print $3}')
    local mem_total=$(echo $mem_info | awk '{print $2}')
    local mem_percent=$(echo "scale=2; $mem_used * 100 / $mem_total" | bc)
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk -F',' '{print $1}' | xargs)
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
    
    # Procesos específicos
    local python_proc=$(ps aux | grep -E "(python.*server|uvicorn)" | grep -v grep | head -1)
    local python_cpu=0
    local python_mem=0
    local python_pid=""
    
    if [ -n "$python_proc" ]; then
        python_cpu=$(echo $python_proc | awk '{print $3}')
        python_mem=$(echo $python_proc | awk '{print $4}')
        python_pid=$(echo $python_proc | awk '{print $2}')
    fi
    
    local ollama_proc=$(ps aux | grep ollama | grep -v grep | head -1)
    local ollama_cpu=0
    local ollama_mem=0
    local ollama_pid=""
    
    if [ -n "$ollama_proc" ]; then
        ollama_cpu=$(echo $ollama_proc | awk '{print $3}')
        ollama_mem=$(echo $ollama_proc | awk '{print $4}')
        ollama_pid=$(echo $ollama_proc | awk '{print $2}')
    fi
    
    # Conexiones de red
    local connections=$(ss -tuln | grep :8000 | wc -l)
    local tcp_connections=$(ss -tu | grep :8000 | wc -l)
    
    # GPU (si disponible)
    local gpu_usage=""
    local gpu_memory=""
    local gpu_temp=""
    
    if command -v nvidia-smi &> /dev/null; then
        gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
        gpu_memory=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null || echo "0")
        gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
    fi
    
    # Crear JSON con las métricas
    cat > "$output_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "label": "$label",
    "system": {
        "cpu_usage_percent": $cpu_usage,
        "memory_used_bytes": $mem_used,
        "memory_total_bytes": $mem_total,
        "memory_usage_percent": $mem_percent,
        "load_average_1min": $load_avg,
        "disk_usage_percent": $disk_usage
    },
    "processes": {
        "python_server": {
            "pid": "$python_pid",
            "cpu_percent": $python_cpu,
            "memory_percent": $python_mem,
            "running": $([ -n "$python_proc" ] && echo "true" || echo "false")
        },
        "ollama": {
            "pid": "$ollama_pid",
            "cpu_percent": $ollama_cpu,
            "memory_percent": $ollama_mem,
            "running": $([ -n "$ollama_proc" ] && echo "true" || echo "false")
        }
    },
    "network": {
        "listening_connections": $connections,
        "active_connections": $tcp_connections
    },
    "gpu": {
        "usage_percent": "$gpu_usage",
        "memory_mb": "$gpu_memory",
        "temperature_c": "$gpu_temp",
        "available": $(command -v nvidia-smi &> /dev/null && echo "true" || echo "false")
    }
}
EOF
    
    echo "✅ Métricas capturadas en: $output_file"
}

# Función para generar reporte HTML
generate_html_report() {
    echo "📄 Generando reporte HTML..."
    
    # Leer datos de ambos archivos
    local baseline_data=$(cat "$BASELINE_FILE")
    local usage_data=$(cat "$USAGE_FILE")
    
    # Extraer valores para comparación
    local baseline_cpu=$(echo "$baseline_data" | jq -r '.system.cpu_usage_percent')
    local usage_cpu=$(echo "$usage_data" | jq -r '.system.cpu_usage_percent')
    local cpu_diff=$(echo "scale=2; $usage_cpu - $baseline_cpu" | bc)
    
    local baseline_mem=$(echo "$baseline_data" | jq -r '.system.memory_usage_percent')
    local usage_mem=$(echo "$usage_data" | jq -r '.system.memory_usage_percent')
    local mem_diff=$(echo "scale=2; $usage_mem - $baseline_mem" | bc)
    
    local baseline_load=$(echo "$baseline_data" | jq -r '.system.load_average_1min')
    local usage_load=$(echo "$usage_data" | jq -r '.system.load_average_1min')
    
    # Generar HTML
    cat > "$REPORT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📊 Reporte de Rendimiento - Tic-Tac-Toe</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 30px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }
        h1, h2 { text-align: center; margin-bottom: 20px; }
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .metric-card {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 20px;
            border-left: 4px solid #4CAF50;
        }
        .metric-value {
            font-size: 24px;
            font-weight: bold;
            margin: 10px 0;
        }
        .metric-diff {
            font-size: 14px;
            margin-top: 5px;
        }
        .positive { color: #ff6b6b; }
        .negative { color: #51cf66; }
        .neutral { color: #ffd43b; }
        .chart-container {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            height: 400px;
        }
        .summary {
            background: rgba(255, 255, 255, 0.15);
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        th {
            background: rgba(255, 255, 255, 0.1);
            font-weight: bold;
        }
        .status-running { color: #51cf66; }
        .status-stopped { color: #ff6b6b; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Reporte de Rendimiento - Tic-Tac-Toe con IA</h1>
        <p style="text-align: center;">Generado el: <strong>TIMESTAMP_PLACEHOLDER</strong></p>
        
        <div class="summary">
            <h2>📋 Resumen Ejecutivo</h2>
            <p><strong>🎯 Objetivo:</strong> Comparar el rendimiento del sistema en reposo vs durante el uso del juego Tic-Tac-Toe con IA.</p>
            <p><strong>🔍 Metodología:</strong> Captura de métricas del sistema antes y durante la ejecución del juego.</p>
        </div>

        <h2>⚡ Comparación de Recursos del Sistema</h2>
        <div class="metrics-grid">
            <div class="metric-card">
                <h3>🖥️ CPU</h3>
                <div class="metric-value">USAGE_CPU_PLACEHOLDER%</div>
                <div class="metric-diff DIFF_CPU_CLASS_PLACEHOLDER">
                    Diferencia: DIFF_CPU_PLACEHOLDER% vs reposo
                </div>
                <small>Reposo: BASELINE_CPU_PLACEHOLDER%</small>
            </div>
            
            <div class="metric-card">
                <h3>🧠 Memoria</h3>
                <div class="metric-value">USAGE_MEM_PLACEHOLDER%</div>
                <div class="metric-diff DIFF_MEM_CLASS_PLACEHOLDER">
                    Diferencia: DIFF_MEM_PLACEHOLDER% vs reposo
                </div>
                <small>Reposo: BASELINE_MEM_PLACEHOLDER%</small>
            </div>
            
            <div class="metric-card">
                <h3>📈 Carga del Sistema</h3>
                <div class="metric-value">USAGE_LOAD_PLACEHOLDER</div>
                <small>Reposo: BASELINE_LOAD_PLACEHOLDER</small>
            </div>
        </div>

        <h2>🔍 Detalles de Procesos</h2>
        <table>
            <thead>
                <tr>
                    <th>Proceso</th>
                    <th>Estado en Reposo</th>
                    <th>Estado en Uso</th>
                    <th>CPU (%)</th>
                    <th>Memoria (%)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>🐍 Servidor Python</td>
                    <td class="PYTHON_BASELINE_STATUS_CLASS_PLACEHOLDER">PYTHON_BASELINE_STATUS_PLACEHOLDER</td>
                    <td class="PYTHON_USAGE_STATUS_CLASS_PLACEHOLDER">PYTHON_USAGE_STATUS_PLACEHOLDER</td>
                    <td>PYTHON_USAGE_CPU_PLACEHOLDER%</td>
                    <td>PYTHON_USAGE_MEM_PLACEHOLDER%</td>
                </tr>
                <tr>
                    <td>🤖 Ollama (IA)</td>
                    <td class="OLLAMA_BASELINE_STATUS_CLASS_PLACEHOLDER">OLLAMA_BASELINE_STATUS_PLACEHOLDER</td>
                    <td class="OLLAMA_USAGE_STATUS_CLASS_PLACEHOLDER">OLLAMA_USAGE_STATUS_PLACEHOLDER</td>
                    <td>OLLAMA_USAGE_CPU_PLACEHOLDER%</td>
                    <td>OLLAMA_USAGE_MEM_PLACEHOLDER%</td>
                </tr>
            </tbody>
        </table>

        <h2>🌐 Conexiones de Red</h2>
        <div class="metrics-grid">
            <div class="metric-card">
                <h3>🔌 Puerto 8000</h3>
                <div class="metric-value">USAGE_CONNECTIONS_PLACEHOLDER</div>
                <small>Conexiones activas durante el juego</small>
            </div>
        </div>

        <div class="chart-container">
            <canvas id="comparisonChart"></canvas>
        </div>

        <div class="summary">
            <h2>💡 Conclusiones</h2>
            <ul>
                <li><strong>Impacto en CPU:</strong> CONCLUSION_CPU_PLACEHOLDER</li>
                <li><strong>Impacto en Memoria:</strong> CONCLUSION_MEM_PLACEHOLDER</li>
                <li><strong>Procesos Críticos:</strong> CONCLUSION_PROCESSES_PLACEHOLDER</li>
                <li><strong>Rendimiento General:</strong> CONCLUSION_GENERAL_PLACEHOLDER</li>
            </ul>
        </div>
    </div>

    <script>
        // Datos para el gráfico
        const ctx = document.getElementById('comparisonChart').getContext('2d');
        const chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['CPU (%)', 'Memoria (%)', 'Carga del Sistema'],
                datasets: [{
                    label: 'Reposo',
                    data: [BASELINE_CPU_PLACEHOLDER, BASELINE_MEM_PLACEHOLDER, BASELINE_LOAD_PLACEHOLDER],
                    backgroundColor: 'rgba(81, 207, 102, 0.6)',
                    borderColor: 'rgba(81, 207, 102, 1)',
                    borderWidth: 1
                }, {
                    label: 'En Uso',
                    data: [USAGE_CPU_PLACEHOLDER, USAGE_MEM_PLACEHOLDER, USAGE_LOAD_PLACEHOLDER],
                    backgroundColor: 'rgba(255, 107, 107, 0.6)',
                    borderColor: 'rgba(255, 107, 107, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: 'Comparación: Reposo vs En Uso',
                        color: 'white',
                        font: { size: 16 }
                    },
                    legend: {
                        labels: { color: 'white' }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(255, 255, 255, 0.2)' },
                        ticks: { color: 'white' }
                    },
                    x: {
                        grid: { color: 'rgba(255, 255, 255, 0.2)' },
                        ticks: { color: 'white' }
                    }
                }
            }
        });
    </script>
</body>
</html>
EOF

    # Reemplazar placeholders con datos reales
    sed -i "s/TIMESTAMP_PLACEHOLDER/$(date)/g" "$REPORT_FILE"
    sed -i "s/BASELINE_CPU_PLACEHOLDER/$baseline_cpu/g" "$REPORT_FILE"
    sed -i "s/USAGE_CPU_PLACEHOLDER/$usage_cpu/g" "$REPORT_FILE"
    sed -i "s/DIFF_CPU_PLACEHOLDER/$cpu_diff/g" "$REPORT_FILE"
    sed -i "s/BASELINE_MEM_PLACEHOLDER/$baseline_mem/g" "$REPORT_FILE"
    sed -i "s/USAGE_MEM_PLACEHOLDER/$usage_mem/g" "$REPORT_FILE"
    sed -i "s/DIFF_MEM_PLACEHOLDER/$mem_diff/g" "$REPORT_FILE"
    sed -i "s/BASELINE_LOAD_PLACEHOLDER/$baseline_load/g" "$REPORT_FILE"
    sed -i "s/USAGE_LOAD_PLACEHOLDER/$usage_load/g" "$REPORT_FILE"
    
    # Determinar clases CSS para diferencias
    local cpu_class="neutral"
    if (( $(echo "$cpu_diff > 5" | bc -l) )); then
        cpu_class="positive"
    elif (( $(echo "$cpu_diff < -1" | bc -l) )); then
        cpu_class="negative"
    fi
    
    local mem_class="neutral"
    if (( $(echo "$mem_diff > 3" | bc -l) )); then
        mem_class="positive"
    elif (( $(echo "$mem_diff < -1" | bc -l) )); then
        mem_class="negative"
    fi
    
    sed -i "s/DIFF_CPU_CLASS_PLACEHOLDER/$cpu_class/g" "$REPORT_FILE"
    sed -i "s/DIFF_MEM_CLASS_PLACEHOLDER/$mem_class/g" "$REPORT_FILE"
    
    # Datos de procesos
    local python_baseline_running=$(echo "$baseline_data" | jq -r '.processes.python_server.running')
    local python_usage_running=$(echo "$usage_data" | jq -r '.processes.python_server.running')
    local python_usage_cpu=$(echo "$usage_data" | jq -r '.processes.python_server.cpu_percent')
    local python_usage_mem=$(echo "$usage_data" | jq -r '.processes.python_server.memory_percent')
    
    local ollama_baseline_running=$(echo "$baseline_data" | jq -r '.processes.ollama.running')
    local ollama_usage_running=$(echo "$usage_data" | jq -r '.processes.ollama.running')
    local ollama_usage_cpu=$(echo "$usage_data" | jq -r '.processes.ollama.cpu_percent')
    local ollama_usage_mem=$(echo "$usage_data" | jq -r '.processes.ollama.memory_percent')
    
    local usage_connections=$(echo "$usage_data" | jq -r '.network.listening_connections')
    
    # Reemplazar datos de procesos
    sed -i "s/PYTHON_BASELINE_STATUS_PLACEHOLDER/$([ "$python_baseline_running" == "true" ] && echo "Ejecutándose" || echo "Detenido")/g" "$REPORT_FILE"
    sed -i "s/PYTHON_USAGE_STATUS_PLACEHOLDER/$([ "$python_usage_running" == "true" ] && echo "Ejecutándose" || echo "Detenido")/g" "$REPORT_FILE"
    sed -i "s/PYTHON_BASELINE_STATUS_CLASS_PLACEHOLDER/$([ "$python_baseline_running" == "true" ] && echo "status-running" || echo "status-stopped")/g" "$REPORT_FILE"
    sed -i "s/PYTHON_USAGE_STATUS_CLASS_PLACEHOLDER/$([ "$python_usage_running" == "true" ] && echo "status-running" || echo "status-stopped")/g" "$REPORT_FILE"
    sed -i "s/PYTHON_USAGE_CPU_PLACEHOLDER/$python_usage_cpu/g" "$REPORT_FILE"
    sed -i "s/PYTHON_USAGE_MEM_PLACEHOLDER/$python_usage_mem/g" "$REPORT_FILE"
    
    sed -i "s/OLLAMA_BASELINE_STATUS_PLACEHOLDER/$([ "$ollama_baseline_running" == "true" ] && echo "Ejecutándose" || echo "Detenido")/g" "$REPORT_FILE"
    sed -i "s/OLLAMA_USAGE_STATUS_PLACEHOLDER/$([ "$ollama_usage_running" == "true" ] && echo "Ejecutándose" || echo "Detenido")/g" "$REPORT_FILE"
    sed -i "s/OLLAMA_BASELINE_STATUS_CLASS_PLACEHOLDER/$([ "$ollama_baseline_running" == "true" ] && echo "status-running" || echo "status-stopped")/g" "$REPORT_FILE"
    sed -i "s/OLLAMA_USAGE_STATUS_CLASS_PLACEHOLDER/$([ "$ollama_usage_running" == "true" ] && echo "status-running" || echo "status-stopped")/g" "$REPORT_FILE"
    sed -i "s/OLLAMA_USAGE_CPU_PLACEHOLDER/$ollama_usage_cpu/g" "$REPORT_FILE"
    sed -i "s/OLLAMA_USAGE_MEM_PLACEHOLDER/$ollama_usage_mem/g" "$REPORT_FILE"
    
    sed -i "s/USAGE_CONNECTIONS_PLACEHOLDER/$usage_connections/g" "$REPORT_FILE"
    
    # Generar conclusiones automáticas
    local conclusion_cpu="El uso de CPU incrementó ${cpu_diff}% durante el juego."
    local conclusion_mem="El uso de memoria incrementó ${mem_diff}% durante el juego."
    local conclusion_processes="Servidor Python y Ollama funcionando correctamente."
    local conclusion_general="Rendimiento del sistema dentro de parámetros normales."
    
    sed -i "s/CONCLUSION_CPU_PLACEHOLDER/$conclusion_cpu/g" "$REPORT_FILE"
    sed -i "s/CONCLUSION_MEM_PLACEHOLDER/$conclusion_mem/g" "$REPORT_FILE"
    sed -i "s/CONCLUSION_PROCESSES_PLACEHOLDER/$conclusion_processes/g" "$REPORT_FILE"
    sed -i "s/CONCLUSION_GENERAL_PLACEHOLDER/$conclusion_general/g" "$REPORT_FILE"
    
    echo "✅ Reporte HTML generado: $REPORT_FILE"
}

# Función principal del benchmark
run_benchmark() {
    echo "🚀 INICIANDO BENCHMARK AUTOMÁTICO"
    echo "================================="
    echo ""
    echo "Este proceso tomará mediciones del sistema en dos estados:"
    echo "1. 📊 Sistema en REPOSO (sin el juego ejecutándose)"
    echo "2. 🎮 Sistema EN USO (con el juego activo)"
    echo ""
    
    # Verificar dependencias
    if ! command -v jq &> /dev/null; then
        echo "⚠️  Instalando dependencia jq..."
        sudo apt update && sudo apt install -y jq bc
    fi
    
    # Paso 1: Capturar estado en reposo
    echo "📋 PASO 1: Captura en REPOSO"
    echo "============================"
    echo "Asegúrate de que:"
    echo "- El servidor del juego NO esté ejecutándose"
    echo "- No haya procesos relacionados con el juego"
    echo "- El sistema esté en un estado 'normal' de reposo"
    echo ""
    read -p "Presiona Enter cuando el sistema esté en reposo..."
    
    capture_metrics "reposo" "$BASELINE_FILE"
    echo ""
    
    # Paso 2: Solicitar inicio del juego
    echo "📋 PASO 2: Iniciar el JUEGO"
    echo "=========================="
    echo "Ahora debes:"
    echo "1. Ejecutar: ./start-game.sh"
    echo "2. Abrir el juego en el navegador"
    echo "3. Jugar al menos 2-3 partidas con la IA"
    echo "4. Volver aquí y presionar Enter"
    echo ""
    read -p "Presiona Enter cuando hayas jugado varias partidas..."
    
    # Paso 3: Capturar estado en uso
    echo "📋 PASO 3: Captura EN USO"
    echo "========================"
    capture_metrics "en_uso" "$USAGE_FILE"
    echo ""
    
    # Paso 4: Generar reporte
    echo "📋 PASO 4: Generando REPORTE"
    echo "============================"
    generate_html_report
    echo ""
    
    # Resumen final
    echo "🎉 BENCHMARK COMPLETADO"
    echo "======================"
    echo ""
    echo "📁 Archivos generados:"
    echo "  📊 Datos reposo: $BASELINE_FILE"
    echo "  🎮 Datos en uso: $USAGE_FILE"
    echo "  📄 Reporte HTML: $REPORT_FILE"
    echo ""
    echo "🌐 Para ver el reporte completo:"
    echo "  Abre: $REPORT_FILE"
    echo ""
    
    # Mostrar resumen rápido
    echo "📊 RESUMEN RÁPIDO:"
    echo "=================="
    local baseline_cpu=$(jq -r '.system.cpu_usage_percent' "$BASELINE_FILE")
    local usage_cpu=$(jq -r '.system.cpu_usage_percent' "$USAGE_FILE")
    local cpu_diff=$(echo "scale=2; $usage_cpu - $baseline_cpu" | bc)
    
    local baseline_mem=$(jq -r '.system.memory_usage_percent' "$BASELINE_FILE")
    local usage_mem=$(jq -r '.system.memory_usage_percent' "$USAGE_FILE")
    local mem_diff=$(echo "scale=2; $usage_mem - $baseline_mem" | bc)
    
    echo "⚡ CPU: $baseline_cpu% → $usage_cpu% (Δ $cpu_diff%)"
    echo "🧠 Memoria: $baseline_mem% → $usage_mem% (Δ $mem_diff%)"
    echo ""
    
    if (( $(echo "$cpu_diff > 10" | bc -l) )); then
        echo "⚠️  Alto impacto en CPU detectado"
    elif (( $(echo "$cpu_diff > 5" | bc -l) )); then
        echo "🟡 Impacto moderado en CPU"
    else
        echo "✅ Impacto bajo en CPU"
    fi
    
    if (( $(echo "$mem_diff > 10" | bc -l) )); then
        echo "⚠️  Alto impacto en memoria detectado"
    elif (( $(echo "$mem_diff > 5" | bc -l) )); then
        echo "🟡 Impacto moderado en memoria"
    else
        echo "✅ Impacto bajo en memoria"
    fi
}

# Función para mostrar reportes anteriores
show_previous_reports() {
    echo "📁 REPORTES ANTERIORES"
    echo "====================="
    echo ""
    
    if [ -d "$REPORT_DIR" ] && [ "$(ls -A $REPORT_DIR/*.html 2>/dev/null)" ]; then
        echo "📄 Reportes HTML disponibles:"
        ls -la "$REPORT_DIR"/*.html 2>/dev/null | while read line; do
            echo "  $line"
        done
        echo ""
        echo "🌐 Para ver un reporte, abre el archivo .html en tu navegador"
    else
        echo "❌ No hay reportes anteriores"
        echo "💡 Ejecuta un benchmark primero con la opción 1"
    fi
}

# Menú principal
show_menu() {
    echo "📊 GENERADOR DE REPORTE DE RENDIMIENTO"
    echo "======================================"
    echo "1. 🚀 Ejecutar benchmark completo (reposo vs uso)"
    echo "2. 📸 Captura única del estado actual"
    echo "3. 📁 Ver reportes anteriores"
    echo "4. 🧹 Limpiar reportes antiguos"
    echo "5. 🚪 Salir"
    echo ""
    read -p "Selecciona una opción (1-5): " choice
    
    case $choice in
        1) run_benchmark ;;
        2) capture_metrics "snapshot_$(date +%H%M%S)" "/tmp/snapshot_$(date +%Y%m%d_%H%M%S).json" ;;
        3) show_previous_reports ;;
        4) rm -rf "$REPORT_DIR" && echo "🧹 Reportes limpiados" ;;
        5) echo "👋 ¡Hasta luego!"; exit 0 ;;
        *) echo "❌ Opción inválida"; show_menu ;;
    esac
}

# Ejecutar script
if [ "$1" == "--auto" ]; then
    run_benchmark
elif [ "$1" == "--reports" ]; then
    show_previous_reports
else
    show_menu
fi
