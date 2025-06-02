# 🎯 01 - Preparación Inicial

> **Objetivo**: Asegurar que tienes todas las herramientas y conocimientos necesarios antes de comenzar.

## 📋 Requisitos Previos

### ✅ Herramientas Esenciales

#### 1. **Cuenta de GitHub**
- ✅ Cuenta activa en [GitHub](https://github.com)
- ✅ Acceso a [GitHub Codespaces](https://github.com/features/codespaces)
- ✅ GitHub CLI instalado (opcional pero recomendado)

#### 2. **Git**
- ✅ Git versión 2.30 o superior
- ✅ Configuración básica de usuario

```bash
# Verificar versión de Git
git --version

# Configurar usuario (si no está configurado)
git config --global user.name "Tu Nombre"
git config --global user.email "tu.email@ejemplo.com"
```

#### 3. **Visual Studio Code**
- ✅ VS Code versión 1.70 o superior
- ✅ Extensiones recomendadas instaladas

```bash
# Verificar versión de VS Code
code --version
```

### 🔧 Extensiones de VS Code Recomendadas

```bash
# Instalar extensiones esenciales
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
code --install-extension ms-vscode.vscode-json
code --install-extension GitHub.copilot              # Opcional
code --install-extension GitHub.copilot-chat         # Opcional
```

### 🛠️ Herramientas por Stack Tecnológico

#### Para Proyectos Python
```bash
# Verificar Python
python3 --version    # Python 3.8+
pip3 --version

# Extensiones adicionales para Python
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.flake8
```

#### Para Proyectos Node.js/JavaScript
```bash
# Verificar Node.js
node --version       # Node.js 16+
npm --version

# Extensiones adicionales para JavaScript/TypeScript
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
```

#### Para Proyectos Full-Stack
```bash
# Extensiones adicionales para desarrollo web
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-vscode.vscode-css-peek
code --install-extension ritwickdey.LiveServer
```

### 🌐 GitHub CLI (Opcional pero Recomendado)

#### Instalación
```bash
# En macOS (con Homebrew)
brew install gh

# En Ubuntu/Debian
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# En Windows (con chocolatey)
choco install gh
```

#### Autenticación
```bash
# Autenticar con GitHub
gh auth login

# Verificar autenticación
gh auth status
```

### 📚 Conocimientos Básicos Requeridos

#### Git & GitHub
- ✅ Comandos básicos de Git (clone, add, commit, push, pull)
- ✅ Branching y merging básico
- ✅ GitHub workflow básico
- ✅ Conceptos de remote repositories

#### Desarrollo con Contenedores (Básico)
- ✅ Qué es un contenedor Docker (concepto general)
- ✅ Qué son los Dev Containers
- ✅ Cómo funciona VS Code con contenedores

#### Línea de Comandos
- ✅ Navegación básica en terminal
- ✅ Creación y edición de archivos
- ✅ Permisos básicos de archivos

## 🧪 Verificación del Entorno

### Script de Verificación Automática
Crea y ejecuta este script para verificar tu entorno:

```bash
#!/bin/bash
# verificar-entorno.sh

echo "🔍 Verificando entorno de desarrollo..."
echo "=====================================

# Verificar Git
if command -v git &> /dev/null; then
    echo "✅ Git: $(git --version)"
else
    echo "❌ Git no está instalado"
fi

# Verificar VS Code
if command -v code &> /dev/null; then
    echo "✅ VS Code: $(code --version | head -n1)"
else
    echo "❌ VS Code no está instalado"
fi

# Verificar GitHub CLI
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI: $(gh --version | head -n1)"
else
    echo "⚠️ GitHub CLI no está instalado (opcional)"
fi

# Verificar Python (si aplica)
if command -v python3 &> /dev/null; then
    echo "✅ Python: $(python3 --version)"
else
    echo "⚠️ Python no está instalado"
fi

# Verificar Node.js (si aplica)
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
else
    echo "⚠️ Node.js no está instalado"
fi

echo "=====================================
echo "🎉 Verificación completada"
```

### Ejecutar Verificación
```bash
# Hacer ejecutable
chmod +x verificar-entorno.sh

# Ejecutar
./verificar-entorno.sh
```

## 🎓 Recursos de Aprendizaje

### Si Necesitas Aprender los Básicos
- **Git**: [Git Handbook](https://guides.github.com/introduction/git-handbook/)
- **GitHub**: [GitHub Skills](https://skills.github.com/)
- **VS Code**: [VS Code Documentation](https://code.visualstudio.com/docs)
- **Dev Containers**: [Dev Container Tutorial](https://code.visualstudio.com/docs/devcontainers/tutorial)

### Documentación Oficial
- [GitHub Codespaces Docs](https://docs.github.com/en/codespaces)
- [Dev Containers Specification](https://containers.dev/)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)

## ❓ FAQ - Preparación Inicial

### P: ¿Necesito conocer Docker para usar Dev Containers?
**R**: No es necesario conocimiento profundo de Docker. Los Dev Containers abstraen la complejidad, pero entender los conceptos básicos es útil.

### P: ¿Puedo usar este setup sin GitHub Codespaces?
**R**: Sí, puedes usar solo el desarrollo local con Dev Containers. Codespaces es opcional pero recomendado para colaboración.

### P: ¿Qué stack tecnológico debo elegir?
**R**: Depende de tu proyecto:
- **Python**: Para AI/ML, data science, backend APIs
- **Node.js**: Para aplicaciones web, APIs REST, herramientas CLI
- **Full-Stack**: Para aplicaciones web completas

### P: ¿Es obligatorio usar VS Code?
**R**: Los Dev Containers están optimizados para VS Code, pero puedes usar otros editores que soporten contenedores.

## ✅ Checklist de Preparación

Marca cada item cuando esté completado:

- [ ] ✅ Cuenta de GitHub activa
- [ ] ✅ Git instalado y configurado
- [ ] ✅ VS Code instalado
- [ ] ✅ Extensiones básicas de VS Code instaladas
- [ ] ✅ Herramientas del stack elegido instaladas
- [ ] ✅ GitHub CLI instalado y autenticado (opcional)
- [ ] ✅ Script de verificación ejecutado exitosamente
- [ ] ✅ Documentación de referencia revisada

## ➡️ Siguiente Paso

Una vez completada la preparación inicial, continúa con:
👉 **[02-creacion-repositorio.md](02-creacion-repositorio.md)** - Crear y configurar el repositorio en GitHub
