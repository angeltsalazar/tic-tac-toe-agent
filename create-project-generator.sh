#!/bin/bash
# 🚀 Generador Automático de Proyectos con Arquitectura Dual
# Crea un nuevo proyecto con la arquitectura optimizada (Local + Codespaces)
# 
# Autor: Sistema de Monitoreo Tic-Tac-Toe
# Versión: 1.0.0
# Fecha: $(date +%Y-%m-%d)

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Funciones de utilidad
print_header() {
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${WHITE}                🚀 GENERADOR DE PROYECTOS DUAL                 ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${WHITE}            Arquitectura Local + GitHub Codespaces             ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}[PASO $1]${NC} $2"
}

print_success() {
    echo -e "${GREEN}[✅]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠️]${NC} $1"
}

print_error() {
    echo -e "${RED}[❌]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[ℹ️]${NC} $1"
}

# Verificar dependencias
check_dependencies() {
    print_step "1" "Verificando dependencias del sistema..."
    
    local missing_deps=()
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        print_warning "jq no está instalado, instalando..."
        sudo apt-get update -qq && sudo apt-get install -y jq
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Dependencias faltantes: ${missing_deps[*]}"
        print_info "Instala con: sudo apt-get install ${missing_deps[*]}"
        exit 1
    fi
    
    print_success "Todas las dependencias están disponibles"
}

# Función para obtener información del proyecto
get_project_info() {
    print_step "2" "Configuración del proyecto..."
    echo ""
    
    # Nombre del proyecto
    while true; do
        echo -e "${WHITE}📝 Nombre del proyecto${NC} (sin espacios, usar guiones):"
        echo -e "   Ejemplo: ${CYAN}mi-app-web${NC}, ${CYAN}api-usuarios${NC}, ${CYAN}dashboard-analytics${NC}"
        read -p "   > " PROJECT_NAME
        
        if [[ "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
            break
        else
            print_error "Nombre inválido. Solo minúsculas, números y guiones."
        fi
    done
    
    # Descripción
    echo ""
    echo -e "${WHITE}📄 Descripción del proyecto${NC} (una línea):"
    echo -e "   Ejemplo: ${CYAN}API REST para gestión de usuarios con autenticación${NC}"
    read -p "   > " PROJECT_DESCRIPTION
    
    # Stack tecnológico
    echo ""
    echo -e "${WHITE}🔧 Stack tecnológico principal:${NC}"
    echo "   1) Python (Flask/FastAPI/Django)"
    echo "   2) Node.js (Express/Next.js/NestJS)"
    echo "   3) Full-Stack (Python + React/Vue)"
    echo "   4) Otro (configuración manual después)"
    
    while true; do
        read -p "   Selecciona [1-4]: " STACK_CHOICE
        case $STACK_CHOICE in
            1) TECH_STACK="python"; break;;
            2) TECH_STACK="nodejs"; break;;
            3) TECH_STACK="fullstack"; break;;
            4) TECH_STACK="other"; break;;
            *) print_error "Opción inválida. Selecciona 1, 2, 3 o 4.";;
        esac
    done
    
    # GitHub username
    echo ""
    echo -e "${WHITE}👤 Tu usuario de GitHub:${NC}"
    if git config user.name &>/dev/null; then
        SUGGESTED_USER=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        echo -e "   Sugerencia basada en git config: ${CYAN}$SUGGESTED_USER${NC}"
    fi
    read -p "   > " GITHUB_USER
    
    # Confirmación
    echo ""
    echo -e "${PURPLE}╔═══ RESUMEN DE CONFIGURACIÓN ═══╗${NC}"
    echo -e "${PURPLE}║${NC} 📦 Proyecto: ${CYAN}$PROJECT_NAME${NC}"
    echo -e "${PURPLE}║${NC} 📄 Descripción: $PROJECT_DESCRIPTION"
    echo -e "${PURPLE}║${NC} 🔧 Stack: ${YELLOW}$TECH_STACK${NC}"
    echo -e "${PURPLE}║${NC} 👤 Usuario: ${CYAN}$GITHUB_USER${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════╝${NC}"
    echo ""
    
    while true; do
        read -p "¿Continuar con esta configuración? [y/N]: " CONFIRM
        case $CONFIRM in
            [Yy]|[Yy][Ee][Ss]) break;;
            [Nn]|[Nn][Oo]|"") echo "Operación cancelada."; exit 0;;
            *) print_error "Responde 'y' para sí o 'n' para no.";;
        esac
    done
}

# Crear estructura base del proyecto
create_project_structure() {
    print_step "3" "Creando estructura del proyecto..."
    
    # Crear directorio principal
    if [ -d "$PROJECT_NAME" ]; then
        print_error "El directorio '$PROJECT_NAME' ya existe"
        exit 1
    fi
    
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"
    
    # Crear estructura de directorios
    print_info "Creando directorios..."
    mkdir -p {.devcontainer,scripts,src,tests,docs,assets,config}
    
    # Archivos base
    touch {README.md,.env.example,.gitignore}
    
    print_success "Estructura base creada"
}

# Generar .gitignore según el stack
generate_gitignore() {
    print_info "Generando .gitignore..."
    
    cat > .gitignore << 'EOF'
# Entornos virtuales
venv/
env/
.env
.venv

# Dependencias
node_modules/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python

# IDEs
.vscode/settings.json
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
.DS_Store?
._*

# Logs y temporales
*.log
logs/
tmp/
.tmp/
.cache/

# Build outputs
dist/
build/
*.egg-info/

# Testing
.coverage
.pytest_cache/
coverage.xml
*.cover

# Databases
*.db
*.sqlite3

# Secrets y configuración local
config/local.json
secrets.json
.env.local
.env.production

# Monitoring outputs
/tmp/*-reports/
/tmp/*-monitor.log
EOF

    # Añadir específicos del stack
    case $TECH_STACK in
        "nodejs")
            echo "" >> .gitignore
            echo "# Node.js específicos" >> .gitignore
            echo "npm-debug.log*" >> .gitignore
            echo "yarn-debug.log*" >> .gitignore
            echo "yarn-error.log*" >> .gitignore
            echo ".npm" >> .gitignore
            echo ".yarn-integrity" >> .gitignore
            ;;
        "python"|"fullstack")
            echo "" >> .gitignore
            echo "# Python específicos" >> .gitignore
            echo "*.so" >> .gitignore
            echo ".tox/" >> .gitignore
            echo ".coverage" >> .gitignore
            echo ".mypy_cache/" >> .gitignore
            ;;
    esac
}

# Generar devcontainer.json
generate_devcontainer() {
    print_info "Generando configuración de Dev Container..."
    
    case $TECH_STACK in
        "python"|"fullstack")
            cat > .devcontainer/devcontainer.json << EOF
{
  "name": "$PROJECT_NAME Development",
  "image": "mcr.microsoft.com/devcontainers/python:3.12-bullseye",
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.pylint",
        "ms-python.black-formatter",
        "ms-python.isort",
        "ms-python.flake8",
        "ms-vscode.vscode-json",
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-vscode.live-server"
      ],
      
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.terminal.activateEnvironment": true,
        "files.autoSave": "afterDelay",
        "files.autoSaveDelay": 1000,
        
        // Optimizaciones para Codespaces
        "typescript.preferences.includePackageJsonAutoImports": "off",
        "typescript.suggest.autoImports": false,
        "editor.quickSuggestions": {
          "other": false,
          "comments": false,
          "strings": false
        },
        "editor.parameterHints.enabled": false,
        "editor.hover.delay": 1000,
        "editor.wordBasedSuggestions": "off",
        
        "files.watcherExclude": {
          "**/.git/objects/**": true,
          "**/node_modules/**": true,
          "**/tmp/**": true,
          "**/__pycache__/**": true,
          "**/venv/**": true,
          "**/.pytest_cache/**": true
        }
      }
    }
  },
  
  "forwardPorts": [8000, 3000, 5000],
  "portsAttributes": {
    "8000": {
      "label": "Main Application",
      "onAutoForward": "notify"
    },
    "3000": {
      "label": "Frontend Dev Server",
      "onAutoForward": "silent"
    },
    "5000": {
      "label": "API Server",
      "onAutoForward": "silent"
    }
  },
  
  "postCreateCommand": "bash scripts/setup-codespaces.sh",
  
  "features": {
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  
  "remoteEnv": {
    "PYTHONPATH": "/workspaces/$PROJECT_NAME",
    "ENVIRONMENT": "codespaces",
    "PYTHONUNBUFFERED": "1"
  }
}
EOF
            ;;
            
        "nodejs")
            cat > .devcontainer/devcontainer.json << EOF
{
  "name": "$PROJECT_NAME Development",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:18-bullseye",
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "esbenp.prettier-vscode",
        "bradlc.vscode-tailwindcss",
        "ms-vscode.vscode-json",
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-vscode.live-server"
      ],
      
      "settings": {
        "typescript.preferences.includePackageJsonAutoImports": "off",
        "typescript.suggest.autoImports": false,
        "files.autoSave": "afterDelay",
        "files.autoSaveDelay": 1000,
        
        "editor.quickSuggestions": {
          "other": false,
          "comments": false,
          "strings": false
        },
        
        "files.watcherExclude": {
          "**/.git/objects/**": true,
          "**/node_modules/**": true,
          "**/dist/**": true,
          "**/tmp/**": true
        }
      }
    }
  },
  
  "forwardPorts": [3000, 8000, 5173],
  "portsAttributes": {
    "3000": {
      "label": "Development Server",
      "onAutoForward": "notify"
    }
  },
  
  "postCreateCommand": "npm install && bash scripts/setup-codespaces.sh",
  
  "features": {
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  
  "remoteEnv": {
    "NODE_ENV": "development",
    "ENVIRONMENT": "codespaces"
  }
}
EOF
            ;;
            
        "other")
            cat > .devcontainer/devcontainer.json << EOF
{
  "name": "$PROJECT_NAME Development",
  "image": "mcr.microsoft.com/devcontainers/universal:2-focal",
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-json",
        "GitHub.copilot",
        "GitHub.copilot-chat"
      ]
    }
  },
  
  "forwardPorts": [8000, 3000, 5000],
  "postCreateCommand": "bash scripts/setup-codespaces.sh",
  
  "features": {
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  
  "remoteEnv": {
    "ENVIRONMENT": "codespaces"
  }
}
EOF
            ;;
    esac
}

# Generar scripts de setup
generate_setup_scripts() {
    print_info "Generando scripts de configuración..."
    
    # Script de setup para Codespaces
    cat > scripts/setup-codespaces.sh << 'EOF'
#!/bin/bash
echo "🚀 Configurando entorno de desarrollo en GitHub Codespaces..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✅]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[⚠️]${NC} $1"; }
print_error() { echo -e "${RED}[❌]${NC} $1"; }

# Actualizar sistema
print_status "Actualizando sistema..."
sudo apt-get update -qq

# Instalar herramientas útiles
print_status "Instalando herramientas del sistema..."
sudo apt-get install -y -qq htop tree curl wget unzip jq ncdu git-lfs

# Configuración específica por stack
EOF

    case $TECH_STACK in
        "python"|"fullstack")
            cat >> scripts/setup-codespaces.sh << 'EOF'

# Configuración Python
if [ -f "requirements.txt" ]; then
    print_status "Instalando dependencias de Python..."
    pip install -r requirements.txt
    print_success "Dependencias de Python instaladas"
fi
EOF
            ;;
        "nodejs"|"fullstack")
            cat >> scripts/setup-codespaces.sh << 'EOF'

# Configuración Node.js
if [ -f "package.json" ]; then
    print_status "Instalando dependencias de Node.js..."
    npm install
    print_success "Dependencias de Node.js instaladas"
fi
EOF
            ;;
    esac

    cat >> scripts/setup-codespaces.sh << 'EOF'

# Hacer scripts ejecutables
print_status "Configurando permisos de scripts..."
find . -name "*.sh" -type f -exec chmod +x {} \;
print_success "Scripts configurados como ejecutables"

# Configurar Git
print_status "Configurando Git..."
git config --global init.defaultBranch main
git config --global core.autocrlf input
git config --global pull.rebase false

# Variables de entorno
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    print_status "Creando archivo .env desde template..."
    cp .env.example .env
    print_warning "Revisa y ajusta las variables en .env"
fi

print_success "🎉 GitHub Codespaces configurado correctamente!"
echo ""
echo "🎯 Comandos útiles:"
echo "  ./start-app.sh           - Iniciar aplicación"
echo "  ./monitor-system.sh      - Monitorear sistema"
echo "  ./monitor-visual.sh      - Monitor visual en tiempo real"
echo "  ./benchmark-report.sh    - Generar reporte de rendimiento"
echo ""
print_status "El entorno está listo para desarrollo 🚀"
EOF

    # Script de setup local
    cat > scripts/setup-local.sh << 'EOF'
#!/bin/bash
echo "💻 Configurando entorno de desarrollo local..."

# Detectar sistema operativo
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
    OS="windows"
fi

echo "🔍 Sistema operativo detectado: $OS"

EOF

    case $TECH_STACK in
        "python"|"fullstack")
            cat >> scripts/setup-local.sh << 'EOF'
# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 no encontrado."
    case $OS in
        "linux")
            echo "Instalando Python3..."
            sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-venv
            ;;
        "macos")
            echo "Instala Python3 desde https://python.org o usando Homebrew:"
            echo "brew install python3"
            exit 1
            ;;
        "windows")
            echo "Instala Python3 desde https://python.org"
            exit 1
            ;;
    esac
fi

# Crear entorno virtual Python
if [ -f "requirements.txt" ]; then
    if [ ! -d "venv" ]; then
        echo "📦 Creando entorno virtual Python..."
        python3 -m venv venv
    fi
    
    echo "📥 Activando entorno virtual..."
    source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
    
    echo "📦 Instalando dependencias..."
    pip install -r requirements.txt
fi
EOF
            ;;
        "nodejs"|"fullstack")
            cat >> scripts/setup-local.sh << 'EOF'
# Setup Node.js
if [ -f "package.json" ]; then
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js no encontrado. Instala desde https://nodejs.org"
        exit 1
    fi
    
    echo "📦 Instalando dependencias de Node.js..."
    npm install
fi
EOF
            ;;
    esac

    cat >> scripts/setup-local.sh << 'EOF'

# Hacer scripts ejecutables
chmod +x *.sh 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true

# Configurar archivo .env
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    cp .env.example .env
    echo "⚠️  Archivo .env creado. Ajusta las variables según tu entorno."
fi

echo ""
echo "✅ Configuración local completada!"
echo ""
echo "🎯 Próximos pasos:"
if [ -f "requirements.txt" ]; then
    echo "  source venv/bin/activate  # Activar entorno virtual (Linux/macOS)"
    echo "  venv\\Scripts\\activate      # Activar entorno virtual (Windows)"
fi
echo "  ./start-app.sh            # Iniciar aplicación"
echo ""
EOF

    chmod +x scripts/*.sh
}

# Generar archivo de dependencias
generate_dependencies() {
    print_info "Generando archivos de dependencias..."
    
    case $TECH_STACK in
        "python"|"fullstack")
            cat > requirements.txt << 'EOF'
# Dependencias principales
flask>=2.3.0
requests>=2.31.0
python-dotenv>=1.0.0

# Desarrollo y testing
pytest>=7.4.0
black>=23.7.0
flake8>=6.0.0
pylint>=2.17.0

# Monitoreo y logging
psutil>=5.9.0

# Opcional: FastAPI alternative
# fastapi>=0.103.0
# uvicorn>=0.23.0

# Opcional: Base de datos
# sqlalchemy>=2.0.0
# alembic>=1.12.0
EOF
            ;;
        "nodejs"|"fullstack")
            cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "$PROJECT_DESCRIPTION",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "lint": "eslint src/",
    "format": "prettier --write src/"
  },
  "keywords": [],
  "author": "$GITHUB_USER",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.6.4",
    "eslint": "^8.47.0",
    "prettier": "^3.0.2"
  }
}
EOF
            ;;
    esac
}

# Generar código base
generate_base_code() {
    print_info "Generando código base de la aplicación..."
    
    case $TECH_STACK in
        "python"|"fullstack")
            # App principal Python
            cat > src/app.py << 'EOF'
#!/usr/bin/env python3
"""
Aplicación principal
"""
import os
from flask import Flask, jsonify, render_template_string
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

app = Flask(__name__)

# Configuración
app.config['DEBUG'] = os.getenv('DEBUG', 'False').lower() == 'true'
PORT = int(os.getenv('PORT', 8000))

@app.route('/')
def home():
    """Página principal"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>{{ title }}</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            h1 { color: #333; text-align: center; }
            .status { background: #e8f5e8; padding: 20px; border-radius: 5px; margin: 20px 0; }
            .api-link { display: inline-block; background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 10px 5px; }
            .api-link:hover { background: #0056b3; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 {{ title }}</h1>
            <div class="status">
                <h3>✅ Aplicación funcionando correctamente</h3>
                <p><strong>Entorno:</strong> {{ environment }}</p>
                <p><strong>Puerto:</strong> {{ port }}</p>
            </div>
            
            <h3>🔗 API Endpoints:</h3>
            <a href="/api/health" class="api-link">Health Check</a>
            <a href="/api/info" class="api-link">App Info</a>
            
            <h3>📊 Monitoreo:</h3>
            <p>Para monitorear el rendimiento de la aplicación, ejecuta en terminal:</p>
            <pre style="background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto;">
./monitor-system.sh      # Monitor básico
./monitor-visual.sh      # Monitor visual
./benchmark-report.sh    # Reporte completo</pre>
        </div>
    </body>
    </html>
    """
    return render_template_string(html, 
                                  title=os.getenv('APP_NAME', 'Mi Aplicación'),
                                  environment=os.getenv('ENVIRONMENT', 'local'),
                                  port=PORT)

@app.route('/api/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': os.getenv('APP_NAME', 'mi-aplicacion'),
        'environment': os.getenv('ENVIRONMENT', 'local'),
        'version': '1.0.0'
    })

@app.route('/api/info')
def info():
    """Información de la aplicación"""
    return jsonify({
        'name': os.getenv('APP_NAME', 'mi-aplicacion'),
        'description': 'Aplicación generada con arquitectura dual',
        'version': '1.0.0',
        'environment': os.getenv('ENVIRONMENT', 'local'),
        'python_version': os.sys.version,
        'endpoints': [
            '/api/health',
            '/api/info'
        ]
    })

if __name__ == '__main__':
    print(f"🚀 Iniciando aplicación en puerto {PORT}")
    print(f"🌐 Accede en: http://localhost:{PORT}")
    print(f"📊 Health check: http://localhost:{PORT}/api/health")
    
    app.run(host='0.0.0.0', port=PORT, debug=app.config['DEBUG'])
EOF
            ;;
            
        "nodejs")
            # App principal Node.js
            cat > src/index.js << 'EOF'
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Página principal
app.get('/', (req, res) => {
    const html = `
    <!DOCTYPE html>
    <html>
    <head>
        <title>${process.env.APP_NAME || 'Mi Aplicación'}</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            h1 { color: #333; text-align: center; }
            .status { background: #e8f5e8; padding: 20px; border-radius: 5px; margin: 20px 0; }
            .api-link { display: inline-block; background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 10px 5px; }
            .api-link:hover { background: #0056b3; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 ${process.env.APP_NAME || 'Mi Aplicación'}</h1>
            <div class="status">
                <h3>✅ Aplicación funcionando correctamente</h3>
                <p><strong>Entorno:</strong> ${process.env.ENVIRONMENT || 'local'}</p>
                <p><strong>Puerto:</strong> ${PORT}</p>
                <p><strong>Node.js:</strong> ${process.version}</p>
            </div>
            
            <h3>🔗 API Endpoints:</h3>
            <a href="/api/health" class="api-link">Health Check</a>
            <a href="/api/info" class="api-link">App Info</a>
        </div>
    </body>
    </html>
    `;
    res.send(html);
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        service: process.env.APP_NAME || 'mi-aplicacion',
        environment: process.env.ENVIRONMENT || 'local',
        version: '1.0.0',
        uptime: process.uptime()
    });
});

// App info
app.get('/api/info', (req, res) => {
    res.json({
        name: process.env.APP_NAME || 'mi-aplicacion',
        description: 'Aplicación generada con arquitectura dual',
        version: '1.0.0',
        environment: process.env.ENVIRONMENT || 'local',
        node_version: process.version,
        endpoints: [
            '/api/health',
            '/api/info'
        ]
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Servidor iniciado en puerto ${PORT}`);
    console.log(`🌐 Accede en: http://localhost:${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
});
EOF
            ;;
    esac
}

# Generar script de inicio
generate_start_script() {
    print_info "Generando script de inicio..."
    
    cat > start-app.sh << 'EOF'
#!/bin/bash
# Script universal para iniciar la aplicación

# Detectar entorno
if [ "$ENVIRONMENT" = "codespaces" ]; then
    echo "🌐 Iniciando en GitHub Codespaces..."
    CODESPACE_NAME=$(echo $CODESPACE_NAME)
    if [ ! -z "$CODESPACE_NAME" ]; then
        BASE_URL="https://${CODESPACE_NAME}-8000.app.github.dev"
        echo "📱 Tu aplicación estará disponible en: $BASE_URL"
    fi
else
    echo "🏠 Iniciando en entorno local..."
    # Activar entorno virtual si existe
    if [ -d "venv" ]; then
        source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
        echo "✅ Entorno virtual activado"
    fi
    BASE_URL="http://localhost:8000"
fi

# Verificar puerto disponible
PORT=${1:-8000}
if netstat -tln 2>/dev/null | grep -q ":$PORT " || ss -tln 2>/dev/null | grep -q ":$PORT "; then
    echo "⚠️  Puerto $PORT ocupado, usando puerto $((PORT + 1))..."
    PORT=$((PORT + 1))
fi

echo "🚀 Iniciando aplicación en puerto $PORT..."

# Iniciar según el stack
EOF

    case $TECH_STACK in
        "python"|"fullstack")
            cat >> start-app.sh << 'EOF'
# Proyecto Python
if [ -f "src/app.py" ]; then
    cd src && python app.py --port $PORT
elif [ -f "app.py" ]; then
    python app.py --port $PORT
else
    echo "📁 Iniciando servidor HTTP simple..."
    python3 -m http.server $PORT
fi
EOF
            ;;
        "nodejs")
            cat >> start-app.sh << 'EOF'
# Proyecto Node.js
if [ -f "package.json" ]; then
    npm start
else
    echo "❌ package.json no encontrado"
    exit 1
fi
EOF
            ;;
        "other")
            cat >> start-app.sh << 'EOF'
# Servidor HTTP simple como fallback
echo "📁 Iniciando servidor HTTP simple..."
python3 -m http.server $PORT 2>/dev/null || node -e "
const http = require('http');
const fs = require('fs');
const path = require('path');
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('<h1>🚀 Aplicación funcionando</h1><p>Puerto: $PORT</p>');
});
server.listen($PORT, () => console.log('Servidor en puerto $PORT'));
"
EOF
            ;;
    esac

    chmod +x start-app.sh
}

# Copiar scripts de monitoreo
copy_monitoring_scripts() {
    print_step "4" "Copiando sistema de monitoreo..."
    
    # Lista de scripts a copiar
    local scripts=(
        "monitor-system.sh"
        "monitor-visual.sh" 
        "monitor-advanced.sh"
        "benchmark-report.sh"
        "monitor-latency.sh"
    )
    
    local source_dir="/workspaces/tic-tac-toe-agent"
    local copied=0
    
    for script in "${scripts[@]}"; do
        if [ -f "$source_dir/$script" ]; then
            cp "$source_dir/$script" .
            chmod +x "$script"
            
            # Personalizar nombres en los scripts
            sed -i "s/tic-tac-toe-agent/$PROJECT_NAME/g" "$script" 2>/dev/null || true
            sed -i "s/Tic-Tac-Toe/$PROJECT_NAME/g" "$script" 2>/dev/null || true
            
            ((copied++))
            print_success "Copiado: $script"
        else
            print_warning "No encontrado: $script"
        fi
    done
    
    if [ $copied -gt 0 ]; then
        print_success "Sistema de monitoreo instalado ($copied scripts)"
    else
        print_warning "No se pudieron copiar scripts de monitoreo"
        print_info "Los puedes añadir manualmente después"
    fi
}

# Generar archivo .env.example
generate_env_example() {
    print_info "Generando template de variables de entorno..."
    
    cat > .env.example << EOF
# Configuración de la aplicación
APP_NAME=$PROJECT_NAME
ENVIRONMENT=local
DEBUG=true
PORT=8000

# Base de datos (opcional)
# DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# APIs externas (opcional)
# API_KEY=tu-api-key-aqui
# SECRET_KEY=tu-secret-key-aqui

# Configuración específica de desarrollo
# LOG_LEVEL=DEBUG
# CACHE_TTL=3600
EOF
}

# Generar README.md completo
generate_readme() {
    print_step "5" "Generando documentación..."
    
    cat > README.md << EOF
# 🚀 $PROJECT_NAME

[![GitHub Codespaces](https://img.shields.io/badge/GitHub-Codespaces-blue?logo=github)](https://github.com/codespaces)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> $PROJECT_DESCRIPTION

## ✨ Características

- 🌐 **Desarrollo Dual**: Optimizado para local y GitHub Codespaces
- 📊 **Monitoreo Integrado**: Herramientas avanzadas de diagnóstico de rendimiento
- 🚀 **Setup Automático**: Configuración sin fricción en ambos entornos
- 🔧 **Dev Container**: Entorno reproducible con VS Code
- 📈 **Reportes HTML**: Análisis visual de métricas de rendimiento

## 🏗️ Arquitectura

\`\`\`
┌─────────────────┐    ┌─────────────────┐
│  Local Dev      │    │ GitHub Codespaces│
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   VS Code   │ │    │ │  VS Code    │ │
│ │ + DevContainer│◄────┤ │ Web/Desktop │ │
│ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ $PROJECT_NAME │    │ │ $PROJECT_NAME │
│ │ localhost   │ │    │ │ *.github.dev│ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
         ▲                       ▲
         │                       │
    ┌─────────────────────────────────┐
    │     Sistema de Monitoreo        │
    │  CPU • RAM • GPU • Red • Disco  │
    └─────────────────────────────────┘
\`\`\`

## 🚀 Inicio Rápido

### Opción 1: GitHub Codespaces (⭐ Recomendado)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/$GITHUB_USER/$PROJECT_NAME)

1. **Abrir Codespace**: Clic en el botón de arriba o ve al repo → "Code" → "Create codespace"
2. **Esperar configuración**: El entorno se configura automáticamente (2-3 minutos)
3. **Iniciar aplicación**: 
   \`\`\`bash
   ./start-app.sh
   \`\`\`
4. **Acceder**: Se abrirá automáticamente tu aplicación en el navegador

### Opción 2: Desarrollo Local

#### Linux/macOS
\`\`\`bash
# Clonar repositorio
git clone https://github.com/$GITHUB_USER/$PROJECT_NAME.git
cd $PROJECT_NAME

# Configurar entorno
./scripts/setup-local.sh

EOF

    if [ "$TECH_STACK" = "python" ] || [ "$TECH_STACK" = "fullstack" ]; then
        cat >> README.md << 'EOF'
# Activar entorno virtual (Python)
source venv/bin/activate

EOF
    fi

    cat >> README.md << 'EOF'
# Iniciar aplicación
./start-app.sh
```

## 📊 Sistema de Monitoreo de Rendimiento

Este proyecto incluye un sistema completo de monitoreo para analizar el rendimiento tanto en desarrollo local como en GitHub Codespaces.

### 🔧 Herramientas Disponibles

| Script | Descripción | Uso |
|--------|-------------|-----|
| `monitor-system.sh` | Monitor básico del sistema | `./monitor-system.sh` |
| `monitor-visual.sh` | Monitor visual en tiempo real | `./monitor-visual.sh` |
| `monitor-advanced.sh` | Análisis con herramientas especializadas | `./monitor-advanced.sh` |
| `benchmark-report.sh` | Generador de reportes HTML | `./benchmark-report.sh` |
| `monitor-latency.sh` | Diagnóstico de latencia del teclado | `./monitor-latency.sh` |

### 📈 Ejemplo de Uso

```bash
# Monitor básico - snapshot del sistema
./monitor-system.sh

# Monitor visual - actualización en tiempo real
./monitor-visual.sh

# Generar reporte completo
./benchmark-report.sh
# El reporte se guarda en /tmp/EOF

    echo "$PROJECT_NAME-reports/" >> README.md
    
    cat >> README.md << EOF
\`\`\`

## 🛠️ Desarrollo

### Estructura del Proyecto
\`\`\`
$PROJECT_NAME/
├── .devcontainer/              # Configuración Dev Container
│   └── devcontainer.json
├── scripts/                    # Scripts de configuración
│   ├── setup-codespaces.sh     # Setup para Codespaces
│   └── setup-local.sh          # Setup para desarrollo local
├── src/                        # Código fuente principal
EOF

    case $TECH_STACK in
        "python"|"fullstack")
            cat >> README.md << 'EOF'
│   ├── __init__.py
│   └── app.py                  # Aplicación principal Flask
EOF
            ;;
        "nodejs")
            cat >> README.md << 'EOF'
│   └── index.js                # Aplicación principal Express
EOF
            ;;
    esac

    cat >> README.md << 'EOF'
├── tests/                      # Tests unitarios
├── docs/                       # Documentación adicional
├── config/                     # Archivos de configuración
├── assets/                     # Recursos estáticos
├── monitor-*.sh                # Herramientas de monitoreo
├── benchmark-report.sh         # Generador de reportes
├── start-app.sh               # Script de inicio
EOF

    case $TECH_STACK in
        "python"|"fullstack")
            echo "├── requirements.txt           # Dependencias Python" >> README.md
            ;;
        "nodejs"|"fullstack")
            echo "├── package.json               # Dependencias Node.js" >> README.md
            ;;
    esac

    cat >> README.md << 'EOF'
├── .env.example              # Variables de entorno ejemplo
└── README.md                 # Este archivo
```

### 🔧 Stack Tecnológico

EOF

    case $TECH_STACK in
        "python")
            echo "- **Backend**: Python 3.12+ con Flask" >> README.md
            echo "- **Testing**: pytest" >> README.md
            ;;
        "nodejs")
            echo "- **Backend**: Node.js 18+ con Express" >> README.md
            echo "- **Testing**: Jest" >> README.md
            ;;
        "fullstack")
            echo "- **Backend**: Python 3.12+ con Flask" >> README.md
            echo "- **Frontend**: Node.js 18+ (configurable)" >> README.md
            echo "- **Testing**: pytest + Jest" >> README.md
            ;;
        "other")
            echo "- **Stack**: Configurable según necesidades" >> README.md
            ;;
    esac

    cat >> README.md << 'EOF'
- **Desarrollo**: VS Code + Dev Containers
- **Deploy**: GitHub Codespaces + Local
- **Monitoreo**: Scripts bash personalizados

### 🧪 Ejecutar Tests
```bash
EOF

    case $TECH_STACK in
        "python"|"fullstack")
            cat >> README.md << 'EOF'
# Tests unitarios Python
python -m pytest tests/

# Tests con coverage
python -m pytest tests/ --cov=src
EOF
            ;;
        "nodejs"|"fullstack")
            cat >> README.md << 'EOF'
# Tests unitarios Node.js
npm test

# Tests con coverage
npm run test:coverage
EOF
            ;;
    esac

    cat >> README.md << EOF
\`\`\`

## 🌐 Entornos

### GitHub Codespaces
- **URL**: \`https://tu-codespace-8000.app.github.dev\`
- **Configuración**: Automática via \`.devcontainer/\`
- **Recursos**: 4-core, 8GB RAM, 32GB storage
- **Tiempo de setup**: ~2-3 minutos

### Desarrollo Local
- **URL**: \`http://localhost:8000\`
EOF

    case $TECH_STACK in
        "python"|"fullstack")
            echo "- **Requisitos**: Python 3.12+, Git" >> README.md
            ;;
        "nodejs")
            echo "- **Requisitos**: Node.js 18+, Git" >> README.md
            ;;
        "other")
            echo "- **Requisitos**: Git, herramientas específicas del stack" >> README.md
            ;;
    esac

    cat >> README.md << 'EOF'
- **Setup**: Manual via `scripts/setup-local.sh`
- **Tiempo de setup**: ~5-10 minutos

## 📋 Requisitos del Sistema

### Mínimos
- **OS**: Linux, macOS, Windows 10+
- **RAM**: 4GB (8GB recomendado)
- **Storage**: 2GB libres
- **Network**: Conexión a internet estable

### Recomendados
- **OS**: Ubuntu 20.04+, macOS 12+, Windows 11
- **RAM**: 8GB+ (16GB para análisis intensivos)
- **CPU**: 4+ cores
- **Network**: 50+ Mbps para Codespaces

## 🚀 Roadmap

- [x] ✅ **v0.1**: Configuración base dual (Local + Codespaces)
- [ ] 🔄 **v0.2**: Tests automatizados y CI/CD
- [ ] 📋 **v0.3**: Dashboard web para monitoreo
- [ ] 🐳 **v0.4**: Deployment con Docker
- [ ] 📱 **v0.5**: Optimizaciones avanzadas

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. **Fork** el proyecto
2. **Crea** tu rama feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'feat: Add AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abre** un Pull Request

## 📄 Licencia

Distribuido bajo la Licencia MIT. Ver [`LICENSE`](LICENSE) para más información.

## 👥 Autores

EOF

    echo "- **$GITHUB_USER** - *Desarrollo inicial* - [@$GITHUB_USER](https://github.com/$GITHUB_USER)" >> README.md

    cat >> README.md << 'EOF'

## 🙏 Agradecimientos

- [GitHub Codespaces](https://github.com/features/codespaces) por el entorno de desarrollo en la nube
- [Dev Containers](https://containers.dev/) por la estandarización de entornos
- Sistema de monitoreo basado en [tic-tac-toe-agent](https://github.com/usuario/tic-tac-toe-agent)

---

<div align="center">

**⭐ Si este proyecto te resultó útil, considera darle una estrella ⭐**

EOF

    echo "[![GitHub stars](https://img.shields.io/github/stars/$GITHUB_USER/$PROJECT_NAME?style=social)](https://github.com/$GITHUB_USER/$PROJECT_NAME/stargazers)" >> README.md

    echo "" >> README.md
    echo "</div>" >> README.md
}

# Inicializar Git y crear commits
initialize_git() {
    print_step "6" "Inicializando repositorio Git..."
    
    git init
    git add .
    git commit -m "🎉 Proyecto inicial generado con arquitectura dual (Local + Codespaces)

- Configuración completa para desarrollo local y GitHub Codespaces
- Sistema de monitoreo integrado
- Stack: $TECH_STACK
- Scripts de setup automático
- Documentación completa"

    # Crear tag inicial
    git tag -a v0.1 -m "Release v0.1: Configuración base con arquitectura dual"
    
    print_success "Repositorio Git inicializado con commit inicial"
}

# Generar documentación de uso del generador
generate_generator_docs() {
    print_step "7" "Generando documentación del generador..."
    
    cat > docs/GENERATOR-INFO.md << 'EOF'
# 📋 Información del Generador de Proyectos

## 🎯 ¿Qué es este proyecto?

Este proyecto fue generado automáticamente usando el **Generador de Proyectos con Arquitectura Dual**, una herramienta que crea proyectos optimizados para funcionar tanto en desarrollo local como en GitHub Codespaces.

## 🛠️ Características Incluidas

### ✅ Lo que YA está configurado:
- **Dev Container** completo para VS Code/Codespaces
- **Scripts de setup** automático para ambos entornos
- **Sistema de monitoreo** de rendimiento integrado
- **Estructura de proyecto** estandarizada
- **Documentación** completa y profesional
- **Configuración Git** con commit inicial
- **Variables de entorno** con template

### 🔧 Stack Tecnológico Configurado:
- **Lenguaje**: [Tu stack seleccionado]
- **Contenedor**: Dev Container con extensiones optimizadas
- **Monitoreo**: 5 herramientas especializadas
- **Setup**: Scripts multiplataforma automáticos

## 📊 Sistema de Monitoreo Incluido

Tu proyecto viene con un sistema completo de monitoreo:

1. **monitor-system.sh** - Métricas básicas del sistema
2. **monitor-visual.sh** - Dashboard visual en tiempo real
3. **monitor-advanced.sh** - Análisis con herramientas especializadas
4. **benchmark-report.sh** - Reportes HTML detallados
5. **monitor-latency.sh** - Diagnóstico de latencia específico

## 🎯 Próximos Pasos Recomendados

### 1. **Verificar Funcionamiento** (5 min)
```bash
# Probar que todo funciona
./start-app.sh

# Verificar monitoreo
./monitor-system.sh
```

### 2. **Personalizar Aplicación** (30 min)
- Edita `src/app.py` (Python) o `src/index.js` (Node.js)
- Añade tus endpoints específicos
- Configura variables en `.env`

### 3. **Añadir Funcionalidades** (según proyecto)
- Implementa tu lógica de negocio
- Añade base de datos si es necesario
- Crea tests para tus funciones

### 4. **Configurar CI/CD** (15 min)
```bash
# Crear workflow básico
mkdir -p .github/workflows
# Copiar template de CI desde documentación
```

### 5. **Deploy en GitHub** (10 min)
```bash
# Crear repositorio en GitHub
gh repo create tu-usuario/tu-proyecto --public

# Subir código
git remote add origin https://github.com/tu-usuario/tu-proyecto.git
git push origin main
git push origin v0.1
```

## 🔧 Personalización Avanzada

### Cambiar Puerto por Defecto
Edita `.env.example` y `.env`:
```bash
PORT=3000  # Cambiar de 8000 a tu puerto preferido
```

### Añadir Base de Datos
Para PostgreSQL, edita `.devcontainer/devcontainer.json`:
```json
{
  "features": {
    "ghcr.io/devcontainers/features/postgresql:1": {}
  }
}
```

### Añadir Nuevas Extensiones de VS Code
Edita `.devcontainer/devcontainer.json` → `extensions[]`

### Personalizar Scripts de Monitoreo
Los scripts pueden editarse para añadir métricas específicas de tu aplicación:
```bash
# Editar monitor-system.sh para añadir métricas personalizadas
vim monitor-system.sh
```

## 🆘 Troubleshooting

### Problema: Codespace no inicia
**Solución**: Verificar sintaxis de `.devcontainer/devcontainer.json`
```bash
jq . .devcontainer/devcontainer.json
```

### Problema: Scripts no ejecutan
**Solución**: Verificar permisos
```bash
chmod +x *.sh scripts/*.sh
```

### Problema: Puerto ocupado
**Solución**: El script automáticamente busca puerto libre, o especifica uno:
```bash
./start-app.sh 3001
```

## 📚 Documentación Adicional

- **README.md** - Documentación principal del proyecto
- **SETUP-LOCAL.md** - Guía detallada para desarrollo local  
- **.devcontainer/devcontainer.json** - Configuración del contenedor
- **scripts/** - Scripts de configuración y setup

## 🎨 Personalización de Branding

Para cambiar nombres y branding:

1. **Actualizar variables de entorno**:
   ```bash
   # En .env y .env.example
   APP_NAME="Mi App Personalizada"
   ```

2. **Cambiar título en código**:
   - Python: `src/app.py` → variable `title`
   - Node.js: `src/index.js` → `process.env.APP_NAME`

3. **Actualizar README.md** con tu información específica

## 💡 Tips de Optimización

### Para Mejor Rendimiento:
- Usa `./monitor-visual.sh` para identificar cuellos de botella
- Ejecuta `./benchmark-report.sh` regularmente
- Revisa logs con `./monitor-latency.sh` si VS Code está lento

### Para Desarrollo Eficiente:
- Trabaja en Codespaces para colaboración
- Usa desarrollo local para debugging intensivo
- Aprovecha el hot-reload automático

## 🔮 Roadmap Sugerido

### Semana 1: Setup y Validación
- [ ] Verificar funcionamiento en ambos entornos
- [ ] Personalizar aplicación básica
- [ ] Configurar repositorio en GitHub

### Semana 2: Desarrollo Core
- [ ] Implementar funcionalidades principales
- [ ] Añadir tests básicos
- [ ] Configurar CI/CD básico

### Semana 3: Optimización
- [ ] Usar herramientas de monitoreo para optimizar
- [ ] Añadir funcionalidades avanzadas
- [ ] Mejorar documentación

### Mes 2+: Producción
- [ ] Deploy a producción
- [ ] Monitoreo en producción
- [ ] Iteración basada en métricas

---

## 🙏 Agradecimientos

Este proyecto fue generado usando herramientas del proyecto **tic-tac-toe-agent**, que incluye:
- Sistema de monitoreo avanzado
- Configuración optimizada de Dev Containers
- Scripts de setup multiplataforma
- Documentación profesional automatizada

**¡Disfruta desarrollando tu proyecto!** 🚀
EOF
}

# Función principal
main() {
    print_header
    
    # Verificar que estamos en el directorio correcto
    if [ ! -f "create-project-generator.sh" ]; then
        print_error "Este script debe ejecutarse desde el directorio que contiene los scripts de monitoreo"
        print_info "Navega al directorio correcto y ejecuta: ./create-project-generator.sh"
        exit 1
    fi
    
    # Ejecutar pasos
    check_dependencies
    get_project_info
    create_project_structure
    generate_gitignore
    generate_devcontainer
    generate_setup_scripts
    generate_dependencies
    generate_base_code
    generate_start_script
    copy_monitoring_scripts
    generate_env_example
    generate_readme
    initialize_git
    generate_generator_docs
    
    # Mensaje final
    echo ""
    print_success "🎉 ¡Proyecto '$PROJECT_NAME' generado exitosamente!"
    echo ""
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${WHITE}                        📋 PRÓXIMOS PASOS                        ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║${NC} 1. ${CYAN}cd $PROJECT_NAME${NC}                                       ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC} 2. ${CYAN}./start-app.sh${NC}                    # Probar aplicación      ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC} 3. ${CYAN}./monitor-system.sh${NC}               # Verificar monitoreo    ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC} 4. ${CYAN}gh repo create $GITHUB_USER/$PROJECT_NAME --public${NC}     ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC} 5. ${CYAN}git remote add origin <URL> && git push -u origin main${NC} ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📚 Documentación generada:${NC}"
    echo -e "   ${CYAN}README.md${NC}           - Documentación principal"
    echo -e "   ${CYAN}docs/GENERATOR-INFO.md${NC} - Información del generador"
    echo -e "   ${CYAN}.devcontainer/${NC}       - Configuración de Codespaces"
    echo ""
    echo -e "${GREEN}✨ Tu proyecto está listo para desarrollo dual (Local + Codespaces)!${NC}"
}

# Ejecutar si se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
