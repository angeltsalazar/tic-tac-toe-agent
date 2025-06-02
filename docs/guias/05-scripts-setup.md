# ⚙️ 05 - Scripts de Setup y Ejecución

> **Objetivo**: Crear scripts automatizados que simplifiquen el setup, desarrollo y deployment del proyecto en cualquier entorno.

## 📋 Filosofía de Automatización

### Principios de Nuestros Scripts
- 🔄 **Idempotencia**: Ejecutar múltiples veces sin problemas
- 🎨 **UX Friendly**: Output colorido y claro
- 🖥️ **Cross-Platform**: Compatibilidad Windows/macOS/Linux
- 🔍 **Detección Inteligente**: Auto-detectar entorno y configuración
- 🛡️ **Error Handling**: Manejo robusto de errores

### Estructura de Scripts
```
scripts/
├── 📄 setup.sh           # Setup inicial completo
├── 📄 dev.sh             # Servidor de desarrollo
├── 📄 test.sh            # Ejecutar tests
├── 📄 build.sh           # Build para producción
├── 📄 deploy.sh          # Deployment
├── 📄 clean.sh           # Limpieza de archivos temporales
├── 📄 monitor.sh         # Monitoreo de recursos
└── 📂 utils/             # Utilidades compartidas
    ├── colors.sh         # Funciones de colores
    ├── detect-os.sh      # Detección de OS
    └── common.sh         # Funciones comunes
```

## 🛠️ Scripts Utilitarios Base

### 1. scripts/utils/colors.sh
```bash
mkdir -p scripts/utils
cat > scripts/utils/colors.sh << 'EOF'
#!/bin/bash
# Colores y estilos para scripts

# Colores básicos
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export NC='\033[0m' # No Color

# Estilos
export BOLD='\033[1m'
export DIM='\033[2m'
export UNDERLINE='\033[4m'
export BLINK='\033[5m'

# Iconos y símbolos
export CHECKMARK="✅"
export CROSS="❌"
export WARNING="⚠️"
export INFO="ℹ️"
export ROCKET="🚀"
export GEAR="⚙️"
export PACKAGE="📦"
export FOLDER="📁"
export FILE="📄"

# Funciones de logging
log_info() {
    echo -e "${BLUE}${INFO} ${1}${NC}"
}

log_success() {
    echo -e "${GREEN}${CHECKMARK} ${1}${NC}"
}

log_warning() {
    echo -e "${YELLOW}${WARNING} ${1}${NC}"
}

log_error() {
    echo -e "${RED}${CROSS} ${1}${NC}"
}

log_step() {
    echo -e "${CYAN}${ROCKET} ${1}${NC}"
}

# Función para headers
print_header() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title}) / 2 ))
    
    echo ""
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo -e "${BLUE}$(printf ' %.0s' $(seq 1 $padding))${BOLD}${title}${NC}${BLUE}$(printf ' %.0s' $(seq 1 $padding))${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo ""
}

# Función para separadores
print_separator() {
    echo -e "${DIM}$(printf '-%.0s' $(seq 1 60))${NC}"
}
EOF
```

### 2. scripts/utils/detect-os.sh
```bash
cat > scripts/utils/detect-os.sh << 'EOF'
#!/bin/bash
# Detección de sistema operativo y configuración

detect_os() {
    case "$(uname -s)" in
        Linux*)     export OS_TYPE="Linux";;
        Darwin*)    export OS_TYPE="macOS";;
        CYGWIN*)    export OS_TYPE="Windows";;
        MINGW*)     export OS_TYPE="Windows";;
        MSYS*)      export OS_TYPE="Windows";;
        *)          export OS_TYPE="Unknown";;
    esac
}

detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        export PKG_MANAGER="apt"
    elif command -v yum &> /dev/null; then
        export PKG_MANAGER="yum"
    elif command -v brew &> /dev/null; then
        export PKG_MANAGER="brew"
    elif command -v pacman &> /dev/null; then
        export PKG_MANAGER="pacman"
    else
        export PKG_MANAGER="unknown"
    fi
}

detect_shell() {
    export CURRENT_SHELL=$(basename "$SHELL")
}

detect_environment() {
    if [ -n "$CODESPACES" ]; then
        export ENV_TYPE="codespaces"
    elif [ -n "$REMOTE_CONTAINERS" ]; then
        export ENV_TYPE="devcontainer"
    elif [ -f /.dockerenv ]; then
        export ENV_TYPE="docker"
    else
        export ENV_TYPE="local"
    fi
}

# Función para mostrar información del sistema
show_system_info() {
    detect_os
    detect_package_manager
    detect_shell
    detect_environment
    
    log_info "Sistema detectado:"
    echo "  OS: $OS_TYPE"
    echo "  Package Manager: $PKG_MANAGER"
    echo "  Shell: $CURRENT_SHELL"
    echo "  Environment: $ENV_TYPE"
}
EOF
```

### 3. scripts/utils/common.sh
```bash
cat > scripts/utils/common.sh << 'EOF'
#!/bin/bash
# Funciones comunes para todos los scripts

# Source otros utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"
source "$SCRIPT_DIR/detect-os.sh"

# Verificar si comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Verificar si archivo existe
file_exists() {
    [ -f "$1" ]
}

# Verificar si directorio existe
dir_exists() {
    [ -d "$1" ]
}

# Crear directorio si no existe
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_success "Directorio creado: $1"
    fi
}

# Verificar y crear archivo .env desde .env.example
setup_env_file() {
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            log_success ".env creado desde .env.example"
            log_warning "Recuerda configurar las variables en .env"
        else
            log_warning ".env.example no encontrado"
        fi
    else
        log_info ".env ya existe"
    fi
}

# Verificar dependencias básicas
check_basic_deps() {
    local missing_deps=()
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if ! command_exists curl; then
        missing_deps+=("curl")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Dependencias faltantes: ${missing_deps[*]}"
        log_info "Instálalas antes de continuar"
        return 1
    fi
    
    return 0
}

# Función para hacer backup de archivos
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        log_info "Backup creado: $backup"
    fi
}

# Función para preguntar al usuario
ask_user() {
    local question="$1"
    local default="$2"
    
    if [ -n "$default" ]; then
        read -p "$question [$default]: " answer
        echo "${answer:-$default}"
    else
        read -p "$question: " answer
        echo "$answer"
    fi
}

# Función para confirmar acción
confirm_action() {
    local message="$1"
    local response
    
    read -p "$message (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Función para mostrar progreso
show_progress() {
    local current=$1
    local total=$2
    local message="$3"
    local percentage=$((current * 100 / total))
    
    echo -ne "\r${BLUE}[${percentage}%] ${message}${NC}"
    
    if [ $current -eq $total ]; then
        echo ""
    fi
}

# Cleanup function para traps
cleanup() {
    log_info "Limpiando archivos temporales..."
    # Agregar cleanup específico aquí
}

# Setup trap para cleanup
trap cleanup EXIT
EOF
```

## 🚀 Script Principal de Setup

### scripts/setup.sh (Versión Avanzada)
```bash
cat > scripts/setup.sh << 'EOF'
#!/bin/bash
# Setup inicial completo del proyecto

set -e  # Exit on any error

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/common.sh"

# Variables globales
PROJECT_NAME="mi-proyecto-dual"
VERSION="1.0.0"

# Función principal
main() {
    print_header "Setup: $PROJECT_NAME v$VERSION"
    
    # Detectar entorno
    detect_os
    detect_environment
    show_system_info
    print_separator
    
    # Verificar dependencias básicas
    log_step "Verificando dependencias básicas..."
    if ! check_basic_deps; then
        exit 1
    fi
    log_success "Dependencias básicas verificadas"
    
    # Setup específico según stack
    setup_stack_specific
    
    # Configurar archivos de entorno
    log_step "Configurando archivos de entorno..."
    setup_env_file
    
    # Crear directorios necesarios
    log_step "Creando estructura de directorios..."
    setup_directories
    
    # Configurar permisos
    log_step "Configurando permisos..."
    setup_permissions
    
    # Ejecutar tests básicos
    log_step "Ejecutando verificaciones..."
    run_basic_tests
    
    # Mostrar siguiente pasos
    show_next_steps
    
    log_success "Setup completado exitosamente!"
}

setup_stack_specific() {
    if file_exists "requirements.txt"; then
        setup_python
    elif file_exists "package.json"; then
        setup_nodejs
    else
        log_info "Stack no detectado automáticamente"
        setup_generic
    fi
}

setup_python() {
    log_step "Configurando entorno Python..."
    
    # Verificar Python
    if ! command_exists python3; then
        log_error "Python3 no está instalado"
        exit 1
    fi
    
    local python_version=$(python3 --version)
    log_info "Python detectado: $python_version"
    
    # Crear virtual environment si no existe
    if [ ! -d "venv" ] && [ "$ENV_TYPE" != "codespaces" ] && [ "$ENV_TYPE" != "devcontainer" ]; then
        log_step "Creando virtual environment..."
        python3 -m venv venv
        log_success "Virtual environment creado"
        
        log_info "Para activar el virtual environment:"
        echo "  source venv/bin/activate  # Linux/macOS"
        echo "  venv\\Scripts\\activate     # Windows"
    fi
    
    # Instalar dependencias
    if file_exists "requirements.txt"; then
        log_step "Instalando dependencias Python..."
        if [ -d "venv" ] && [ "$ENV_TYPE" == "local" ]; then
            source venv/bin/activate
        fi
        pip3 install --upgrade pip
        pip3 install -r requirements.txt
        log_success "Dependencias Python instaladas"
    fi
    
    # Instalar dependencias de desarrollo
    if file_exists "requirements-dev.txt"; then
        log_step "Instalando dependencias de desarrollo..."
        pip3 install -r requirements-dev.txt
        log_success "Dependencias de desarrollo instaladas"
    fi
}

setup_nodejs() {
    log_step "Configurando entorno Node.js..."
    
    # Verificar Node.js
    if ! command_exists node; then
        log_error "Node.js no está instalado"
        exit 1
    fi
    
    local node_version=$(node --version)
    log_info "Node.js detectado: $node_version"
    
    # Instalar dependencias
    if file_exists "package.json"; then
        log_step "Instalando dependencias Node.js..."
        npm install
        log_success "Dependencias Node.js instaladas"
    fi
    
    # Verificar package.json scripts
    if file_exists "package.json" && command_exists jq; then
        local scripts=$(jq -r '.scripts | keys[]' package.json 2>/dev/null || echo "")
        if [ -n "$scripts" ]; then
            log_info "Scripts npm disponibles:"
            echo "$scripts" | sed 's/^/  - /'
        fi
    fi
}

setup_generic() {
    log_info "Configuración genérica aplicada"
    log_warning "Considera agregar requirements.txt o package.json para setup automático"
}

setup_directories() {
    local dirs=("logs" "tmp" "uploads" "config" "assets")
    
    for dir in "${dirs[@]}"; do
        ensure_dir "$dir"
    done
}

setup_permissions() {
    # Hacer ejecutables todos los scripts
    chmod +x scripts/*.sh 2>/dev/null || true
    chmod +x .devcontainer/*.sh 2>/dev/null || true
    
    log_success "Permisos configurados"
}

run_basic_tests() {
    # Test básico de estructura
    local required_files=("README.md" ".gitignore")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if ! file_exists "$file"; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log_warning "Archivos recomendados faltantes: ${missing_files[*]}"
    else
        log_success "Archivos esenciales presentes"
    fi
    
    # Test de configuración git
    if command_exists git; then
        if git rev-parse --git-dir > /dev/null 2>&1; then
            log_success "Repositorio Git configurado"
        else
            log_warning "No es un repositorio Git"
        fi
    fi
}

show_next_steps() {
    print_separator
    log_info "Próximos pasos:"
    echo "  1. Configurar variables en .env"
    echo "  2. Ejecutar: ./scripts/dev.sh"
    echo "  3. Leer documentación en docs/"
    
    if file_exists "package.json"; then
        echo "  4. Ejecutar: npm run dev"
    elif file_exists "requirements.txt"; then
        echo "  4. Ejecutar: python app.py"
    fi
    
    print_separator
}

# Ejecutar función principal
main "$@"
EOF

chmod +x scripts/setup.sh
```

## 🛠️ Scripts de Desarrollo

### scripts/dev.sh (Servidor de Desarrollo)
```bash
cat > scripts/dev.sh << 'EOF'
#!/bin/bash
# Servidor de desarrollo con auto-detección

set -e

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/common.sh"

main() {
    print_header "Servidor de Desarrollo"
    
    # Verificar setup
    if [ ! -f ".env" ]; then
        log_warning "Archivo .env no encontrado"
        if confirm_action "¿Ejecutar setup primero?"; then
            ./scripts/setup.sh
        fi
    fi
    
    # Detectar stack y ejecutar
    detect_and_run
}

detect_and_run() {
    if file_exists "package.json"; then
        run_nodejs_dev
    elif file_exists "requirements.txt"; then
        run_python_dev
    elif file_exists "app.py"; then
        run_python_app
    elif file_exists "server.js"; then
        run_nodejs_server
    else
        log_error "No se pudo detectar el tipo de proyecto"
        show_manual_options
    fi
}

run_nodejs_dev() {
    log_step "Iniciando servidor Node.js..."
    
    # Verificar si existe script dev
    if command_exists jq && jq -e '.scripts.dev' package.json >/dev/null 2>&1; then
        log_info "Ejecutando: npm run dev"
        npm run dev
    elif jq -e '.scripts.start' package.json >/dev/null 2>&1; then
        log_info "Ejecutando: npm start"
        npm start
    else
        log_info "Ejecutando: node server.js"
        node server.js
    fi
}

run_python_dev() {
    log_step "Iniciando servidor Python..."
    
    # Activar virtual environment si existe
    if [ -d "venv" ] && [ "$ENV_TYPE" == "local" ]; then
        log_info "Activando virtual environment..."
        source venv/bin/activate
    fi
    
    # Buscar archivo principal
    if file_exists "app.py"; then
        run_python_app
    elif file_exists "main.py"; then
        log_info "Ejecutando: python main.py"
        python main.py
    elif file_exists "server.py"; then
        log_info "Ejecutando: python server.py"
        python server.py
    else
        log_error "No se encontró archivo principal Python"
        show_python_options
    fi
}

run_python_app() {
    # Detectar framework
    if grep -q "flask" requirements.txt 2>/dev/null; then
        log_info "Flask detectado"
        export FLASK_ENV=development
        export FLASK_DEBUG=1
        log_info "Ejecutando: python app.py"
        python app.py
    elif grep -q "fastapi" requirements.txt 2>/dev/null; then
        log_info "FastAPI detectado"
        if command_exists uvicorn; then
            log_info "Ejecutando: uvicorn app:app --reload"
            uvicorn app:app --reload --host 0.0.0.0 --port 8000
        else
            log_info "Ejecutando: python app.py"
            python app.py
        fi
    elif grep -q "django" requirements.txt 2>/dev/null; then
        log_info "Django detectado"
        if file_exists "manage.py"; then
            log_info "Ejecutando: python manage.py runserver"
            python manage.py runserver 0.0.0.0:8000
        fi
    else
        log_info "Ejecutando: python app.py"
        python app.py
    fi
}

show_manual_options() {
    log_info "Opciones manuales disponibles:"
    echo "  1. python app.py     (Para aplicaciones Python)"
    echo "  2. node server.js    (Para aplicaciones Node.js)"
    echo "  3. npm run dev       (Si tienes script dev)"
    echo "  4. npm start         (Si tienes script start)"
    
    local choice=$(ask_user "Selecciona una opción (1-4)" "1")
    
    case $choice in
        1) python app.py ;;
        2) node server.js ;;
        3) npm run dev ;;
        4) npm start ;;
        *) log_error "Opción inválida" ;;
    esac
}

show_python_options() {
    log_info "Archivos Python encontrados:"
    find . -name "*.py" -maxdepth 1 | head -5
    
    local file=$(ask_user "¿Qué archivo ejecutar?" "app.py")
    python "$file"
}

# Signal handling para cleanup
cleanup_dev() {
    log_info "Deteniendo servidor de desarrollo..."
    # Kill background processes if any
    jobs -p | xargs -r kill
    exit 0
}

trap cleanup_dev SIGINT SIGTERM

main "$@"
EOF

chmod +x scripts/dev.sh
```

### scripts/test.sh (Testing Automatizado)
```bash
cat > scripts/test.sh << 'EOF'
#!/bin/bash
# Testing automatizado con detección de framework

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/common.sh"

main() {
    print_header "Ejecutando Tests"
    
    detect_test_framework
}

detect_test_framework() {
    if file_exists "package.json"; then
        run_javascript_tests
    elif file_exists "requirements.txt" || file_exists "pytest.ini"; then
        run_python_tests
    else
        log_warning "Framework de testing no detectado"
        show_test_options
    fi
}

run_javascript_tests() {
    log_step "Ejecutando tests JavaScript/TypeScript..."
    
    if command_exists jq && jq -e '.scripts.test' package.json >/dev/null 2>&1; then
        log_info "Ejecutando: npm test"
        npm test
    elif command_exists jest; then
        log_info "Ejecutando: jest"
        jest
    elif dir_exists "test" || dir_exists "tests"; then
        log_info "Ejecutando tests con mocha..."
        npx mocha test/**/*.js || npx mocha tests/**/*.js
    else
        log_warning "No se encontraron tests configurados"
    fi
}

run_python_tests() {
    log_step "Ejecutando tests Python..."
    
    # Activar virtual environment si existe
    if [ -d "venv" ] && [ "$ENV_TYPE" == "local" ]; then
        source venv/bin/activate
    fi
    
    if command_exists pytest; then
        log_info "Ejecutando: pytest"
        pytest tests/ -v --tb=short
    elif command_exists python && [ -d "tests" ]; then
        log_info "Ejecutando tests con unittest..."
        python -m unittest discover tests
    else
        log_warning "No se encontró pytest ni tests/"
        log_info "Instala pytest: pip install pytest"
    fi
}

show_test_options() {
    log_info "Opciones de testing disponibles:"
    echo "  1. pytest tests/        (Python)"
    echo "  2. npm test             (Node.js)"
    echo "  3. jest                 (JavaScript)"
    echo "  4. python -m unittest   (Python unittest)"
    
    local choice=$(ask_user "Selecciona una opción (1-4)" "1")
    
    case $choice in
        1) pytest tests/ ;;
        2) npm test ;;
        3) jest ;;
        4) python -m unittest discover tests ;;
        *) log_error "Opción inválida" ;;
    esac
}

# Coverage report si está disponible
run_coverage() {
    if command_exists pytest; then
        log_step "Generando reporte de cobertura..."
        pytest --cov=src tests/ --cov-report=html
        log_success "Reporte generado en htmlcov/"
    fi
}

main "$@"

# Ejecutar coverage si se pasa como parámetro
if [ "$1" == "--coverage" ]; then
    run_coverage
fi
EOF

chmod +x scripts/test.sh
```

### scripts/build.sh (Build para Producción)
```bash
cat > scripts/build.sh << 'EOF'
#!/bin/bash
# Build para producción

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/common.sh"

BUILD_DIR="dist"
VERSION=$(date +%Y%m%d_%H%M%S)

main() {
    print_header "Build para Producción"
    
    # Limpiar build anterior
    clean_previous_build
    
    # Detectar stack y hacer build
    detect_and_build
    
    # Verificar build
    verify_build
    
    log_success "Build completado: $BUILD_DIR"
}

clean_previous_build() {
    if [ -d "$BUILD_DIR" ]; then
        log_step "Limpiando build anterior..."
        rm -rf "$BUILD_DIR"
    fi
    
    ensure_dir "$BUILD_DIR"
}

detect_and_build() {
    if file_exists "package.json"; then
        build_nodejs
    elif file_exists "requirements.txt"; then
        build_python
    else
        build_generic
    fi
}

build_nodejs() {
    log_step "Building aplicación Node.js..."
    
    # Install dependencies
    npm ci --only=production
    
    # Build si existe script
    if command_exists jq && jq -e '.scripts.build' package.json >/dev/null 2>&1; then
        log_info "Ejecutando: npm run build"
        npm run build
    fi
    
    # Copiar archivos necesarios
    cp -r node_modules "$BUILD_DIR/"
    cp package.json "$BUILD_DIR/"
    cp server.js "$BUILD_DIR/" 2>/dev/null || true
    
    if [ -d "public" ]; then
        cp -r public "$BUILD_DIR/"
    fi
}

build_python() {
    log_step "Building aplicación Python..."
    
    # Crear requirements.txt frozen
    if [ -d "venv" ]; then
        source venv/bin/activate
        pip freeze > "$BUILD_DIR/requirements.txt"
    else
        cp requirements.txt "$BUILD_DIR/"
    fi
    
    # Copiar código fuente
    cp -r src "$BUILD_DIR/" 2>/dev/null || true
    cp app.py "$BUILD_DIR/" 2>/dev/null || true
    cp main.py "$BUILD_DIR/" 2>/dev/null || true
    
    # Copiar archivos de configuración
    cp -r config "$BUILD_DIR/" 2>/dev/null || true
    cp .env.example "$BUILD_DIR/" 2>/dev/null || true
}

build_generic() {
    log_step "Build genérico..."
    
    # Copiar archivos esenciales
    local files_to_copy=("README.md" "LICENSE" ".env.example")
    
    for file in "${files_to_copy[@]}"; do
        if file_exists "$file"; then
            cp "$file" "$BUILD_DIR/"
        fi
    done
    
    # Copiar directorios comunes
    local dirs_to_copy=("src" "assets" "config")
    
    for dir in "${dirs_to_copy[@]}"; do
        if dir_exists "$dir"; then
            cp -r "$dir" "$BUILD_DIR/"
        fi
    done
}

verify_build() {
    log_step "Verificando build..."
    
    if [ ! -d "$BUILD_DIR" ]; then
        log_error "Directorio build no encontrado"
        exit 1
    fi
    
    local build_size=$(du -sh "$BUILD_DIR" | cut -f1)
    log_info "Tamaño del build: $build_size"
    
    log_success "Build verificado correctamente"
}

# Crear archivos adicionales para deployment
create_deployment_files() {
    # Dockerfile para producción
    cat > "$BUILD_DIR/Dockerfile" << 'EOL'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOL

    # docker-compose para producción
    cat > "$BUILD_DIR/docker-compose.prod.yml" << 'EOL'
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
EOL

    log_success "Archivos de deployment creados"
}

main "$@"

# Crear archivos de deployment si se solicita
if [ "$1" == "--with-docker" ]; then
    create_deployment_files
fi
EOF

chmod +x scripts/build.sh
```

## 🧹 Scripts de Mantenimiento

### scripts/clean.sh
```bash
cat > scripts/clean.sh << 'EOF'
#!/bin/bash
# Limpieza de archivos temporales y cache

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/common.sh"

main() {
    print_header "Limpieza de Proyecto"
    
    if [ "$1" == "--deep" ]; then
        deep_clean
    else
        standard_clean
    fi
}

standard_clean() {
    log_step "Limpieza estándar..."
    
    # Archivos temporales
    clean_temp_files
    
    # Logs antiguos
    clean_old_logs
    
    # Cache
    clean_cache
    
    log_success "Limpieza estándar completada"
}

deep_clean() {
    log_step "Limpieza profunda..."
    
    standard_clean
    
    # Dependencies
    clean_dependencies
    
    # Build artifacts
    clean_build_artifacts
    
    log_success "Limpieza profunda completada"
}

clean_temp_files() {
    log_info "Eliminando archivos temporales..."
    
    # Python
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyo" -delete 2>/dev/null || true
    
    # Node.js
    rm -rf .nyc_output 2>/dev/null || true
    rm -rf coverage 2>/dev/null || true
    
    # General
    rm -rf tmp/* 2>/dev/null || true
    rm -rf logs/*.log 2>/dev/null || true
    
    log_success "Archivos temporales eliminados"
}

clean_old_logs() {
    log_info "Eliminando logs antiguos (>7 días)..."
    
    if [ -d "logs" ]; then
        find logs -name "*.log" -mtime +7 -delete 2>/dev/null || true
    fi
    
    log_success "Logs antiguos eliminados"
}

clean_cache() {
    log_info "Limpiando cache..."
    
    # npm cache
    if command_exists npm; then
        npm cache clean --force 2>/dev/null || true
    fi
    
    # pip cache
    if command_exists pip; then
        pip cache purge 2>/dev/null || true
    fi
    
    log_success "Cache limpiado"
}

clean_dependencies() {
    if confirm_action "¿Eliminar node_modules y reinstalar dependencias?"; then
        rm -rf node_modules
        npm install
        log_success "Dependencias Node.js reinstaladas"
    fi
    
    if confirm_action "¿Recrear virtual environment Python?"; then
        rm -rf venv
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
        log_success "Virtual environment recreado"
    fi
}

clean_build_artifacts() {
    log_info "Eliminando artefactos de build..."
    
    rm -rf dist build *.egg-info 2>/dev/null || true
    
    log_success "Artefactos de build eliminados"
}

main "$@"
EOF

chmod +x scripts/clean.sh
```

## ❓ FAQ - Scripts de Setup

### P: ¿Los scripts funcionan en Windows?
**R**: Sí, pero necesitas Git Bash, WSL o un terminal compatible con bash. Para Windows puro, considera versiones PowerShell.

### P: ¿Puedo personalizar los colores y mensajes?
**R**: Sí, modifica `scripts/utils/colors.sh` para cambiar colores e iconos.

### P: ¿Cómo agregar soporte para otros frameworks?
**R**: Modifica las funciones de detección en cada script y agrega nuevas funciones específicas.

### P: ¿Los scripts son idempotentes?
**R**: Sí, puedes ejecutarlos múltiples veces sin problemas. Verifican estado antes de realizar acciones.

## ✅ Checklist de Scripts

- [ ] ✅ Utilities creados (colors.sh, detect-os.sh, common.sh)
- [ ] ✅ setup.sh con detección automática de stack
- [ ] ✅ dev.sh con auto-detección de servidor
- [ ] ✅ test.sh con soporte para múltiples frameworks
- [ ] ✅ build.sh para builds de producción
- [ ] ✅ clean.sh para mantenimiento
- [ ] ✅ Todos los scripts con permisos de ejecución
- [ ] ✅ Manejo de errores implementado
- [ ] ✅ Output colorido y user-friendly
- [ ] ✅ Scripts probados en el entorno objetivo

## ➡️ Siguiente Paso

Con los scripts de automatización listos, continúa con:
👉 **[06-sistema-monitoreo.md](06-sistema-monitoreo.md)** - Monitoreo de rendimiento y recursos
