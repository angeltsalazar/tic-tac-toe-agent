#!/bin/bash
# Script de setup para desarrollo en Mac

echo "🍎 Configurando ambiente Mac para desarrollo..."

# Verificar si Ollama está instalado
if ! command -v ollama &> /dev/null; then
    echo "📥 Instalando Ollama..."
    if command -v brew &> /dev/null; then
        brew install ollama
    else
        curl -fsSL https://ollama.ai/install.sh | sh
    fi
else
    echo "✅ Ollama ya está instalado"
fi

# Verificar si el servicio está corriendo
if ! pgrep -x "ollama" > /dev/null; then
    echo "🚀 Iniciando Ollama..."
    ollama serve &
    sleep 3
fi

# Instalar dependencias Python
echo "📦 Instalando dependencias Python..."
pip install -r requirements.txt

# Descargar modelo por defecto
echo "🤖 Descargando modelo IA..."
ollama pull llama2 2>/dev/null || echo "Modelo ya existe"

echo "✅ Ambiente Mac configurado para desarrollo"
echo "🎯 Para ejecutar: python server/server.py"
