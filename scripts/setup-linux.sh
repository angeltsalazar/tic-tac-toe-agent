#!/bin/bash
# Script de setup para desarrollo en Linux (Spaces)

echo "🐧 Configurando ambiente Linux para desarrollo..."

# Verificar si Ollama está instalado
if ! command -v ollama &> /dev/null; then
    echo "📥 Instalando Ollama..."
    curl -fsSL https://ollama.ai/install.sh | sh
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

echo "✅ Ambiente Linux configurado para desarrollo"
echo "🎯 Para ejecutar: python server/server.py"
