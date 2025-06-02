#!/bin/bash
# 🎯 Configurador de perfil específico para Codespaces
# Crea un perfil de VS Code optimizado solo para este proyecto

echo "🎯 Configurando perfil específico para Codespaces..."

# Crear configuración de workspace específica
mkdir -p .vscode

# Configuraciones específicas del workspace que anulan las del usuario
cat > .vscode/settings.json << 'EOF'
{
  // Configuraciones específicas de Python para este proyecto
  "python.defaultInterpreterPath": "/usr/local/bin/python",
  "python.terminal.activateEnvironment": true,
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  
  // Desactivar funcionalidades que pueden ser pesadas en web
  "typescript.preferences.includePackageJsonAutoImports": "off",
  "typescript.suggest.autoImports": false,
  "javascript.suggest.autoImports": false,
  
  // Optimizaciones para rendimiento en Codespaces
  "editor.quickSuggestions": {
    "other": false,
    "comments": false,
    "strings": false
  },
  "editor.parameterHints.enabled": false,
  "editor.hover.delay": 1000,
  "editor.wordBasedSuggestions": "off",
  
  // Autoguardado optimizado
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  
  // Exclusiones para mejorar rendimiento
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/node_modules/**": true,
    "**/tmp/**": true,
    "**/__pycache__/**": true,
    "**/venv/**": true,
    "**/.pytest_cache/**": true
  },
  
  "search.exclude": {
    "**/node_modules": true,
    "**/venv": true,
    "**/__pycache__": true,
    "**/.git": true
  },
  
  // Terminal específico para Linux
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.shell.linux": "/bin/bash",
  
  // Prevenir instalación automática de extensiones
  "extensions.autoCheckUpdates": false,
  "extensions.autoUpdate": false,
  "extensions.ignoreRecommendations": true,
  
  // Configuraciones específicas del proyecto
  "python.testing.pytestEnabled": true,
  "python.testing.unittestEnabled": false,
  "python.testing.nosetestsEnabled": false,
  
  // Git optimizado
  "git.autofetch": false,
  "git.enableSmartCommit": true,
  "git.confirmSync": false
}
EOF

# Extensiones recomendadas SOLO para este workspace
cat > .vscode/extensions.json << 'EOF'
{
  "recommendations": [
    "ms-python.python",
    "ms-python.pylint",
    "ms-python.black-formatter",
    "ms-vscode.vscode-json",
    "GitHub.copilot",
    "GitHub.copilot-chat",
    "ms-vscode.live-server"
  ],
  "unwantedRecommendations": [
    "ms-vscode.vscode-typescript-next",
    "esbenp.prettier-vscode", 
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-eslint",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense"
  ]
}
EOF

# Configurar snippets útiles para el proyecto
mkdir -p .vscode/snippets
cat > .vscode/snippets/python.json << 'EOF'
{
  "Python Flask Route": {
    "prefix": "flaskroute",
    "body": [
      "@app.route('/$1', methods=['$2'])",
      "def $3():",
      "    \"\"\"$4\"\"\"",
      "    $0",
      "    return jsonify({'status': 'success'})"
    ],
    "description": "Flask route template"
  },
  
  "Python Test Function": {
    "prefix": "testfunc",
    "body": [
      "def test_$1():",
      "    \"\"\"$2\"\"\"",
      "    # Arrange",
      "    $3",
      "    ",
      "    # Act", 
      "    result = $4",
      "    ",
      "    # Assert",
      "    assert result == $0"
    ],
    "description": "Test function template"
  }
}
EOF

# Tareas específicas del proyecto
cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Start Tic-Tac-Toe Server",
            "type": "shell",
            "command": "./start-game.sh",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new"
            },
            "problemMatcher": []
        },
        {
            "label": "Monitor System",
            "type": "shell", 
            "command": "./monitor-system.sh",
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "new"
            }
        },
        {
            "label": "Clean Extensions",
            "type": "shell",
            "command": "./scripts/clean-extensions.sh",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": true,
                "panel": "new"
            }
        }
    ]
}
EOF

# Configuración de debugging
cat > .vscode/launch.json << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "justMyCode": true
        },
        {
            "name": "Python: Flask App",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/server/server.py",
            "env": {
                "FLASK_ENV": "development",
                "FLASK_DEBUG": "1"
            },
            "console": "integratedTerminal",
            "justMyCode": true
        }
    ]
}
EOF

echo "✅ Configuración de workspace completada!"
echo ""
echo "🎯 Configuraciones aplicadas:"
echo "   - Settings específicos del proyecto en .vscode/settings.json"
echo "   - Extensiones recomendadas y no deseadas en .vscode/extensions.json"
echo "   - Snippets útiles para Python en .vscode/snippets/"
echo "   - Tareas de desarrollo en .vscode/tasks.json"
echo "   - Configuración de debugging en .vscode/launch.json"
echo ""
echo "💡 Estas configuraciones tienen prioridad sobre las de usuario y evitarán conflictos"
