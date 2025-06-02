# ☁️ Guía 08: Configuración de GitHub Codespaces

> **Objetivo:** Configurar GitHub Codespaces para desarrollo inmediato en la nube sin configuración local.

---

## 📑 Tabla de Contenidos

1. [¿Qué es GitHub Codespaces?](#qué-es-github-codespaces)
2. [Configuración Básica](#configuración-básica)
3. [Configuración Avanzada](#configuración-avanzada)
4. [Templates por Stack](#templates-por-stack)
5. [Optimización de Performance](#optimización-de-performance)
6. [Gestión de Recursos](#gestión-de-recursos)
7. [Troubleshooting](#troubleshooting)
8. [Checklist](#checklist)

---

## ☁️ ¿Qué es GitHub Codespaces?

GitHub Codespaces proporciona un entorno de desarrollo completo en la nube basado en VS Code, permitiendo:

### ✨ Beneficios
- 🚀 **Desarrollo inmediato:** Sin instalación local
- 🔄 **Consistencia:** Mismo entorno para todo el equipo
- 💰 **Costo-efectivo:** Paga solo por uso
- 🌐 **Acceso global:** Desde cualquier dispositivo
- 🔒 **Seguridad:** Datos en repositorio privado

### 📊 Especificaciones Disponibles
- **2 cores, 8 GB RAM, 32 GB storage** (Gratis: 60h/mes)
- **4 cores, 16 GB RAM, 32 GB storage** 
- **8 cores, 32 GB RAM, 64 GB storage**
- **16 cores, 64 GB RAM, 128 GB storage**
- **32 cores, 128 GB RAM, 256 GB storage**

---

## ⚙️ Configuración Básica

### 1. Estructura de Archivos

```
.devcontainer/
├── devcontainer.json         # Configuración principal
├── Dockerfile                # Imagen personalizada (opcional)
├── docker-compose.yml        # Multi-container (opcional)
└── scripts/
    ├── postCreateCommand.sh   # Script post-creación
    └── onCreateCommand.sh     # Script inicial
```

### 2. devcontainer.json Básico

```json
{
  "name": "Mi Proyecto",
  "image": "mcr.microsoft.com/devcontainers/universal:2",
  
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "18"
    },
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.11"
    },
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-vscode.vscode-typescript-next",
        "esbenp.prettier-vscode",
        "ms-vscode.vscode-eslint",
        "bradlc.vscode-tailwindcss"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash",
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
          "source.fixAll.eslint": true
        }
      }
    }
  },
  
  "postCreateCommand": ".devcontainer/scripts/postCreateCommand.sh",
  "postStartCommand": "echo '🚀 Codespace listo!'",
  
  "forwardPorts": [3000, 8000, 5000],
  "portsAttributes": {
    "3000": {
      "label": "Frontend",
      "onAutoForward": "notify"
    },
    "8000": {
      "label": "Backend API",
      "onAutoForward": "silent"
    }
  },
  
  "remoteUser": "codespace"
}
```

### 3. Script Post-Creación

```bash
#!/bin/bash
# .devcontainer/scripts/postCreateCommand.sh

set -e

echo "🔧 Configurando entorno de desarrollo..."

# Instalar dependencias Node.js
if [ -f "package.json" ]; then
    echo "📦 Instalando dependencias de Node.js..."
    npm install
fi

# Instalar dependencias Python
if [ -f "requirements.txt" ]; then
    echo "🐍 Instalando dependencias de Python..."
    pip install -r requirements.txt
fi

# Configurar Git
echo "🔐 Configurando Git..."
git config --global init.defaultBranch main
git config --global pull.rebase false

# Instalar herramientas adicionales
echo "🛠️ Instalando herramientas adicionales..."
npm install -g @commitlint/cli @commitlint/config-conventional
pip install pre-commit black flake8

# Pre-commit hooks
if [ -f ".pre-commit-config.yaml" ]; then
    echo "🪝 Configurando pre-commit hooks..."
    pre-commit install
fi

# Crear directorios necesarios
mkdir -p {logs,temp,uploads}

# Configurar variables de entorno para desarrollo
cat >> ~/.bashrc << 'EOF'
# Aliases útiles
alias ll='ls -la'
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias gco='git checkout'

# Variables de entorno
export NODE_ENV=development
export PYTHONPATH=$PYTHONPATH:/workspaces/$(basename $PWD)
EOF

echo "✅ Configuración completada!"
echo "🚀 Entorno listo para desarrollo"
```

---

## 🔧 Configuración Avanzada

### 1. Multi-Container Setup

```json
{
  "name": "Full-Stack App",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-vscode.vscode-typescript-next",
        "ms-vscode-remote.remote-containers",
        "ms-azuretools.vscode-docker"
      ]
    }
  },
  
  "forwardPorts": [3000, 8000, 5432, 6379],
  "portsAttributes": {
    "3000": {"label": "Frontend"},
    "8000": {"label": "API"},
    "5432": {"label": "PostgreSQL"},
    "6379": {"label": "Redis"}
  },
  
  "postCreateCommand": ".devcontainer/scripts/setup-full-stack.sh"
}
```

### 2. docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build: 
      context: .
      dockerfile: .devcontainer/Dockerfile
    volumes:
      - ../..:/workspaces:cached
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
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_USER: postgres
      POSTGRES_DB: myapp
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
      
  redis:
    image: redis:7-alpine
    restart: unless-stopped
    ports:
      - "6379:6379"
      
volumes:
  postgres-data:
```

### 3. Dockerfile Personalizado

```dockerfile
FROM mcr.microsoft.com/devcontainers/universal:2

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    postgresql-client \
    redis-tools \
    imagemagick \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js específico
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Instalar Python tools
RUN pip install --upgrade pip \
    && pip install poetry black flake8 mypy

# Configurar usuario
USER codespace

# Instalar herramientas globales
RUN npm install -g \
    typescript \
    @angular/cli \
    @vue/cli \
    create-react-app \
    vercel \
    netlify-cli

# Configurar shell
RUN echo 'export PATH=$PATH:/home/codespace/.local/bin' >> ~/.bashrc
```

---

## 📚 Templates por Stack

### 1. React + TypeScript + Vite

```json
{
  "name": "React TypeScript",
  "image": "mcr.microsoft.com/devcontainers/typescript-node:18",
  
  "features": {
    "ghcr.io/devcontainers/features/git:1": {}
  },
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "bradlc.vscode-tailwindcss",
        "esbenp.prettier-vscode",
        "ms-vscode.vscode-eslint",
        "formulahendry.auto-rename-tag",
        "christian-kohler.path-intellisense"
      ],
      "settings": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "emmet.includeLanguages": {
          "javascript": "javascriptreact",
          "typescript": "typescriptreact"
        }
      }
    }
  },
  
  "postCreateCommand": "npm install && npm run dev",
  "forwardPorts": [5173],
  "portsAttributes": {
    "5173": {
      "label": "Vite Dev Server",
      "onAutoForward": "notify"
    }
  }
}
```

### 2. Python FastAPI

```json
{
  "name": "Python FastAPI",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  
  "features": {
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/node:1": {
      "version": "18"
    }
  },
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.autopep8",
        "ms-python.black-formatter",
        "ms-python.flake8",
        "ms-python.isort",
        "tamasfe.even-better-toml",
        "charliermarsh.ruff"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.formatting.provider": "black",
        "python.linting.enabled": true,
        "python.linting.flake8Enabled": true,
        "editor.formatOnSave": true
      }
    }
  },
  
  "postCreateCommand": "pip install -r requirements.txt && uvicorn main:app --reload --host 0.0.0.0 --port 8000",
  "forwardPorts": [8000],
  "portsAttributes": {
    "8000": {
      "label": "FastAPI Server",
      "onAutoForward": "notify"
    }
  }
}
```

### 3. Next.js Full-Stack

```json
{
  "name": "Next.js Full-Stack",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "bradlc.vscode-tailwindcss",
        "prisma.prisma",
        "ms-vscode.vscode-json",
        "formulahendry.auto-rename-tag"
      ],
      "settings": {
        "typescript.preferences.includePackageJsonAutoImports": "on",
        "editor.formatOnSave": true
      }
    }
  },
  
  "postCreateCommand": ".devcontainer/scripts/setup-nextjs.sh",
  "forwardPorts": [3000, 5432],
  
  "secrets": {
    "DATABASE_URL": {
      "description": "PostgreSQL connection string"
    },
    "NEXTAUTH_SECRET": {
      "description": "NextAuth.js secret key"
    }
  }
}
```

### 4. Script Setup Next.js

```bash
#!/bin/bash
# .devcontainer/scripts/setup-nextjs.sh

set -e

echo "🔧 Configurando Next.js Full-Stack..."

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm install

# Configurar Prisma
echo "🗄️ Configurando base de datos..."
npx prisma generate
npx prisma db push

# Seed database (si existe)
if [ -f "prisma/seed.ts" ]; then
    echo "🌱 Ejecutando seeds..."
    npx prisma db seed
fi

# Instalar herramientas de desarrollo
npm install -D @types/node typescript

echo "✅ Setup completado!"
echo "🚀 Ejecuta 'npm run dev' para iniciar el servidor"
```

---

## ⚡ Optimización de Performance

### 1. Configuraciones para Sesiones Largas 🆕

```json
{
  "name": "Long Session Optimized",
  "image": "mcr.microsoft.com/devcontainers/universal:2",
  
  "hostRequirements": {
    "cpus": 4,
    "memory": "8gb",
    "storage": "32gb"
  },
  
  "customizations": {
    "vscode": {
      "settings": {
        "typescript.preferences.includePackageJsonAutoImports": "off",
        "typescript.suggest.autoImports": false,
        "typescript.disableAutomaticTypeAcquisition": true,
        "editor.quickSuggestions": false,
        "editor.parameterHints.enabled": false,
        "editor.wordBasedSuggestions": "off",
        "files.watcherExclude": {
          "**/.git/objects/**": true,
          "**/.git/subtree-cache/**": true,
          "**/node_modules/**": true,
          "**/.hg/store/**": true,
          "**/tmp/**": true,
          "**/*.log": true
        },
        "search.exclude": {
          "**/node_modules": true,
          "**/dist": true,
          "**/build": true,
          "**/tmp": true
        },
        "github.copilot.enable": {
          "*": true,
          "plaintext": false,
          "markdown": false
        }
      }
    }
  },
  
  "mounts": [
    "source=${localWorkspaceFolder}/node_modules,target=/workspaces/${localWorkspaceFolderBasename}/node_modules,type=volume"
  ],
  
  "postCreateCommand": ".devcontainer/scripts/setup-long-sessions.sh"
}
```

### 2. Script de Setup para Sesiones Largas

```bash
#!/bin/bash
# .devcontainer/scripts/setup-long-sessions.sh

echo "🚀 Configurando para sesiones largas..."

# Crear herramientas de optimización automática
cat > /workspaces/auto-optimize.sh << 'EOF'
#!/bin/bash
# Monitor automático para sesiones largas
while true; do
    # Limpiar cachés cada 30 minutos
    rm -rf /tmp/vscode-* 2>/dev/null
    rm -rf ~/.cache/typescript/* 2>/dev/null
    sync
    
    echo "🧹 Limpieza automática completada: $(date)"
    sleep 1800  # 30 minutos
done
EOF

chmod +x /workspaces/auto-optimize.sh

# Configurar limpieza automática en background
echo "🔄 Iniciando optimización automática en background..."
nohup /workspaces/auto-optimize.sh &

# Configurar alertas de rendimiento
cat > /workspaces/monitor-session.sh << 'EOF'
#!/bin/bash
# Monitor de sesión para alertar sobre degradación
ext_mem=$(ps aux | grep -E "(extensionHost|Extension Host)" | grep -v grep | awk '{sum+=$6} END {printf "%.0f", sum/1024}')
if [ "${ext_mem:-0}" -gt 2000 ]; then
    echo "⚠️ ALERTA: Extension Host usando ${ext_mem}MB - Considera recargar VS Code"
fi
EOF

chmod +x /workspaces/monitor-session.sh

echo "✅ Configuración para sesiones largas completada!"
echo "💡 Ejecuta '/workspaces/monitor-session.sh' para verificar estado"
```

### 3. Mejores Prácticas para Sesiones Largas 🚀

#### Configuración Inicial Optimizada
```bash
# Al iniciar una nueva sesión de Codespaces
./auto-optimize.sh setup           # Aplicar configuraciones optimizadas
./latency-detector.sh baseline     # Establecer baseline de rendimiento
```

#### Monitoreo Preventivo para Sesiones +4 Horas
```bash
# Monitor automático (recomendado para trabajo prolongado)
./latency-detector.sh monitor &

# Auto-optimización cada 5 minutos en background
./auto-optimize.sh start &
```

#### Manejo de Degradación de Performance

| Síntoma | Comando | Descripción |
|---------|---------|-------------|
| 🐌 Teclado lento | `./latency-detector.sh auto-fix` | Optimización automática |
| 💾 Alta memoria | `./auto-optimize.sh clean` | Limpieza de cachés |
| 🔴 Extension Host >1GB | Ctrl+Shift+P > "Reload Window" | Reiniciar VS Code |
| 📊 Múltiples TS servers | `./latency-detector.sh auto-fix moderate` | Limpieza profunda |

#### Scripts de Automatización Recomendados

```bash
# .devcontainer/scripts/session-optimizer.sh
#!/bin/bash
set -e

echo "🚀 Configurando sesión optimizada para trabajo prolongado..."

# Configuración base optimizada
./auto-optimize.sh setup

# Establecer baseline de rendimiento inicial
./latency-detector.sh baseline

# Monitor en background para sesiones largas (opcional)
if [ "${LONG_SESSION:-false}" = "true" ]; then
    echo "⏱️ Activando monitor automático para sesión larga..."
    ./latency-detector.sh monitor 300 &  # Cada 5 minutos
fi

echo "✅ Sesión optimizada lista para trabajo prolongado!"
echo "💡 Usa './latency-detector.sh check' para verificar estado"
```

### 3. Configuración de Performance Específica

```json
{
  "name": "High Performance Long Sessions",
  "image": "mcr.microsoft.com/devcontainers/universal:2",
  
  "hostRequirements": {
    "cpus": 4,
    "memory": "8gb",
    "storage": "32gb"
  },
  
  "customizations": {
    "vscode": {
      "settings": {
        "files.watcherExclude": {
          "**/node_modules/**": true,
          "**/.git/objects/**": true,
          "**/.git/subtree-cache/**": true,
          "**/dist/**": true,
          "**/build/**": true
        },
        "search.exclude": {
          "**/node_modules": true,
          "**/dist": true,
          "**/build": true
        },
        "typescript.disableAutomaticTypeAcquisition": true
      }
    }
  },
  
  "mounts": [
    "source=${localWorkspaceFolder}/node_modules,target=/workspaces/${localWorkspaceFolderBasename}/node_modules,type=volume"
  ]
}
```

### 2. Cache de Dependencias

```bash
#!/bin/bash
# .devcontainer/scripts/cache-dependencies.sh

echo "📦 Configurando cache de dependencias..."

# Node.js cache
if [ -f "package.json" ]; then
    echo "Setting up npm cache..."
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'
    export PATH=~/.npm-global/bin:$PATH
fi

# Python cache
if [ -f "requirements.txt" ]; then
    echo "Setting up pip cache..."
    pip config set global.cache-dir ~/.cache/pip
fi

# Configurar cache persistente
mkdir -p {~/.cache/pip,~/.npm,~/.cargo,~/.go}

echo "✅ Cache configurado!"
```

### 3. Pre-build de Imagen

```dockerfile
# .devcontainer/Dockerfile.prebuild
FROM mcr.microsoft.com/devcontainers/universal:2

# Pre-instalar dependencias comunes
RUN npm install -g \
    typescript \
    @angular/cli \
    @vue/cli \
    create-react-app \
    prettier \
    eslint

RUN pip install \
    fastapi \
    uvicorn \
    sqlalchemy \
    alembic \
    pytest \
    black \
    flake8

# Pre-configurar herramientas
RUN git config --global init.defaultBranch main
RUN echo 'alias ll="ls -la"' >> ~/.bashrc
```

---

## 💰 Gestión de Recursos

### 1. Configuración de Auto-suspend

```json
{
  "name": "Cost-Optimized",
  "image": "mcr.microsoft.com/devcontainers/universal:2",
  
  "hostRequirements": {
    "cpus": 2,
    "memory": "4gb",
    "storage": "32gb"
  },
  
  "customizations": {
    "codespaces": {
      "machine": "basicLinux32gb"
    }
  },
  
  "postCreateCommand": "echo 'Setup completado en $(date)'",
  "postStartCommand": "echo 'Codespace iniciado en $(date)'"
}
```

### 2. Script de Monitoreo de Recursos

```bash
#!/bin/bash
# .devcontainer/scripts/monitor-resources.sh

echo "📊 Estado de recursos del Codespace:"
echo "=================================="

# CPU Usage
echo "🖥️ CPU:"
top -bn1 | grep "Cpu(s)" | awk '{print "   Uso: " $2}' | sed 's/%us,//'

# Memory Usage
echo "💾 Memoria:"
free -h | awk '/^Mem:/ {print "   Usada: " $3 "/" $2 " (" int($3/$2 * 100) "%)"}'

# Disk Usage
echo "💿 Disco:"
df -h /workspaces | awk 'NR==2 {print "   Usada: " $3 "/" $2 " (" $5 ")"}'

# Network
echo "🌐 Red:"
cat /proc/net/dev | awk '/eth0/ {print "   RX: " int($2/1024/1024) "MB, TX: " int($10/1024/1024) "MB"}'

echo "=================================="
echo "⏰ Tiempo activo: $(uptime -p)"
```

### 3. Auto-cleanup Script

```bash
#!/bin/bash
# .devcontainer/scripts/cleanup.sh

echo "🧹 Limpiando archivos temporales..."

# Limpiar cache de npm
if command -v npm &> /dev/null; then
    npm cache clean --force
fi

# Limpiar cache de pip
if command -v pip &> /dev/null; then
    pip cache purge
fi

# Limpiar logs
find /workspaces -name "*.log" -type f -delete 2>/dev/null || true

# Limpiar directorios temporales
rm -rf /tmp/* 2>/dev/null || true
rm -rf ~/.cache/thumbnails/* 2>/dev/null || true

# Limpiar Git
git gc --aggressive --prune=now 2>/dev/null || true

echo "✅ Limpieza completada!"
```

---

## 🐛 Troubleshooting

### Problemas Comunes

#### 1. Codespace no inicia
```bash
# Verificar configuración
cat .devcontainer/devcontainer.json | jq '.'

# Revisar logs
gh codespace logs --codespace CODESPACE_NAME
```

#### 2. Ports no forwardean
```json
{
  "forwardPorts": [3000],
  "portsAttributes": {
    "3000": {
      "onAutoForward": "notify",
      "visibility": "public"
    }
  }
}
```

#### 3. Performance lenta y latencia del teclado 🆕
```bash
# Verificar recursos y detectar problemas
./latency-detector.sh check

# Auto-optimización para sesiones largas
./auto-optimize.sh clean

# Configuración completa para sesiones largas
./auto-optimize.sh setup

# Monitor continuo (background)
./latency-detector.sh monitor &

# Si persiste: Recargar VS Code
# Ctrl+Shift+P > "Developer: Reload Window"
```

**Configuración automática aplicada:**
```json
{
  "typescript.preferences.includePackageJsonAutoImports": "off",
  "typescript.suggest.autoImports": false,
  "editor.quickSuggestions": false,
  "editor.parameterHints.enabled": false,
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/node_modules/**": true,
    "**/tmp/**": true,
    "**/*.log": true
  }
}
```

#### 4. Problemas de permisos
```bash
# Verificar usuario
whoami
id

# Cambiar ownership si es necesario
sudo chown -R codespace:codespace /workspaces
```

### Debug de Configuración

```bash
#!/bin/bash
# .devcontainer/scripts/debug-config.sh

echo "🔍 Diagnostico de Codespace"
echo "=========================="

echo "📍 Ubicación: $(pwd)"
echo "👤 Usuario: $(whoami)"
echo "🖥️ Sistema: $(uname -a)"
echo "🐳 Docker: $(docker --version 2>/dev/null || echo 'No disponible')"
echo "📦 Node: $(node --version 2>/dev/null || echo 'No disponible')"
echo "🐍 Python: $(python --version 2>/dev/null || echo 'No disponible')"
echo "🔧 Git: $(git --version)"

echo ""
echo "📋 Variables de entorno relevantes:"
env | grep -E "GITHUB|CODESPACE|NODE|PYTHON" | sort

echo ""
echo "🔌 Puertos en uso:"
netstat -tulpn 2>/dev/null | grep LISTEN || ss -tulpn | grep LISTEN

echo ""
echo "💾 Espacio en disco:"
df -h /workspaces

echo "=========================="
```

---

## ✅ Checklist

### 📋 Configuración Básica
- [ ] devcontainer.json creado y validado
- [ ] Features necesarias configuradas
- [ ] Extensions de VS Code instaladas
- [ ] Scripts post-creación funcionando
- [ ] Forward de puertos configurado

### 🔧 Configuración Avanzada
- [ ] Multi-container setup (si aplica)
- [ ] Dockerfile personalizado
- [ ] Secrets configurados
- [ ] Variables de entorno
- [ ] Cache de dependencias

### ⚡ Optimización
- [ ] Configuración de recursos apropiada
- [ ] Exclusiones de archivos configuradas
- [ ] Pre-build optimizada
- [ ] Scripts de limpieza
- [ ] Monitoreo de recursos

### 🔒 Seguridad
- [ ] Secrets en GitHub configurados
- [ ] Variables sensibles no en código
- [ ] Permisos de usuario correctos
- [ ] Ports públicos solo si necesario
- [ ] Git configurado correctamente

### 🧪 Testing
- [ ] Codespace inicia correctamente
- [ ] Todas las herramientas funcionan
- [ ] Ports accesibles
- [ ] Scripts ejecutan sin errores
- [ ] Performance aceptable

---

## ❓ FAQ

### ¿Cuánto cuesta usar Codespaces?

**R:** GitHub incluye:
- **Personal:** 60 horas gratis/mes (2-core)
- **Pro:** 90 horas gratis/mes
- **Enterprise:** Depende del plan
- Costo adicional: ~$0.18/hora (2-core)

### ¿Puedo usar mi configuración local?

**R:** Sí, con Settings Sync:
- Instala la extensión Settings Sync
- Sincroniza settings, keybindings, extensions
- Se aplica automáticamente en Codespaces

### ¿Cómo persistir datos entre sesiones?

**R:** Los datos se persisten automáticamente en:
- `/workspaces/` (código del proyecto)
- `~/.` (configuraciones de usuario)
- Usar volumes para node_modules, etc.

---

## 🔗 Siguiente Paso

➡️ **[Guía 09: Pruebas y Validación](09-pruebas-validacion.md)**

---

## 📚 Recursos Adicionales

- [GitHub Codespaces Docs](https://docs.github.com/en/codespaces)
- [Dev Container Specification](https://containers.dev/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Codespaces Pricing](https://github.com/pricing)
- [Dev Container Images](https://github.com/devcontainers/images)
