#!/bin/bash

# 🎮 Script de Inicio Automático para Tic-Tac-Toe en GitHub Codespaces
# Detecta automáticamente la URL correcta y ejecuta el servidor

echo "🎮 TIC-TAC-TOE CON IA - GITHUB CODESPACES"
echo "========================================="
echo ""

# Detectar si estamos en GitHub Codespaces
if [ -n "$CODESPACE_NAME" ]; then
    echo "✅ GitHub Codespaces detectado"
    echo "📛 Nombre del Codespace: $CODESPACE_NAME"
    echo ""
    
    # Construir la URL automáticamente
    GAME_URL="https://${CODESPACE_NAME}-8000.app.github.dev/"
    echo "🌐 URL de tu juego:"
    echo "   $GAME_URL"
    echo ""
    echo "📋 Instrucciones:"
    echo "   1. Copia la URL de arriba"
    echo "   2. Pégala en una nueva pestaña del navegador"
    echo "   3. ¡Disfruta del juego!"
    echo ""
else
    echo "⚠️  No se detectó GitHub Codespaces"
    echo "🏠 Parece que estás en desarrollo local"
    echo "🌐 URL de tu juego: http://localhost:8000/"
    echo ""
fi

echo "📂 Cambiando al directorio del servidor..."
cd /workspaces/tic-tac-toe-agent/server

echo "🚀 Iniciando servidor en puerto 8000..."
echo "   (Presiona Ctrl+C para detener)"
echo ""

# Ejecutar el servidor
python server.py
