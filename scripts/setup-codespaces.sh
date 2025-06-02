#!/bin/bash

# 🚀 Setup script para GitHub Codespaces
# Este script se ejecuta automáticamente al crear un Codespace

echo "🔧 Configurando entorno de Codespaces..."

# Crear directorio para logs
mkdir -p logs

# Instalar dependencias Python
if [ -f "requirements.txt" ]; then
    echo "📦 Instalando dependencias Python..."
    pip install -r requirements.txt
else
    echo "📦 Instalando Flask básico..."
    pip install flask flask-cors
fi

# Configurar Git si no está configurado
if [ -z "$(git config --global user.name)" ]; then
    echo "📝 Configurando Git con información del usuario de GitHub..."
    git config --global user.name "$GITHUB_USER"
    git config --global user.email "$GITHUB_USER@users.noreply.github.com"
fi

# Crear archivo de configuración específico para Codespaces
cat > .env << EOF
ENVIRONMENT=codespaces
CODESPACE_NAME=$CODESPACE_NAME
GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN=$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN
EOF

# Hacer ejecutables los scripts
chmod +x scripts/*.sh
chmod +x *.sh

# Información del entorno
echo ""
echo "✅ Setup de Codespaces completado!"
echo "🌐 Entorno: GitHub Codespaces"
echo "🐍 Python: $(python --version)"
echo "📁 Workspace: /workspaces/tic-tac-toe-agent"
echo ""
echo "🎮 Para iniciar el juego ejecuta:"
echo "   ./start-game.sh"
echo ""
echo "📊 Para monitorear el sistema:"
echo "   ./monitor-system.sh"
echo ""
