# 🏗️ 03 - Estructura del Proyecto

> **Objetivo**: Crear una estructura de directorios y archivos organizada y escalable que soporte desarrollo dual.

## 📁 Estructura Base Recomendada

### Estructura Universal (Cualquier Stack)
```
mi-proyecto-dual/
├── 📂 .devcontainer/          # Configuración Dev Container
│   ├── devcontainer.json     # Configuración principal
│   ├── Dockerfile            # Imagen personalizada (opcional)
│   └── postCreateCommand.sh  # Script post-creación
├── 📂 .github/               # GitHub específico
│   ├── 📂 workflows/         # GitHub Actions
│   └── 📂 ISSUE_TEMPLATE/    # Templates de issues
├── 📂 .vscode/               # Configuración VS Code
│   ├── settings.json         # Settings del workspace
│   ├── extensions.json       # Extensiones recomendadas
│   ├── launch.json          # Configuración debug
│   └── tasks.json           # Tareas automatizadas
├── 📂 docs/                  # Documentación
│   ├── setup.md             # Guía de instalación
│   ├── development.md       # Guía de desarrollo
│   ├── deployment.md        # Guía de deployment
│   └── api.md               # Documentación API (si aplica)
├── 📂 scripts/               # Scripts de automatización
│   ├── setup.sh             # Setup inicial
│   ├── dev.sh               # Desarrollo local
│   ├── test.sh              # Ejecutar tests
│   └── deploy.sh            # Deployment
├── 📂 src/                   # Código fuente principal
├── 📂 tests/                 # Tests automatizados
├── 📂 assets/                # Recursos estáticos
├── 📂 config/                # Archivos de configuración
├── 📄 README.md              # Documentación principal
├── 📄 .gitignore             # Archivos ignorados por Git
├── 📄 .env.example           # Variables de entorno ejemplo
├── 📄 LICENSE                # Licencia del proyecto
└── 📄 CONTRIBUTING.md        # Guía de contribución
```

## 🐍 Estructura para Proyectos Python

### Estructura Completa Python
```
mi-proyecto-python/
├── 📂 .devcontainer/
├── 📂 .github/
├── 📂 .vscode/
├── 📂 docs/
├── 📂 scripts/
├── 📂 src/
│   ├── 📂 app/               # Aplicación principal
│   │   ├── __init__.py
│   │   ├── main.py          # Punto de entrada
│   │   ├── 📂 models/       # Modelos de datos
│   │   ├── 📂 views/        # Vistas/Controllers
│   │   ├── 📂 utils/        # Utilidades
│   │   └── 📂 config/       # Configuración app
│   └── 📂 shared/           # Código compartido
├── 📂 tests/
│   ├── 📂 unit/             # Tests unitarios
│   ├── 📂 integration/      # Tests de integración
│   └── conftest.py          # Configuración pytest
├── 📂 assets/
├── 📄 requirements.txt       # Dependencias pip
├── 📄 requirements-dev.txt   # Dependencias desarrollo
├── 📄 setup.py              # Setup del paquete
├── 📄 pyproject.toml        # Configuración moderna Python
├── 📄 app.py                # Punto de entrada principal
├── 📄 .env.example
├── 📄 .gitignore
└── 📄 README.md
```

### Crear Estructura Python
```bash
# Crear estructura de directorios
mkdir -p .devcontainer .github/workflows .vscode docs scripts
mkdir -p src/app/{models,views,utils,config} src/shared
mkdir -p tests/{unit,integration} assets config

# Crear archivos Python básicos
touch src/__init__.py
touch src/app/__init__.py
touch src/app/main.py
touch src/app/models/__init__.py
touch src/app/views/__init__.py
touch src/app/utils/__init__.py
touch src/app/config/__init__.py
touch src/shared/__init__.py
touch tests/__init__.py
touch tests/conftest.py
touch app.py

# Crear archivos de configuración Python
touch requirements.txt
touch requirements-dev.txt
touch setup.py
touch pyproject.toml
```

## 🟢 Estructura para Proyectos Node.js

### Estructura Completa Node.js
```
mi-proyecto-nodejs/
├── 📂 .devcontainer/
├── 📂 .github/
├── 📂 .vscode/
├── 📂 docs/
├── 📂 scripts/
├── 📂 src/
│   ├── 📂 controllers/      # Controladores
│   ├── 📂 models/           # Modelos de datos
│   ├── 📂 routes/           # Rutas API
│   ├── 📂 middleware/       # Middleware personalizado
│   ├── 📂 services/         # Lógica de negocio
│   ├── 📂 utils/            # Utilidades
│   ├── 📂 config/           # Configuración
│   └── app.js               # Aplicación principal
├── 📂 tests/
│   ├── 📂 unit/
│   ├── 📂 integration/
│   └── setup.js
├── 📂 public/               # Archivos estáticos
│   ├── 📂 css/
│   ├── 📂 js/
│   └── 📂 images/
├── 📄 package.json          # Dependencias npm
├── 📄 package-lock.json     # Lock de versiones
├── 📄 server.js             # Punto de entrada
├── 📄 .eslintrc.json        # Configuración ESLint
├── 📄 .prettierrc           # Configuración Prettier
├── 📄 jest.config.js        # Configuración Jest
├── 📄 .env.example
├── 📄 .gitignore
└── 📄 README.md
```

### Crear Estructura Node.js
```bash
# Crear estructura de directorios
mkdir -p .devcontainer .github/workflows .vscode docs scripts
mkdir -p src/{controllers,models,routes,middleware,services,utils,config}
mkdir -p tests/{unit,integration}
mkdir -p public/{css,js,images}

# Crear archivos básicos
touch src/app.js
touch src/controllers/index.js
touch src/models/index.js
touch src/routes/index.js
touch src/config/index.js
touch tests/setup.js
touch server.js

# Inicializar npm
npm init -y

# Crear archivos de configuración
touch .eslintrc.json
touch .prettierrc
touch jest.config.js
```

## 🌐 Estructura para Proyectos Full-Stack

### Estructura Completa Full-Stack
```
mi-proyecto-fullstack/
├── 📂 .devcontainer/
├── 📂 .github/
├── 📂 .vscode/
├── 📂 docs/
├── 📂 scripts/
├── 📂 backend/              # API/Server
│   ├── 📂 src/
│   ├── 📂 tests/
│   ├── package.json         # o requirements.txt
│   └── server.js            # o app.py
├── 📂 frontend/             # Cliente web
│   ├── 📂 src/
│   ├── 📂 public/
│   ├── 📂 tests/
│   └── package.json
├── 📂 shared/               # Código compartido
│   ├── 📂 types/            # TypeScript types
│   ├── 📂 utils/            # Utilidades compartidas
│   └── 📂 constants/        # Constantes globales
├── 📂 database/             # Esquemas y migraciones
│   ├── 📂 migrations/
│   ├── 📂 seeds/
│   └── schema.sql
├── 📂 docker/               # Configuraciones Docker
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   └── docker-compose.yml
├── 📄 .env.example
├── 📄 .gitignore
└── 📄 README.md
```

## 📋 Crear Archivos Base Esenciales

### 1. README.md Básico
```bash
cat > README.md << 'EOF'
# 🚀 Mi Proyecto Dual

> [Descripción breve del proyecto]

## ⚡ Quick Start

### 🌐 GitHub Codespaces
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tu-usuario/mi-proyecto-dual)

### 💻 Desarrollo Local
```bash
git clone https://github.com/tu-usuario/mi-proyecto-dual.git
cd mi-proyecto-dual
./scripts/setup.sh
```

## 🛠️ Stack Tecnológico

- **[Lenguaje]**: [Versión]
- **[Framework]**: [Versión]
- **DevOps**: Docker, GitHub Codespaces, VS Code Dev Containers

## 📚 Documentación

- [📖 Setup](docs/setup.md)
- [🛠️ Development](docs/development.md)
- [🚀 Deployment](docs/deployment.md)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Ver [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 Licencia

[MIT](LICENSE)
EOF
```

### 2. .env.example
```bash
cat > .env.example << 'EOF'
# Configuración de la aplicación
APP_NAME=mi-proyecto-dual
APP_ENV=development
APP_DEBUG=true
APP_PORT=3000

# Base de datos (si aplica)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mi_proyecto_db
DB_USER=usuario
DB_PASSWORD=password

# APIs externas (ejemplos)
API_KEY=tu_api_key_aqui
SECRET_TOKEN=tu_secret_token_aqui

# URLs y endpoints
BASE_URL=http://localhost:3000
API_URL=http://localhost:3000/api

# Logging
LOG_LEVEL=info
LOG_FILE=logs/app.log
EOF
```

### 3. .gitignore Mejorado
```bash
# Agregar reglas adicionales al .gitignore existente
cat >> .gitignore << 'EOF'

# Archivos específicos del proyecto
.env
*.local
.DS_Store
Thumbs.db

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Dependency directories
node_modules/
venv/
env/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Next.js build output
.next
out

# Nuxt.js build / generate output
.nuxt
dist

# Storybook build outputs
.out
.storybook-out

# Temporary folders
tmp/
temp/

# Editor directories and files
.vscode/settings.json
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOF
```

### 4. CONTRIBUTING.md
```bash
cat > CONTRIBUTING.md << 'EOF'
# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir al proyecto!

## 🚀 Quick Start para Contribuidores

1. **Fork** el repositorio
2. **Clone** tu fork
3. **Crea** una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`
4. **Desarrolla** usando GitHub Codespaces o localmente
5. **Commit** tus cambios: `git commit -m "Add: nueva funcionalidad"`
6. **Push** a tu fork: `git push origin feature/nueva-funcionalidad`
7. **Crea** un Pull Request

## 📋 Estándares de Código

### Commits
Usar [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` nueva funcionalidad
- `fix:` corrección de bug
- `docs:` cambios en documentación
- `style:` cambios de formato
- `refactor:` refactoring de código
- `test:` agregar o modificar tests

### Código
- Seguir las convenciones del lenguaje
- Incluir tests para nuevas funcionalidades
- Documentar funciones públicas
- Mantener cobertura de tests > 80%

## 🧪 Testing

```bash
# Ejecutar tests
./scripts/test.sh

# Verificar cobertura
./scripts/coverage.sh
```

## 📚 Documentación

- Actualizar docs/ si es necesario
- Incluir ejemplos en README.md
- Documentar APIs nuevas

## ❓ Preguntas

¿Dudas? Abre un [Issue](../../issues) o contacta a los maintainers.
EOF
```

## 📂 Scripts de Automatización Iniciales

### 1. scripts/setup.sh
```bash
mkdir -p scripts
cat > scripts/setup.sh << 'EOF'
#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setup inicial del proyecto${NC}"
echo "=================================="

# Detectar OS
OS=$(uname -s)
echo -e "${YELLOW}📱 Sistema detectado: $OS${NC}"

# Verificar dependencias
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✅ Python3 encontrado${NC}"
    PYTHON_VERSION=$(python3 --version)
    echo -e "${BLUE}   Versión: $PYTHON_VERSION${NC}"
fi

if command -v node &> /dev/null; then
    echo -e "${GREEN}✅ Node.js encontrado${NC}"
    NODE_VERSION=$(node --version)
    echo -e "${BLUE}   Versión: $NODE_VERSION${NC}"
fi

# Crear directorios necesarios
echo -e "${YELLOW}📁 Creando directorios...${NC}"
mkdir -p logs tmp uploads

# Copiar variables de entorno
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ .env creado desde .env.example${NC}"
        echo -e "${YELLOW}⚠️  Recuerda configurar las variables en .env${NC}"
    fi
fi

echo "=================================="
echo -e "${GREEN}🎉 Setup completado${NC}"
echo -e "${BLUE}📖 Próximos pasos:${NC}"
echo "   1. Configurar variables en .env"
echo "   2. Ejecutar ./scripts/dev.sh para desarrollo"
echo "   3. Ver docs/development.md para más información"
EOF

chmod +x scripts/setup.sh
```

### 2. scripts/dev.sh (Template)
```bash
cat > scripts/dev.sh << 'EOF'
#!/bin/bash

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛠️  Iniciando modo desarrollo${NC}"

# Verificar .env
if [ ! -f .env ]; then
    echo "❌ Archivo .env no encontrado"
    echo "💡 Ejecuta ./scripts/setup.sh primero"
    exit 1
fi

# TODO: Agregar comandos específicos del stack
# Para Python: source venv/bin/activate && python app.py
# Para Node.js: npm run dev
# Para otros: comandos específicos

echo -e "${GREEN}🎉 Servidor en desarrollo iniciado${NC}"
EOF

chmod +x scripts/dev.sh
```

## 🧪 Verificación de Estructura

### Script de Verificación
```bash
cat > scripts/verify-structure.sh << 'EOF'
#!/bin/bash

echo "🔍 Verificando estructura del proyecto..."
echo "========================================"

# Directorios esenciales
directories=(".devcontainer" ".vscode" "docs" "scripts" "src" "tests")
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir/"
    else
        echo "❌ $dir/ (faltante)"
    fi
done

# Archivos esenciales
files=("README.md" ".gitignore" ".env.example" "CONTRIBUTING.md")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (faltante)"
    fi
done

echo "========================================"
echo "🎉 Verificación completada"
EOF

chmod +x scripts/verify-structure.sh
```

### Ejecutar Verificación
```bash
./scripts/verify-structure.sh
```

## ❓ FAQ - Estructura del Proyecto

### P: ¿Debo seguir exactamente esta estructura?
**R**: Es un punto de partida recomendado. Puedes adaptarla según las necesidades de tu proyecto.

### P: ¿Qué va en src/ vs. qué va en la raíz?
**R**: 
- **src/**: Código fuente de la aplicación
- **Raíz**: Archivos de configuración, documentación, scripts

### P: ¿Es necesario crear todos los directorios desde el inicio?
**R**: Crea los básicos (.devcontainer, .vscode, docs, scripts, src, tests) y agrega otros según necesidad.

### P: ¿Cómo organizar un monorepo?
**R**: Para monorepos, usar la estructura Full-Stack como base y agregar más subdirectorios según servicios.

## ✅ Checklist de Estructura

- [ ] ✅ Directorios principales creados
- [ ] ✅ README.md inicial creado
- [ ] ✅ .env.example configurado
- [ ] ✅ .gitignore actualizado
- [ ] ✅ CONTRIBUTING.md creado
- [ ] ✅ Scripts básicos creados y ejecutables
- [ ] ✅ Estructura verificada con script
- [ ] ✅ Archivos base del stack específico creados

## ➡️ Siguiente Paso

Con la estructura base creada, continúa con:
👉 **[04-dev-container.md](04-dev-container.md)** - Configuración completa de Dev Container
