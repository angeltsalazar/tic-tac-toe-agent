#!/bin/bash

# 🏠 Script de Inicio para Desarrollo Local
# Detecta automáticamente el entorno y configura adecuadamente

echo "🏠 TIC-TAC-TOE - DESARROLLO LOCAL"
echo "================================="
echo ""

# Verificar si estamos en Codespaces
if [ ! -z "$CODESPACE_NAME" ]; then
    echo "⚠️  Detectado GitHub Codespaces!"
    echo "   Usa: ./start-game.sh para Codespaces"
    echo "   Este script es para desarrollo LOCAL"
    exit 1
fi

# Verificar Python
if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
    echo "❌ Python no encontrado"
    echo "   Instala Python 3.8 o superior"
    exit 1
fi

# Determinar comando Python
PYTHON_CMD="python"
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
fi

echo "🐍 Usando: $PYTHON_CMD"

# Verificar entorno virtual
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo ""
    echo "📦 CONFIGURANDO ENTORNO VIRTUAL"
    echo "==============================="
    
    if [ ! -d "venv" ]; then
        echo "🔧 Creando entorno virtual..."
        $PYTHON_CMD -m venv venv
    fi
    
    echo "⚡ Activando entorno virtual..."
    source venv/bin/activate
    
    echo "📥 Instalando dependencias..."
    pip install -r requirements.txt
else
    echo "✅ Entorno virtual activo: $VIRTUAL_ENV"
fi

# Verificar dependencias
echo ""
echo "🔍 VERIFICANDO DEPENDENCIAS"
echo "==========================="

MISSING_DEPS=()

# Verificar Flask
if ! python -c "import flask" 2>/dev/null; then
    MISSING_DEPS+=("flask")
fi

# Verificar requests
if ! python -c "import requests" 2>/dev/null; then
    MISSING_DEPS+=("requests")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "📥 Instalando dependencias faltantes: ${MISSING_DEPS[*]}"
    pip install "${MISSING_DEPS[@]}"
fi

# Verificar puerto disponible
echo ""
echo "🌐 VERIFICANDO PUERTO"
echo "===================="

if lsof -i :8000 &> /dev/null; then
    echo "⚠️  Puerto 8000 ocupado"
    echo "   Procesos en puerto 8000:"
    lsof -i :8000
    echo ""
    read -p "   ¿Matar procesos en puerto 8000? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔫 Matando procesos en puerto 8000..."
        lsof -ti :8000 | xargs kill -9 2>/dev/null
        sleep 2
    else
        echo "❌ No se puede iniciar con puerto ocupado"
        exit 1
    fi
fi

# Mostrar información del sistema
echo ""
echo "📊 INFORMACIÓN DEL SISTEMA"
echo "=========================="
echo "🖥️  OS: $(uname -s)"
echo "🐍 Python: $($PYTHON_CMD --version)"
echo "📁 Directorio: $(pwd)"
echo "🌐 URL local: http://localhost:8000"

# Verificar si hay herramientas de monitoreo
if [ -f "monitor-visual.sh" ]; then
    echo ""
    echo "🔧 HERRAMIENTAS DISPONIBLES"
    echo "=========================="
    echo "📊 Monitor visual: ./monitor-visual.sh"
    echo "⌨️  Monitor latencia: ./monitor-latency.sh"
    echo "📈 Reportes: ./benchmark-report.sh"
fi

# Iniciar servidor
echo ""
echo "🚀 INICIANDO SERVIDOR"
echo "===================="
echo "✅ Servidor iniciando en http://localhost:8000"
echo "🌐 Abre tu navegador y ve a: http://localhost:8000"
echo "⏹️  Presiona Ctrl+C para detener"
echo ""

cd server
python server.py
