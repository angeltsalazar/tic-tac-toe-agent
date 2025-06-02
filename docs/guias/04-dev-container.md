# 🐳 04 - Configuración de Dev Container

> **Objetivo**: Configurar un entorno de desarrollo containerizado que funcione tanto localmente como en GitHub Codespaces.

## 📋 Introducción a Dev Containers

### ¿Qué son los Dev Containers?
Los Dev Containers proporcionan un entorno de desarrollo completamente configurado usando Docker, permitiendo:
- ✅ **Consistencia**: Mismo entorno para todos los desarrolladores
- ✅ **Aislamiento**: No afecta tu sistema local
- ✅ **Portabilidad**: Funciona local y en Codespaces
- ✅ **Reproducibilidad**: Configuración versionada

### Ventajas de Nuestra Arquitectura Dual
- 🔄 **Flexibilidad**: Desarrollo local o en la nube
- 🚀 **Velocidad**: Setup instantáneo para nuevos desarrolladores
- 🔒 **Seguridad**: Entorno aislado y controlado
- 📈 **Escalabilidad**: Recursos cloud cuando necesites

## 🏗️ Estructura de .devcontainer/

```
.devcontainer/
├── 📄 devcontainer.json      # Configuración principal
├── 📄 Dockerfile            # Imagen personalizada (opcional)
├── 📄 postCreateCommand.sh   # Script post-creación
└── 📄 docker-compose.yml    # Para servicios múltiples (opcional)
```

## 🐍 Configuración para Python

### 1. devcontainer.json para Python
```bash
cat > .devcontainer/devcontainer.json << 'EOF'
{
    "name": "Python Dev Container",
    "image": "mcr.microsoft.com/devcontainers/python:0-3.11",
    
    // Configuración de features
    "features": {
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/devcontainers/features/github-cli:1": {},
        "ghcr.io/devcontainers/features/docker-in-docker:2": {}
    },
    
    // VS Code customizations
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-python.python",
                "ms-python.vscode-pylance",
                "ms-python.flake8",
                "ms-python.black-formatter",
                "ms-toolsai.jupyter",
                "ms-vscode.vscode-json",
                "GitHub.copilot",
                "GitHub.copilot-chat",
                "ms-vscode.live-share",
                "eamodio.gitlens"
            ],
            "settings": {
                "python.defaultInterpreterPath": "/usr/local/bin/python",
                "python.linting.enabled": true,
                "python.linting.flake8Enabled": true,
                "python.formatting.provider": "black",
                "python.formatting.blackArgs": ["--line-length", "88"],
                "python.testing.pytestEnabled": true,
                "files.autoSave": "afterDelay",
                "files.autoSaveDelay": 1000,
                "terminal.integrated.defaultProfile.linux": "bash"
            }
        }
    },
    
    // Port forwarding
    "forwardPorts": [8000, 5000, 3000],
    "portsAttributes": {
        "8000": {
            "label": "App Port",
            "onAutoForward": "notify"
        }
    },
    
    // Environment variables
    "containerEnv": {
        "PYTHONPATH": "${containerWorkspaceFolder}/src",
        "ENVIRONMENT": "development"
    },
    
    // Post-create commands
    "postCreateCommand": ".devcontainer/postCreateCommand.sh",
    
    // Mount source code
    "mounts": [
        "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached"
    ],
    
    // User configuration
    "remoteUser": "vscode",
    "workspaceFolder": "/workspace",
    
    // Lifecycle scripts
    "onCreateCommand": "echo '🚀 Container created!'",
    "updateContentCommand": "pip install -r requirements.txt",
    "postAttachCommand": "echo '🎉 Welcome to your Python dev environment!'"
}
EOF
```

### 2. postCreateCommand.sh para Python
```bash
cat > .devcontainer/postCreateCommand.sh << 'EOF'
#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Configurando entorno Python...${NC}"

# Actualizar pip
echo -e "${YELLOW}📦 Actualizando pip...${NC}"
python -m pip install --upgrade pip

# Instalar dependencias si existe requirements.txt
if [ -f "requirements.txt" ]; then
    echo -e "${YELLOW}📦 Instalando dependencias desde requirements.txt...${NC}"
    pip install -r requirements.txt
fi

# Instalar dependencias de desarrollo si existe
if [ -f "requirements-dev.txt" ]; then
    echo -e "${YELLOW}📦 Instalando dependencias de desarrollo...${NC}"
    pip install -r requirements-dev.txt
fi

# Configurar pre-commit hooks si existe .pre-commit-config.yaml
if [ -f ".pre-commit-config.yaml" ]; then
    echo -e "${YELLOW}🔧 Configurando pre-commit hooks...${NC}"
    pip install pre-commit
    pre-commit install
fi

# Crear directorios necesarios
mkdir -p logs tmp

# Configurar permisos
chmod +x scripts/*.sh 2>/dev/null || true

# Verificar instalación
echo -e "${GREEN}✅ Python version: $(python --version)${NC}"
echo -e "${GREEN}✅ Pip version: $(pip --version)${NC}"

echo -e "${GREEN}🎉 Entorno Python configurado correctamente!${NC}"
echo -e "${BLUE}📖 Próximos pasos:${NC}"
echo "   1. Configurar variables en .env"
echo "   2. Ejecutar: python app.py"
echo "   3. Abrir http://localhost:8000"
EOF

chmod +x .devcontainer/postCreateCommand.sh
```

### 3. Dockerfile personalizado para Python (Opcional)
```bash
cat > .devcontainer/Dockerfile << 'EOF'
FROM mcr.microsoft.com/devcontainers/python:0-3.11

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    tree \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Instalar herramientas Python adicionales
RUN pip install --upgrade pip \
    && pip install \
        black \
        flake8 \
        pytest \
        pytest-cov \
        jupyter \
        ipython \
        requests \
        python-dotenv

# Configurar usuario
ARG USERNAME=vscode
USER $USERNAME

# Configurar bashrc
RUN echo 'alias ll="ls -la"' >> /home/$USERNAME/.bashrc \
    && echo 'alias ..="cd .."' >> /home/$USERNAME/.bashrc \
    && echo 'export PYTHONPATH="${PYTHONPATH}:/workspace/src"' >> /home/$USERNAME/.bashrc

WORKDIR /workspace
EOF
```

## 🟢 Configuración para Node.js

### 1. devcontainer.json para Node.js
```bash
cat > .devcontainer/devcontainer.json << 'EOF'
{
    "name": "Node.js Dev Container",
    "image": "mcr.microsoft.com/devcontainers/javascript-node:0-18",
    
    "features": {
        "ghcr.io/devcontainers/features/git:1": {},
        "ghcr.io/devcontainers/features/github-cli:1": {},
        "ghcr.io/devcontainers/features/docker-in-docker:2": {}
    },
    
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.vscode-typescript-next",
                "esbenp.prettier-vscode",
                "dbaeumer.vscode-eslint",
                "bradlc.vscode-tailwindcss",
                "ms-vscode.vscode-json",
                "GitHub.copilot",
                "GitHub.copilot-chat",
                "ms-vscode.live-share",
                "eamodio.gitlens",
                "formulahendry.auto-rename-tag",
                "christian-kohler.path-intellisense"
            ],
            "settings": {
                "editor.defaultFormatter": "esbenp.prettier-vscode",
                "editor.formatOnSave": true,
                "editor.codeActionsOnSave": {
                    "source.fixAll.eslint": true
                },
                "typescript.preferences.importModuleSpecifier": "relative",
                "javascript.preferences.importModuleSpecifier": "relative",
                "files.autoSave": "afterDelay",
                "files.autoSaveDelay": 1000
            }
        }
    },
    
    "forwardPorts": [3000, 3001, 8080, 5173],
    "portsAttributes": {
        "3000": {
            "label": "App Server",
            "onAutoForward": "notify"
        },
        "3001": {
            "label": "Dev Server",
            "onAutoForward": "silent"
        }
    },
    
    "containerEnv": {
        "NODE_ENV": "development"
    },
    
    "postCreateCommand": ".devcontainer/postCreateCommand.sh",
    
    "mounts": [
        "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached"
    ],
    
    "remoteUser": "node",
    "workspaceFolder": "/workspace",
    
    "onCreateCommand": "echo '🚀 Node.js container created!'",
    "updateContentCommand": "npm install",
    "postAttachCommand": "echo '🎉 Welcome to your Node.js dev environment!'"
}
EOF
```

### 2. postCreateCommand.sh para Node.js
```bash
cat > .devcontainer/postCreateCommand.sh << 'EOF'
#!/bin/bash

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🟢 Configurando entorno Node.js...${NC}"

# Verificar Node.js y npm
echo -e "${GREEN}✅ Node.js version: $(node --version)${NC}"
echo -e "${GREEN}✅ npm version: $(npm --version)${NC}"

# Instalar dependencias si existe package.json
if [ -f "package.json" ]; then
    echo -e "${YELLOW}📦 Instalando dependencias desde package.json...${NC}"
    npm install
fi

# Instalar herramientas globales útiles
echo -e "${YELLOW}🛠️ Instalando herramientas globales...${NC}"
npm install -g \
    nodemon \
    concurrently \
    http-server \
    prettier \
    eslint

# Configurar git hooks si existe husky
if [ -f "package.json" ] && grep -q "husky" package.json; then
    echo -e "${YELLOW}🔧 Configurando husky hooks...${NC}"
    npx husky install
fi

# Crear directorios necesarios
mkdir -p logs tmp public/uploads

# Configurar permisos
chmod +x scripts/*.sh 2>/dev/null || true

echo -e "${GREEN}🎉 Entorno Node.js configurado correctamente!${NC}"
echo -e "${BLUE}📖 Próximos pasos:${NC}"
echo "   1. Configurar variables en .env"
echo "   2. Ejecutar: npm run dev"
echo "   3. Abrir http://localhost:3000"
EOF

chmod +x .devcontainer/postCreateCommand.sh
```

## 🌐 Configuración Full-Stack

### devcontainer.json Full-Stack con Docker Compose
```bash
cat > .devcontainer/devcontainer.json << 'EOF'
{
    "name": "Full-Stack Dev Container",
    "dockerComposeFile": "docker-compose.yml",
    "service": "app",
    "workspaceFolder": "/workspace",
    
    "customizations": {
        "vscode": {
            "extensions": [
                // Python
                "ms-python.python",
                "ms-python.vscode-pylance",
                // JavaScript/TypeScript
                "ms-vscode.vscode-typescript-next",
                "esbenp.prettier-vscode",
                "dbaeumer.vscode-eslint",
                // Database
                "ms-mssql.mssql",
                "mtxr.sqltools",
                // General
                "ms-vscode.vscode-json",
                "GitHub.copilot",
                "GitHub.copilot-chat",
                "ms-vscode.live-share",
                "eamodio.gitlens"
            ],
            "settings": {
                "python.defaultInterpreterPath": "/usr/local/bin/python",
                "editor.defaultFormatter": "esbenp.prettier-vscode",
                "editor.formatOnSave": true,
                "files.autoSave": "afterDelay"
            }
        }
    },
    
    "forwardPorts": [3000, 8000, 5432, 6379],
    "portsAttributes": {
        "3000": {"label": "Frontend"},
        "8000": {"label": "Backend API"},
        "5432": {"label": "PostgreSQL"},
        "6379": {"label": "Redis"}
    },
    
    "postCreateCommand": ".devcontainer/postCreateCommand.sh",
    "remoteUser": "vscode"
}
EOF
```

### docker-compose.yml para Full-Stack
```bash
cat > .devcontainer/docker-compose.yml << 'EOF'
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ../..:/workspace:cached
    command: sleep infinity
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    ports:
      - "3000:3000"
      - "8000:8000"

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
EOF
```

## ⚙️ Configuración de VS Code

### 1. .vscode/settings.json
```bash
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
    // Editor
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "editor.detectIndentation": false,
    "editor.formatOnSave": true,
    "editor.formatOnPaste": true,
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    
    // Python specific
    "python.defaultInterpreterPath": "/usr/local/bin/python",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "black",
    "python.testing.pytestEnabled": true,
    "python.analysis.autoImportCompletions": true,
    
    // JavaScript/TypeScript specific
    "typescript.preferences.importModuleSpecifier": "relative",
    "javascript.preferences.importModuleSpecifier": "relative",
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    
    // Terminal
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.fontSize": 14,
    
    // Git
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "git.autofetch": true,
    
    // Search
    "search.exclude": {
        "**/node_modules": true,
        "**/venv": true,
        "**/.git": true,
        "**/dist": true,
        "**/build": true,
        "**/__pycache__": true,
        "**/*.pyc": true
    },
    
    // Files associations
    "files.associations": {
        "*.env": "plaintext",
        "Dockerfile*": "dockerfile",
        "*.yml": "yaml",
        "*.yaml": "yaml"
    }
}
EOF
```

### 2. .vscode/extensions.json
```bash
cat > .vscode/extensions.json << 'EOF'
{
    "recommendations": [
        // Essential
        "ms-vscode-remote.remote-containers",
        "ms-vscode.vscode-json",
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "ms-vscode.live-share",
        "eamodio.gitlens",
        
        // Python
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.flake8",
        "ms-python.black-formatter",
        "ms-toolsai.jupyter",
        
        // JavaScript/TypeScript
        "ms-vscode.vscode-typescript-next",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "bradlc.vscode-tailwindcss",
        
        // Web Development
        "formulahendry.auto-rename-tag",
        "christian-kohler.path-intellisense",
        "ritwickdey.LiveServer",
        
        // Database
        "ms-mssql.mssql",
        "mtxr.sqltools",
        
        // Docker
        "ms-azuretools.vscode-docker",
        
        // Productivity
        "ms-vscode.vscode-todo-highlight",
        "streetsidesoftware.code-spell-checker"
    ]
}
EOF
```

### 3. .vscode/launch.json
```bash
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
            "program": "app.py",
            "env": {
                "FLASK_ENV": "development",
                "FLASK_DEBUG": "1"
            },
            "console": "integratedTerminal",
            "justMyCode": true
        },
        {
            "name": "Node.js: Launch Program",
            "type": "node",
            "request": "launch",
            "program": "${workspaceFolder}/server.js",
            "env": {
                "NODE_ENV": "development"
            },
            "console": "integratedTerminal"
        },
        {
            "name": "Node.js: Attach",
            "type": "node",
            "request": "attach",
            "port": 9229,
            "restart": true,
            "localRoot": "${workspaceFolder}",
            "remoteRoot": "/workspace"
        }
    ]
}
EOF
```

### 4. .vscode/tasks.json
```bash
cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Setup Project",
            "type": "shell",
            "command": "./scripts/setup.sh",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "Run Development Server",
            "type": "shell",
            "command": "./scripts/dev.sh",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "Run Tests",
            "type": "shell",
            "command": "./scripts/test.sh",
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "Python: Install Requirements",
            "type": "shell",
            "command": "pip",
            "args": ["install", "-r", "requirements.txt"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always"
            }
        },
        {
            "label": "Node.js: Install Dependencies",
            "type": "shell",
            "command": "npm",
            "args": ["install"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always"
            }
        }
    ]
}
EOF
```

## 🧪 Testing y Validación

### Script de Validación del Dev Container
```bash
cat > scripts/validate-devcontainer.sh << 'EOF'
#!/bin/bash

echo "🔍 Validando configuración de Dev Container..."
echo "==============================================="

# Verificar archivos de configuración
configs=(
    ".devcontainer/devcontainer.json"
    ".devcontainer/postCreateCommand.sh"
    ".vscode/settings.json"
    ".vscode/extensions.json"
)

for config in "${configs[@]}"; do
    if [ -f "$config" ]; then
        echo "✅ $config"
    else
        echo "❌ $config (faltante)"
    fi
done

# Verificar permisos
if [ -x ".devcontainer/postCreateCommand.sh" ]; then
    echo "✅ postCreateCommand.sh tiene permisos de ejecución"
else
    echo "⚠️ postCreateCommand.sh no tiene permisos de ejecución"
fi

# Validar JSON syntax
echo "🔍 Validando sintaxis JSON..."
if command -v jq &> /dev/null; then
    for json_file in ".devcontainer/devcontainer.json" ".vscode/settings.json" ".vscode/extensions.json" ".vscode/launch.json" ".vscode/tasks.json"; do
        if [ -f "$json_file" ]; then
            if jq empty "$json_file" 2>/dev/null; then
                echo "✅ $json_file - JSON válido"
            else
                echo "❌ $json_file - JSON inválido"
            fi
        fi
    done
else
    echo "⚠️ jq no está instalado, saltando validación de JSON"
fi

echo "==============================================="
echo "🎉 Validación completada"
EOF

chmod +x scripts/validate-devcontainer.sh
```

## ❓ FAQ - Dev Containers

### P: ¿El Dev Container funciona sin Docker Desktop?
**R**: En Codespaces sí. Para desarrollo local necesitas Docker Desktop o una alternativa como Podman.

### P: ¿Puedo usar múltiples versiones de Python/Node?
**R**: Sí, puedes especificar versiones exactas en la imagen base o usar herramientas como pyenv/nvm en el Dockerfile.

### P: ¿Cómo comparto archivos entre host y container?
**R**: Los archivos del workspace se montan automáticamente. Para otros directorios, usa mounts en devcontainer.json.

### P: ¿Qué pasa con las extensiones de VS Code?
**R**: Se instalan automáticamente según la configuración en customizations.vscode.extensions.

## ✅ Checklist de Dev Container

- [ ] ✅ devcontainer.json creado y configurado
- [ ] ✅ postCreateCommand.sh creado y ejecutable
- [ ] ✅ Configuración de VS Code completa (.vscode/)
- [ ] ✅ Extensions.json con extensiones necesarias
- [ ] ✅ Settings.json optimizado para el stack
- [ ] ✅ Launch.json para debugging configurado
- [ ] ✅ Tasks.json con tareas automatizadas
- [ ] ✅ Dockerfile personalizado (si necesario)
- [ ] ✅ Script de validación ejecutado exitosamente
- [ ] ✅ Container probado localmente o en Codespaces

## ➡️ Siguiente Paso

Con el Dev Container configurado, continúa con:
👉 **[05-scripts-setup.md](05-scripts-setup.md)** - Scripts de automatización y ejecución
