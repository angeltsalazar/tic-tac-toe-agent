# 🚀 Guía Completa: Nuevo Repositorio con Arquitectura Dual (Local + Codespaces)

> **Objetivo**: Crear un nuevo repositorio desde cero que replique la arquitectura optimizada de este proyecto, permitiendo desarrollo tanto local como en GitHub Codespaces con monitoreo de rendimiento incluido.

## 📚 Acceso Rápido a Guías

### 🎯 ¿Quieres empezar rápidamente?
- **🚀 [Generador Automatizado](docs/GUIA-GENERADOR-AUTOMATIZADO.md)** - Crea toda la estructura automáticamente
- **📋 [Guías Paso a Paso](docs/guias/README.md)** - Guías modulares organizadas por tema

### 📖 Guías Modulares Disponibles
1. **[📋 01-preparacion-inicial.md](docs/guias/01-preparacion-inicial.md)** - Requisitos previos y herramientas
2. **[📦 02-creacion-repositorio.md](docs/guias/02-creacion-repositorio.md)** - Crear y configurar repositorio
3. **[🏗️ 03-estructura-proyecto.md](docs/guias/03-estructura-proyecto.md)** - Organización de archivos
4. **[🐳 04-dev-container.md](docs/guias/04-dev-container.md)** - Configuración Dev Container
5. **[⚙️ 05-scripts-setup.md](docs/guias/05-scripts-setup.md)** - Scripts de automatización
6. **[📊 06-sistema-monitoreo.md](docs/guias/06-sistema-monitoreo.md)** - Sistema de monitoreo
7. **[📚 07-documentacion.md](docs/guias/07-documentacion.md)** - Templates de documentación
8. **[🌐 08-codespaces-config.md](docs/guias/08-codespaces-config.md)** - Configuración Codespaces
9. **[🧪 09-pruebas-validacion.md](docs/guias/09-pruebas-validacion.md)** - Testing y validación
10. **[🔧 10-troubleshooting.md](docs/guias/10-troubleshooting.md)** - Solución de problemas

---

## 🔄 Opciones de Setup

### ⚡ Setup Automático (Recomendado)
```bash
# Usar el generador automatizado
./create-project-generator.sh
```
👉 **[Ver documentación completa del generador](docs/GUIA-GENERADOR-AUTOMATIZADO.md)**

### 📖 Setup Manual (Control total)
Sigue las guías modulares en orden para configuración paso a paso:
👉 **[Comenzar con preparación inicial](docs/guias/01-preparacion-inicial.md)**

### 🎯 Setup por Objetivos
- **Setup Básico**: Guías 01-04
- **Automatización**: Guías 05-06  
- **Documentación**: Guía 07
- **Codespaces**: Guía 08
- **Validación**: Guías 09-10

---

## 📋 Resumen Ejecutivo (Contenido Original)

---

## 🎯 Preparación Inicial

### Requisitos Previos
- ✅ Cuenta de GitHub con acceso a Codespaces
- ✅ Git instalado localmente (versión 2.30+)
- ✅ VS Code con extensiones básicas
- ✅ GitHub CLI (opcional pero recomendado)

### Herramientas Recomendadas
```bash
# Verificar instalaciones
git --version          # Git 2.30+
code --version         # VS Code 1.70+
gh --version           # GitHub CLI 2.0+ (opcional)
python3 --version      # Python 3.8+ (si usas Python)
node --version         # Node.js 16+ (si usas JavaScript/TypeScript)
```

---

## 📦 Creación del Repositorio

### Método 1: GitHub Web (Recomendado para principiantes)
1. 🌐 Ve a [github.com/new](https://github.com/new)
2. 📝 **Nombre**: `tu-proyecto-nombre` (sin espacios, usar guiones)
3. 📄 **Descripción**: Descripción clara de tu proyecto
4. 🔓 **Visibilidad**: Público/Privado según necesites
5. ✅ **Add a README file**
6. ✅ **Add .gitignore**: Selecciona según tu lenguaje (Python, Node, etc.)
7. ✅ **Choose a license**: MIT License (recomendado para proyectos open source)
8. 🚀 **Create repository**

### Método 2: GitHub CLI (Para usuarios avanzados)
```bash
# Crear repositorio y clonarlo en un solo comando
gh repo create tu-proyecto-nombre \
  --public \
  --clone \
  --add-readme \
  --gitignore Python \
  --license MIT

cd tu-proyecto-nombre
```

### Clonar Repositorio (Solo si usaste Método 1)
```bash
git clone https://github.com/tu-usuario/tu-proyecto-nombre.git
cd tu-proyecto-nombre
```

---

## 🏗️ Estructura Base del Proyecto

### Crear Estructura Completa de Directorios
```bash
# Navegar al directorio del proyecto
cd tu-proyecto-nombre

# Crear estructura principal
mkdir -p .devcontainer
mkdir -p scripts
mkdir -p src          # o server/ según tu preferencia
mkdir -p tests
mkdir -p docs
mkdir -p assets       # para imágenes, CSS, etc.
mkdir -p config       # para archivos de configuración

# Crear archivos base del proyecto
touch README.md
touch .env.example
touch .gitignore

# Archivos específicos según stack tecnológico
# Para Python:
touch requirements.txt
touch setup.py
touch app.py          # o main.py

# Para Node.js/JavaScript:
touch package.json
touch index.js        # o app.js

# Para proyectos full-stack:
touch docker-compose.yml
touch Dockerfile
```

### Estructura Final Recomendada
```
tu-proyecto-nombre/
├── .devcontainer/
│   └── devcontainer.json
├── scripts/
│   ├── setup-codespaces.sh
│   ├── setup-local.sh
│   └── start-app.sh
├── src/                    # Código principal
│   ├── __init__.py        # Python
│   └── main.py
├── tests/                 # Tests unitarios
├── docs/                  # Documentación adicional
├── assets/               # Recursos estáticos
├── config/               # Configuraciones
├── monitor-system.sh     # Scripts de monitoreo
├── monitor-visual.sh
├── monitor-latency.sh
├── benchmark-report.sh
├── requirements.txt      # Dependencias Python
├── package.json         # Dependencias Node.js
├── .env.example         # Variables de entorno ejemplo
├── .gitignore
├── README.md
└── LICENSE
```

---

## 🐳 Configuración de Dev Container

### Template para Python
Crea `.devcontainer/devcontainer.json`:

```json
{
  "name": "Tu Proyecto Python Development",
  "image": "mcr.microsoft.com/devcontainers/python:3.12-bullseye",
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.pylint",
        "ms-python.black-formatter",
        "ms-vscode.vscode-json",
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-python.isort",
        "ms-python.flake8"
      ],
      
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.terminal.activateEnvironment": true,
        "files.autoSave": "afterDelay",
        "files.autoSaveDelay": 1000,
        
        // Optimizaciones para rendimiento en Codespaces
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
    }
  },
  
  "postCreateCommand": "bash scripts/setup-codespaces.sh",
  
  "features": {
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  
  "remoteEnv": {
    "PYTHONPATH": "/workspaces/tu-proyecto-nombre",
    "ENVIRONMENT": "codespaces",
    "PYTHONUNBUFFERED": "1"
  }
}
```

### Template para Node.js/TypeScript
Si tu proyecto usa Node.js, cambia la imagen y extensiones:

```json
{
  "name": "Tu Proyecto Node Development",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:18-bullseye",
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "esbenp.prettier-vscode",
        "bradlc.vscode-tailwindcss",
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-vscode.vscode-json"
      ]
    }
  },
  
  "forwardPorts": [3000, 8000, 5173],
  "postCreateCommand": "npm install && bash scripts/setup-codespaces.sh"
}
```

---

## ⚙️ Scripts de Setup y Ejecución

### Script Principal de Setup para Codespaces
Crea `scripts/setup-codespaces.sh`:

```bash
#!/bin/bash
echo "🚀 Configurando entorno de desarrollo en GitHub Codespaces..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# Actualizar sistema
print_status "Actualizando sistema..."
sudo apt-get update -qq

# Instalar herramientas de sistema adicionales
print_status "Instalando herramientas del sistema..."
sudo apt-get install -y -qq \
    htop \
    tree \
    curl \
    wget \
    unzip \
    jq \
    ncdu \
    git-lfs

# Configuración específica por lenguaje
if [ -f "requirements.txt" ]; then
    print_status "Instalando dependencias de Python..."
    pip install -r requirements.txt
    print_success "Dependencias de Python instaladas"
fi

if [ -f "package.json" ]; then
    print_status "Instalando dependencias de Node.js..."
    npm install
    print_success "Dependencias de Node.js instaladas"
fi

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
if [ -f ".env.example" ]; then
    if [ ! -f ".env" ]; then
        print_status "Creando archivo .env desde template..."
        cp .env.example .env
        print_warning "Revisa y ajusta las variables en .env"
    fi
fi

# Mensaje final
print_success "🎉 GitHub Codespaces configurado correctamente!"
echo ""
echo "🎯 Comandos útiles:"
echo "  ./start-app.sh           - Iniciar aplicación"
echo "  ./monitor-system.sh      - Monitorear sistema"
echo "  ./monitor-visual.sh      - Monitor visual en tiempo real"
echo "  ./benchmark-report.sh    - Generar reporte de rendimiento"
echo ""
print_status "El entorno está listo para desarrollo 🚀"
```

### Script de Setup Local
Crea `scripts/setup-local.sh`:

```bash
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

# Setup Node.js si existe package.json
if [ -f "package.json" ]; then
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js no encontrado. Instala desde https://nodejs.org"
        exit 1
    fi
    
    echo "📦 Instalando dependencias de Node.js..."
    npm install
fi

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
```

### Script Principal de Inicio
Crea `start-app.sh`:

```bash
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

# Iniciar según el tipo de proyecto
if [ -f "src/app.py" ]; then
    # Proyecto Python con Flask/FastAPI
    cd src && python app.py --port $PORT
elif [ -f "server.py" ]; then
    # Servidor Python simple
    python server.py --port $PORT
elif [ -f "package.json" ]; then
    # Proyecto Node.js
    npm start
elif [ -f "manage.py" ]; then
    # Proyecto Django
    python manage.py runserver 0.0.0.0:$PORT
else
    # Servidor HTTP simple como fallback
    echo "📁 Iniciando servidor HTTP simple..."
    python3 -m http.server $PORT
fi
```

---

## 📊 Sistema de Monitoreo

### Personalizar Scripts de Monitoreo
Los scripts de monitoreo del proyecto original necesitan ser adaptados para tu nuevo proyecto:

#### 1. Copiar Scripts Base
```bash
# Copiar desde el proyecto original
cp /workspaces/tic-tac-toe-agent/monitor-system.sh ./
cp /workspaces/tic-tac-toe-agent/monitor-visual.sh ./
cp /workspaces/tic-tac-toe-agent/monitor-advanced.sh ./
cp /workspaces/tic-tac-toe-agent/benchmark-report.sh ./
cp /workspaces/tic-tac-toe-agent/monitor-latency.sh ./

# Hacer ejecutables
chmod +x monitor-*.sh benchmark-report.sh
```

#### 2. Adaptar Configuraciones
Edita cada script para cambiar:

```bash
# En monitor-system.sh, cambiar:
PROJECT_NAME="tu-proyecto-nombre"           # línea ~15
SERVER_PROCESS="python.*tu-app"            # línea ~20
CLIENT_PROCESS="node.*tu-frontend"         # línea ~21

# En benchmark-report.sh, cambiar:
GAME_TITLE="Tu Proyecto Nombre"            # línea ~10
GAME_DESCRIPTION="Descripción de tu app"   # línea ~11
```

#### 3. Personalizar Métricas
Para proyectos específicos, puedes añadir métricas personalizadas:

```bash
# Ejemplo: Monitor para aplicación web
monitor_web_metrics() {
    echo "📊 Métricas específicas de aplicación web:"
    
    # Conexiones activas
    CONNECTIONS=$(ss -tun | grep :8000 | wc -l)
    echo "  🌐 Conexiones activas: $CONNECTIONS"
    
    # Logs de aplicación
    if [ -f "app.log" ]; then
        ERRORS=$(tail -n 100 app.log | grep -i error | wc -l)
        echo "  ❌ Errores recientes: $ERRORS"
    fi
    
    # Base de datos (si aplica)
    if command -v mysql &> /dev/null; then
        DB_CONNECTIONS=$(mysql -e "SHOW STATUS LIKE 'Threads_connected';" | tail -1 | awk '{print $2}')
        echo "  🗄️  Conexiones DB: $DB_CONNECTIONS"
    fi
}
```

### Crear Monitor Personalizado
Crea `monitor-custom.sh` para métricas específicas de tu aplicación:

```bash
#!/bin/bash
# Monitor personalizado para tu aplicación

PROJECT_NAME="tu-proyecto-nombre"
LOG_FILE="/tmp/${PROJECT_NAME}-custom-monitor.log"

# Función para métricas de tu aplicación específica
monitor_app_specific() {
    echo "=== MÉTRICAS PERSONALIZADAS ===" | tee -a $LOG_FILE
    echo "Timestamp: $(date)" | tee -a $LOG_FILE
    
    # Añadir métricas específicas de tu aplicación aquí
    # Ejemplos:
    
    # API Response time
    if curl -s -w "@/dev/stdin" -o /dev/null http://localhost:8000/health <<< '%{time_total}' &>/dev/null; then
        RESPONSE_TIME=$(curl -s -w '%{time_total}' -o /dev/null http://localhost:8000/health)
        echo "⚡ API Response Time: ${RESPONSE_TIME}s" | tee -a $LOG_FILE
    fi
    
    # Tamaño de archivos de log
    if [ -f "app.log" ]; then
        LOG_SIZE=$(du -h app.log | cut -f1)
        echo "📋 Log file size: $LOG_SIZE" | tee -a $LOG_FILE
    fi
    
    # Usuarios activos (si tienes sesiones)
    # ACTIVE_USERS=$(redis-cli eval "return #redis.call('keys', 'session:*')" 0 2>/dev/null || echo "N/A")
    # echo "👥 Usuarios activos: $ACTIVE_USERS" | tee -a $LOG_FILE
}

# Ejecutar monitoreo
monitor_app_specific
```

---

## 📚 Documentación del Proyecto

### README.md Completo
Reemplaza el contenido de `README.md`:

```markdown
# 🚀 [Tu Proyecto Nombre]

[![GitHub Codespaces](https://img.shields.io/badge/GitHub-Codespaces-blue?logo=github)](https://github.com/codespaces)
[![Python](https://img.shields.io/badge/Python-3.12+-blue?logo=python)](https://python.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> Descripción breve y atractiva de tu proyecto. Qué hace, por qué es útil, y qué tecnologías usa.

## ✨ Características

- 🌐 **Desarrollo Dual**: Optimizado para local y GitHub Codespaces
- 📊 **Monitoreo Integrado**: Herramientas avanzadas de diagnóstico de rendimiento
- 🚀 **Setup Automático**: Configuración sin fricción en ambos entornos
- 🔧 **Dev Container**: Entorno reproducible con VS Code
- 📈 **Reportes HTML**: Análisis visual de métricas de rendimiento

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐
│  Local Dev      │    │ GitHub Codespaces│
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   VS Code   │ │    │ │  VS Code    │ │
│ │ + DevContainer│◄────┤ │ Web/Desktop │ │
│ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Tu App      │ │    │ │ Tu App      │ │
│ │ localhost   │ │    │ │ *.github.dev│ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
         ▲                       ▲
         │                       │
    ┌─────────────────────────────────┐
    │     Sistema de Monitoreo        │
    │  CPU • RAM • GPU • Red • Disco  │
    └─────────────────────────────────┘
```

## 🚀 Inicio Rápido

### Opción 1: GitHub Codespaces (⭐ Recomendado)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tu-usuario/tu-proyecto-nombre)

1. **Abrir Codespace**: Clic en el botón de arriba o ve al repo → "Code" → "Create codespace"
2. **Esperar configuración**: El entorno se configura automáticamente (2-3 minutos)
3. **Iniciar aplicación**: 
   ```bash
   ./start-app.sh
   ```
4. **Acceder**: Se abrirá automáticamente tu aplicación en el navegador

### Opción 2: Desarrollo Local

#### Linux/macOS
```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/tu-proyecto-nombre.git
cd tu-proyecto-nombre

# Configurar entorno
./scripts/setup-local.sh

# Activar entorno virtual (Python)
source venv/bin/activate

# Iniciar aplicación
./start-app.sh
```

#### Windows
```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/tu-proyecto-nombre.git
cd tu-proyecto-nombre

# Configurar entorno
bash scripts/setup-local.sh

# Activar entorno virtual (Python)
venv\Scripts\activate

# Iniciar aplicación
bash start-app.sh
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
# El reporte se guarda en /tmp/tu-proyecto-reports/
```

### 📊 Métricas Monitoreadas

- **CPU**: Uso por núcleo, procesos principales, carga promedio
- **Memoria**: RAM total/usada, swap, memoria de procesos específicos
- **GPU**: Uso de NVIDIA GPU (si está disponible)
- **Red**: Tráfico de entrada/salida, conexiones activas
- **Disco**: Espacio usado, I/O, velocidad de lectura/escritura
- **Latencia**: Diagnóstico específico de VS Code y teclado

## 🛠️ Desarrollo

### Estructura del Proyecto
```
tu-proyecto-nombre/
├── .devcontainer/              # Configuración Dev Container
│   └── devcontainer.json
├── scripts/                    # Scripts de configuración
│   ├── setup-codespaces.sh     # Setup para Codespaces
│   └── setup-local.sh          # Setup para desarrollo local
├── src/                        # Código fuente principal
│   ├── __init__.py
│   └── app.py                  # Aplicación principal
├── tests/                      # Tests unitarios
├── docs/                       # Documentación adicional
├── config/                     # Archivos de configuración
├── assets/                     # Recursos estáticos
├── monitor-*.sh                # Herramientas de monitoreo
├── benchmark-report.sh         # Generador de reportes
├── start-app.sh               # Script de inicio
├── requirements.txt           # Dependencias Python
├── .env.example              # Variables de entorno ejemplo
└── README.md                 # Este archivo
```

### 🔧 Stack Tecnológico

- **Backend**: Python 3.12+ / Node.js 18+ (según tu elección)
- **Frontend**: [Tu framework - React, Vue, Vanilla JS, etc.]
- **Desarrollo**: VS Code + Dev Containers
- **Deploy**: GitHub Codespaces + Local
- **Monitoreo**: Scripts bash personalizados

### 🧪 Ejecutar Tests
```bash
# Tests unitarios
python -m pytest tests/

# Tests con coverage
python -m pytest tests/ --cov=src

# Tests de integración
python -m pytest tests/integration/
```

### 📝 Coding Standards
- **Python**: PEP 8, Black formatter, type hints
- **JavaScript**: ESLint, Prettier
- **Commits**: Conventional Commits (`feat:`, `fix:`, `docs:`, etc.)

## 🌐 Entornos

### GitHub Codespaces
- **URL**: `https://tu-codespace-8000.app.github.dev`
- **Configuración**: Automática via `.devcontainer/`
- **Recursos**: 4-core, 8GB RAM, 32GB storage
- **Tiempo de setup**: ~2-3 minutos

### Desarrollo Local
- **URL**: `http://localhost:8000`
- **Requisitos**: Python 3.12+, Git
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

- [ ] ✅ **v0.1**: Configuración base dual (Local + Codespaces)
- [ ] 🔄 **v0.2**: Tests automatizados y CI/CD
- [ ] 📋 **v0.3**: Dashboard web para monitoreo
- [ ] 🐳 **v0.4**: Deployment con Docker
- [ ] 📱 **v0.5**: App móvil / PWA

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. **Fork** el proyecto
2. **Crea** tu rama feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'feat: Add AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abre** un Pull Request

### 📋 Guidelines
- Seguir los coding standards del proyecto
- Añadir tests para nuevas funcionalidades
- Actualizar documentación si es necesario
- Usar conventional commits

## 📄 Licencia

Distribuido bajo la Licencia MIT. Ver [`LICENSE`](LICENSE) para más información.

## 👥 Autores

- **Tu Nombre** - *Desarrollo inicial* - [@tu-usuario](https://github.com/tu-usuario)

## 🙏 Agradecimientos

- [GitHub Codespaces](https://github.com/features/codespaces) por el entorno de desarrollo en la nube
- [Dev Containers](https://containers.dev/) por la estandarización de entornos
- Comunidad open source por las herramientas y librerías utilizadas

---

<div align="center">

**⭐ Si este proyecto te resultó útil, considera darle una estrella ⭐**

[![GitHub stars](https://img.shields.io/github/stars/tu-usuario/tu-proyecto-nombre?style=social)](https://github.com/tu-usuario/tu-proyecto-nombre/stargazers)

</div>
```

### Documentación Adicional
Crea los siguientes archivos de documentación:

#### `SETUP-LOCAL.md`
```markdown
# 💻 Configuración para Desarrollo Local

Guía detallada para configurar el proyecto en tu máquina local.

## 📋 Requisitos Previos

### Sistema Operativo
- **Linux**: Ubuntu 18.04+ (recomendado: 20.04+)
- **macOS**: 10.15+ (recomendado: 12+)
- **Windows**: Windows 10+ con WSL2 (recomendado: Windows 11)

### Software Requerido
- **Git**: 2.30+
- **Python**: 3.12+ (con pip y venv)
- **VS Code**: Última versión
- **Terminal**: Bash-compatible

## 🚀 Instalación Paso a Paso

### 1. Clonar el Repositorio
[Instrucciones detalladas...]

### 2. Configurar Python
[Instrucciones específicas por OS...]

### 3. Entorno Virtual
[Comandos y troubleshooting...]

### 4. Variables de Entorno
[Configuración de .env...]

### 5. Verificación
[Tests para confirmar que todo funciona...]
```

#### `CODESPACES-SETUP.md`
```markdown
# 🌐 Configuración GitHub Codespaces

Guía específica para trabajar con GitHub Codespaces.

## ⚡ Inicio Rápido
[Pasos básicos...]

## 🔧 Configuración Avanzada
[Customizaciones del dev container...]

## 🚀 Optimización de Rendimiento
[Tips para mejorar velocidad...]

## 🔒 Secrets y Variables de Entorno
[Configuración de secrets...]

## 🆘 Troubleshooting
[Problemas comunes y soluciones...]
```

---

## 🌐 Configuración de GitHub Codespaces

### Configurar Variables de Entorno (si necesarias)
1. Ve a tu repositorio → **Settings** → **Secrets and variables** → **Codespaces**
2. Añade secrets necesarios (API keys, tokens, etc.)
3. Configura variables de entorno públicas

### Personalizar el Codespace
```json
// En .devcontainer/devcontainer.json puedes añadir:
{
  "remoteEnv": {
    "TU_API_KEY": "${localEnv:TU_API_KEY}",
    "DEBUG": "true",
    "ENVIRONMENT": "codespaces"
  }
}
```

---

## 🧪 Pruebas y Validación

### Checklist de Validación

#### 1. Probar en GitHub Codespaces
```bash
# 1. Crear nuevo codespace desde tu repo
# 2. Esperar configuración automática (2-3 min)
# 3. Verificar scripts ejecutables:
ls -la *.sh scripts/*.sh

# 4. Probar inicio de aplicación:
./start-app.sh

# 5. Verificar puertos:
curl http://localhost:8000

# 6. Probar monitoreo:
./monitor-system.sh
./monitor-visual.sh
```

#### 2. Probar Localmente
```bash
# En máquina local fresca:
git clone https://github.com/tu-usuario/tu-proyecto-nombre.git
cd tu-proyecto-nombre

# Setup automático:
./scripts/setup-local.sh

# Activar entorno:
source venv/bin/activate  # Linux/macOS
# venv\Scripts\activate   # Windows

# Iniciar aplicación:
./start-app.sh

# Verificar funcionamiento:
curl http://localhost:8000
```

#### 3. Validar Monitoreo
```bash
# Probar cada herramienta:
./monitor-system.sh      # ✅ Debe mostrar métricas básicas
./monitor-visual.sh      # ✅ Debe mostrar interface colorida
./benchmark-report.sh    # ✅ Debe generar reporte HTML
./monitor-latency.sh     # ✅ Debe diagnosticar latencia

# Verificar archivos generados:
ls -la /tmp/tu-proyecto-*
```

### Automatizar las Pruebas
Crea `test-setup.sh`:

```bash
#!/bin/bash
# Script para validar configuración automáticamente

echo "🧪 Ejecutando tests de configuración..."

# Test 1: Verificar estructura
echo "📁 Verificando estructura de archivos..."
REQUIRED_FILES=(".devcontainer/devcontainer.json" "scripts/setup-codespaces.sh" "start-app.sh")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file existe"
    else
        echo "❌ $file NO EXISTE"
        exit 1
    fi
done

# Test 2: Verificar permisos
echo "🔐 Verificando permisos de scripts..."
SCRIPTS=($(find . -name "*.sh" -type f))
for script in "${SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        echo "✅ $script es ejecutable"
    else
        echo "❌ $script NO es ejecutable"
        chmod +x "$script"
        echo "🔧 Permisos corregidos para $script"
    fi
done

# Test 3: Verificar sintaxis JSON
echo "📄 Verificando sintaxis del devcontainer..."
if jq . .devcontainer/devcontainer.json >/dev/null 2>&1; then
    echo "✅ devcontainer.json tiene sintaxis válida"
else
    echo "❌ devcontainer.json tiene errores de sintaxis"
    exit 1
fi

echo "🎉 Todos los tests pasaron correctamente!"
```

---

## ✅ Lista de Verificación Final

### 📋 Setup Inicial
- [ ] ✅ Repositorio creado en GitHub
- [ ] ✅ Estructura de directorios establecida
- [ ] ✅ Archivos base creados (README, .gitignore, etc.)

### 🐳 Dev Container
- [ ] ✅ `.devcontainer/devcontainer.json` configurado
- [ ] ✅ Extensiones de VS Code especificadas
- [ ] ✅ Puertos configurados correctamente
- [ ] ✅ Variables de entorno establecidas

### ⚙️ Scripts de Setup
- [ ] ✅ `scripts/setup-codespaces.sh` creado y ejecutable
- [ ] ✅ `scripts/setup-local.sh` creado y ejecutable
- [ ] ✅ `start-app.sh` creado y ejecutable
- [ ] ✅ Scripts de monitoreo copiados y adaptados

### 📊 Sistema de Monitoreo
- [ ] ✅ `monitor-system.sh` adaptado para tu proyecto
- [ ] ✅ `monitor-visual.sh` funcionando
- [ ] ✅ `benchmark-report.sh` generando reportes
- [ ] ✅ `monitor-latency.sh` diagnosticando correctamente
- [ ] ✅ Scripts personalizados añadidos (opcional)

### 📚 Documentación
- [ ] ✅ `README.md` actualizado con información completa
- [ ] ✅ `SETUP-LOCAL.md` creado con instrucciones detalladas
- [ ] ✅ `CODESPACES-SETUP.md` creado
- [ ] ✅ Documentación de API/funcionalidades (si aplica)

### 🧪 Validación
- [ ] ✅ Probado en GitHub Codespaces
- [ ] ✅ Probado en desarrollo local (Linux/macOS/Windows)
- [ ] ✅ Scripts de monitoreo funcionando
- [ ] ✅ Puertos abriéndose correctamente
- [ ] ✅ Variables de entorno configuradas

### 🚀 Deploy y Versionado
- [ ] ✅ Primer commit realizado
- [ ] ✅ Tag inicial creado (v0.1)
- [ ] ✅ Pushed a GitHub
- [ ] ✅ Badge de Codespaces añadido al README

### 🔧 Configuración Avanzada (Opcional)
- [ ] ⏳ GitHub Actions configuradas
- [ ] ⏳ Tests automatizados
- [ ] ⏳ Pre-commit hooks
- [ ] ⏳ Docker/docker-compose
- [ ] ⏳ Secrets de GitHub configurados

---

## 🔧 Personalización Avanzada

### Añadir Nuevas Extensiones de VS Code
Edita `.devcontainer/devcontainer.json`:

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        // Extensiones existentes...
        "bradlc.vscode-tailwindcss",     // Tailwind CSS
        "ms-vscode.vscode-json",         // JSON tools
        "redhat.vscode-yaml",            // YAML support
        "ms-kubernetes-tools.vscode-kubernetes-tools" // Kubernetes
      ]
    }
  }
}
```

### Configurar Nuevos Puertos
```json
{
  "forwardPorts": [3000, 8000, 5000, 9000],
  "portsAttributes": {
    "3000": {"label": "Frontend Dev Server"},
    "8000": {"label": "API Server"}, 
    "5000": {"label": "Database"},
    "9000": {"label": "Admin Panel"}
  }
}
```

### Añadir Herramientas del Sistema
En `scripts/setup-codespaces.sh`:

```bash
# Instalar herramientas adicionales
sudo apt-get install -y \
    redis-server \
    postgresql-client \
    docker-compose \
    nginx
```

### Stack-Specific Customizations

#### Para React/Vue/Angular
```json
{
  "image": "mcr.microsoft.com/devcontainers/javascript-node:18-bullseye",
  "customizations": {
    "vscode": {
      "extensions": [
        "esbenp.prettier-vscode",
        "bradlc.vscode-tailwindcss",
        "ms-vscode.vscode-typescript-next"
      ]
    }
  },
  "postCreateCommand": "npm install && npm run build"
}
```

#### Para Django
```json
{
  "postCreateCommand": "pip install -r requirements.txt && python manage.py migrate",
  "forwardPorts": [8000, 5432],
  "features": {
    "ghcr.io/devcontainers/features/postgresql:1": {}
  }
}
```

#### Para FastAPI
```json
{
  "postCreateCommand": "pip install -r requirements.txt",
  "forwardPorts": [8000],
  "portsAttributes": {
    "8000": {
      "label": "FastAPI + Uvicorn",
      "onAutoForward": "notify"
    }
  }
}
```

### Añadir Base de Datos
```bash
# En scripts/setup-codespaces.sh
# Para PostgreSQL:
sudo apt-get install -y postgresql postgresql-contrib
sudo service postgresql start

# Para Redis:
sudo apt-get install -y redis-server
sudo service redis-server start
```

---

## 🆘 Troubleshooting

### Problemas Comunes

#### 1. Codespace no Inicia
**Síntoma**: Error al crear codespace o configuración fallida

**Soluciones**:
```bash
# Verificar sintaxis JSON:
jq . .devcontainer/devcontainer.json

# Verificar que scripts existen:
ls -la scripts/setup-codespaces.sh

# Revisar logs del postCreateCommand:
# (logs disponibles en la terminal de VS Code)
```

#### 2. Scripts no Son Ejecutables
**Síntoma**: `Permission denied` al ejecutar scripts

**Solución**:
```bash
# Hacer todos los scripts ejecutables:
find . -name "*.sh" -type f -exec chmod +x {} \;

# O individualmente:
chmod +x monitor-system.sh
chmod +x start-app.sh
```

#### 3. Puertos no se Abren
**Síntoma**: Aplicación no accesible desde el navegador

**Soluciones**:
```bash
# Verificar que la app escucha en 0.0.0.0:
# Cambiar de localhost a 0.0.0.0 en tu aplicación

# En Python:
app.run(host='0.0.0.0', port=8000)  # ✅ Correcto
app.run(host='127.0.0.1', port=8000)  # ❌ Solo local

# Verificar puertos configurados:
cat .devcontainer/devcontainer.json | grep -A 5 forwardPorts
```

#### 4. Dependencias no se Instalan
**Síntoma**: ModuleNotFoundError o comando no encontrado

**Soluciones**:
```bash
# Verificar que requirements.txt existe:
ls -la requirements.txt

# Instalar manualmente:
pip install -r requirements.txt

# Para Node.js:
npm install
```

#### 5. Monitor de Latencia no Funciona
**Síntoma**: Error en monitor-latency.sh

**Solución**:
```bash
# Verificar herramientas del sistema:
sudo apt-get update
sudo apt-get install -y htop iotop sysstat

# Verificar permisos:
chmod +x monitor-latency.sh
```

#### 6. Variables de Entorno no Disponibles
**Síntoma**: Aplicación no encuentra configuración

**Soluciones**:
```bash
# Crear .env desde template:
cp .env.example .env

# Configurar en Codespaces:
# Repo → Settings → Secrets and variables → Codespaces

# Verificar variables:
echo $PYTHONPATH
echo $ENVIRONMENT
```

#### 7. Setup Local Falla
**Síntoma**: setup-local.sh termina con error

**Soluciones**:
```bash
# Verificar Python:
python3 --version
which python3

# En Ubuntu/Debian:
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv

# En macOS:
brew install python3

# En Windows (WSL):
sudo apt-get install -y python3 python3-pip
```

### Debug de Configuración
Crea `debug-setup.sh` para diagnosticar problemas:

```bash
#!/bin/bash
echo "🔍 Diagnóstico de Configuración"
echo "================================"

echo "📍 Directorio actual: $(pwd)"
echo "🗂️  Archivos principales:"
ls -la | grep -E "(\.sh|\.json|\.md|requirements|package\.json)"

echo ""
echo "🔧 Herramientas del sistema:"
echo "Python: $(python3 --version 2>/dev/null || echo 'No instalado')"
echo "Node.js: $(node --version 2>/dev/null || echo 'No instalado')"
echo "Git: $(git --version 2>/dev/null || echo 'No instalado')"

echo ""
echo "🌐 Variables de entorno:"
echo "ENVIRONMENT: $ENVIRONMENT"
echo "PYTHONPATH: $PYTHONPATH"
echo "CODESPACE_NAME: $CODESPACE_NAME"

echo ""
echo "📊 Scripts de monitoreo:"
for script in monitor-*.sh benchmark-report.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "✅ $script (ejecutable)"
        else
            echo "⚠️  $script (no ejecutable)"
        fi
    else
        echo "❌ $script (no existe)"
    fi
done

echo ""
echo "🔍 Diagnóstico completado"
```

### Contacto y Soporte
Si encuentras problemas no cubiertos aquí:

1. **Revisar logs**: Busca en la terminal del Codespace o local
2. **Verificar documentación**: README.md y archivos de docs/
3. **Crear Issue**: En tu repositorio con detalles del error
4. **Comunidad**: Buscar en Stack Overflow o GitHub Discussions

---

## 🎯 Próximos Pasos

Una vez que tengas tu repositorio configurado:

### 1. **Desarrollo Inicial** 
- Implementa tu funcionalidad principal
- Añade tests básicos
- Documenta la API/funcionalidades

### 2. **CI/CD**
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run tests
        run: python -m pytest
```

### 3. **Optimización de Rendimiento**
- Usa las herramientas de monitoreo regularmente
- Optimiza basándote en los reportes generados
- Monitorea métricas en production

### 4. **Colaboración**
- Configura branch protection rules
- Añade templates para issues y PRs
- Establece guidelines de contribución

### 5. **Deploy**
- Configura deployment automático
- Añade environments (staging, production)
- Configura monitoring en producción

---

¡Tu nuevo repositorio con arquitectura dual está listo para el desarrollo! 🚀

Esta guía te ha proporcionado:
- ✅ **Estructura completa** del proyecto
- ✅ **Configuración dual** (Local + Codespaces)
- ✅ **Sistema de monitoreo** integrado
- ✅ **Documentación detallada**
- ✅ **Scripts automatizados** 
- ✅ **Troubleshooting** comprehensivo

**¿Siguiente paso?** ¡Empieza a desarrollar tu aplicación! 🎯
