#!/bin/bash
set -e

echo "🚀 Iniciando Ollama..."
ollama serve &

echo "⏳ Esperando que Ollama esté listo..."
while ! curl -f http://localhost:11434/api/tags >/dev/null 2>&1; do
    sleep 1
done

echo "📥 Descargando modelo por defecto..."
ollama pull llama2 2>/dev/null || echo "Modelo ya existe"

echo "🎯 Iniciando aplicación..."
exec python server/server.py
