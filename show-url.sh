#!/bin/bash

# 🌐 Comando rápido para mostrar la URL del juego Tic-Tac-Toe

echo ""
echo "🎮 TIC-TAC-TOE CON IA"
echo "===================="
echo ""

if [ -n "$CODESPACE_NAME" ]; then
    echo "✅ GitHub Codespaces detectado"
    echo ""
    echo "🌐 TU URL DEL JUEGO:"
    echo "   https://${CODESPACE_NAME}-8000.app.github.dev/"
    echo ""
    echo "📋 Instrucciones:"
    echo "   1. Copia la URL de arriba"
    echo "   2. Pégala en el navegador"
    echo "   3. ¡Juega!"
    echo ""
    echo "⚙️  ¿Servidor no iniciado? Ejecuta:"
    echo "   cd server && python server.py"
else
    echo "🏠 Desarrollo local detectado"
    echo ""
    echo "🌐 TU URL DEL JUEGO:"
    echo "   http://localhost:8000/"
    echo ""
fi

echo ""
