# 📦 02 - Creación del Repositorio

> **Objetivo**: Crear y configurar un nuevo repositorio en GitHub optimizado para desarrollo dual (local + Codespaces).

## 🌐 Método 1: GitHub Web Interface (Recomendado para principiantes)

### Paso 1: Acceder a GitHub
1. 🌐 Ve a [github.com/new](https://github.com/new)
2. 🔐 Asegúrate de estar autenticado en tu cuenta

### Paso 2: Configurar el Repositorio

#### Información Básica
- **📝 Repository name**: 
  ```
  mi-proyecto-dual
  ```
  > ⚠️ **Naming conventions**: Solo letras minúsculas, números y guiones. No espacios ni caracteres especiales.

- **📄 Description**:
  ```
  Proyecto con arquitectura dual (Local + GitHub Codespaces) para [descripción del proyecto]
  ```

#### Configuración de Visibilidad
- **🔓 Public**: Recomendado para proyectos open source, portfolios o aprendizaje
- **🔒 Private**: Para proyectos comerciales o código sensible

#### Inicialización del Repositorio
- ✅ **Add a README file**: Siempre marcado
- ✅ **Add .gitignore**: Selecciona según tu stack:
  - `Python` para proyectos Python
  - `Node` para proyectos JavaScript/TypeScript
  - `VisualStudio` para proyectos con VS Code específicos
- ✅ **Choose a license**: 
  - `MIT License` (recomendado para open source)
  - `Apache License 2.0` (para proyectos comerciales flexibles)
  - `GNU GPL v3` (para proyectos completamente open source)

### Paso 3: Crear el Repositorio
1. 🚀 Click en **"Create repository"**
2. ⏳ Espera a que GitHub procese la creación
3. 🎉 ¡Repositorio creado exitosamente!

## ⚡ Método 2: GitHub CLI (Para usuarios avanzados)

### Comando Básico
```bash
# Crear repositorio público con configuración completa
gh repo create mi-proyecto-dual \
  --public \
  --clone \
  --add-readme \
  --gitignore Python \
  --license MIT \
  --description "Proyecto con arquitectura dual (Local + GitHub Codespaces)"

# Navegar al directorio del proyecto
cd mi-proyecto-dual
```

### Comando con Opciones Avanzadas
```bash
# Para proyectos privados con más configuraciones
gh repo create mi-proyecto-dual \
  --private \
  --clone \
  --add-readme \
  --gitignore Node \
  --license Apache-2.0 \
  --description "Aplicación web con arquitectura dual" \
  --homepage "https://mi-proyecto-dual.com" \
  --enable-issues \
  --enable-wiki

cd mi-proyecto-dual
```

### Verificar Creación
```bash
# Verificar información del repositorio
gh repo view

# Verificar estado del git local
git status
git remote -v
```

## 🔄 Método 3: Clonar Repositorio Existente

Si el repositorio ya existe y solo necesitas clonarlo:

### Clonación HTTPS (Recomendado)
```bash
# Clonar usando HTTPS
git clone https://github.com/tu-usuario/mi-proyecto-dual.git
cd mi-proyecto-dual
```

### Clonación SSH (Para usuarios con SSH configurado)
```bash
# Clonar usando SSH
git clone git@github.com:tu-usuario/mi-proyecto-dual.git
cd mi-proyecto-dual
```

### Clonación con GitHub CLI
```bash
# Clonar usando GitHub CLI
gh repo clone tu-usuario/mi-proyecto-dual
cd mi-proyecto-dual
```

## ⚙️ Configuración Inicial del Repositorio

### 1. Verificar Configuración Local
```bash
# Verificar configuración de Git
git config --list

# Configurar usuario local (si necesario)
git config user.name "Tu Nombre"
git config user.email "tu.email@ejemplo.com"

# Verificar remotes
git remote -v
```

### 2. Configurar Branch Principal
```bash
# Verificar branch actual
git branch

# Si necesitas cambiar a 'main' (desde 'master')
git branch -M main
git push -u origin main
```

### 3. Configuración de GitHub (Página del Repositorio)

#### Acceder a Settings
1. 🌐 Ve a `https://github.com/tu-usuario/mi-proyecto-dual`
2. ⚙️ Click en tab **"Settings"**

#### Configurar General Settings
- **📝 Repository name**: Verificar que sea correcto
- **📄 Description**: Actualizar si es necesario
- **🌐 Website**: Agregar URL si tienes
- **🏷️ Topics**: Agregar tags relevantes (ej: `devcontainer`, `codespaces`, `python`)

#### Configurar Features
```
✅ Issues
✅ Projects  
✅ Wiki (opcional)
✅ Discussions (opcional para proyectos colaborativos)
```

#### Configurar Security
- **🔒 Vulnerability alerts**: Activado
- **📊 Dependency graph**: Activado
- **🔐 Private repository settings** (solo para repos privados)

## 🚀 Habilitar GitHub Codespaces

### Verificar Disponibilidad
```bash
# Verificar si Codespaces está disponible para tu cuenta
gh codespace list
```

### Configurar Codespaces Settings
1. 🌐 En tu repositorio, ve a **Settings > Codespaces**
2. ⚙️ Configurar:
   ```
   ✅ Allow creating codespaces for this repository
   ✅ Prebuilds (opcional para repositorios grandes)
   ```

### Configurar Secrets (Si necesario)
Para variables de entorno sensibles:
1. 🔐 Ve a **Settings > Secrets and variables > Codespaces**
2. ➕ **New repository secret**
3. 📝 Agregar secrets necesarios

## 📋 Templates de README Inicial

### Template Básico
```markdown
# 🚀 Mi Proyecto Dual

> Proyecto con arquitectura dual optimizada para desarrollo local y GitHub Codespaces.

## ⚡ Quick Start

### 🌐 GitHub Codespaces (Recomendado)
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tu-usuario/mi-proyecto-dual)

### 💻 Desarrollo Local
\`\`\`bash
git clone https://github.com/tu-usuario/mi-proyecto-dual.git
cd mi-proyecto-dual
code .
\`\`\`

## 🏗️ Stack Tecnológico

- **Lenguaje**: [Python/Node.js/etc.]
- **Framework**: [Framework específico]
- **Base de Datos**: [Si aplica]
- **DevOps**: Docker, GitHub Codespaces, VS Code Dev Containers

## 📚 Documentación

- [📖 Guía de Setup](docs/setup.md)
- [🛠️ Guía de Desarrollo](docs/development.md)
- [🚀 Guía de Deployment](docs/deployment.md)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, lee [CONTRIBUTING.md](CONTRIBUTING.md) para detalles.

## 📄 Licencia

Este proyecto está bajo la licencia [MIT](LICENSE).
```

### Template para Proyectos Python
```markdown
# 🐍 Mi Proyecto Python

> Aplicación Python con arquitectura dual para desarrollo flexible.

## 🚀 Quick Start

### 🌐 GitHub Codespaces
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tu-usuario/mi-proyecto-dual)

### 💻 Local con Dev Container
\`\`\`bash
git clone https://github.com/tu-usuario/mi-proyecto-dual.git
cd mi-proyecto-dual
code .
# Reopén en container cuando VS Code lo sugiera
\`\`\`

### 🔧 Local Tradicional
\`\`\`bash
git clone https://github.com/tu-usuario/mi-proyecto-dual.git
cd mi-proyecto-dual
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\\Scripts\\activate
pip install -r requirements.txt
python app.py
\`\`\`

## 🛠️ Stack

- **Python**: 3.9+
- **Framework**: FastAPI/Flask/Django
- **Database**: PostgreSQL/SQLite
- **Testing**: pytest
- **Linting**: flake8, black
```

## 🧪 Verificación del Setup

### Script de Verificación
Crea `scripts/verify-repo.sh`:
```bash
#!/bin/bash

echo "🔍 Verificando configuración del repositorio..."
echo "============================================="

# Verificar Git
echo "📂 Repositorio: $(git remote get-url origin)"
echo "🌿 Branch actual: $(git branch --show-current)"

# Verificar archivos esenciales
files=("README.md" ".gitignore" "LICENSE")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file: Presente"
    else
        echo "❌ $file: Faltante"
    fi
done

# Verificar configuración de Git
echo "👤 Usuario Git: $(git config user.name)"
echo "📧 Email Git: $(git config user.email)"

echo "============================================="
echo "🎉 Verificación completada"
```

### Ejecutar Verificación
```bash
chmod +x scripts/verify-repo.sh
./scripts/verify-repo.sh
```

## ❓ FAQ - Creación de Repositorio

### P: ¿Público o privado para proyectos de aprendizaje?
**R**: Público es recomendado para portfolios y aprendizaje. Facilita la colaboración y muestra tu trabajo.

### P: ¿Qué licencia elegir?
**R**: 
- **MIT**: Máxima flexibilidad, permite uso comercial
- **Apache 2.0**: Similar a MIT pero con protección de patentes
- **GPL v3**: Requiere que derivados sean también open source

### P: ¿Debo inicializar con README, .gitignore y LICENSE?
**R**: Sí, siempre. Esto establece buenas prácticas desde el inicio.

### P: ¿Puedo cambiar la configuración después?
**R**: Sí, todas las configuraciones pueden modificarse posteriormente en Settings.

## 🔧 Troubleshooting

### Error: "Repository already exists"
```bash
# Verificar si ya tienes el repositorio
gh repo view tu-usuario/mi-proyecto-dual

# Si existe, clónalo en lugar de crearlo
gh repo clone tu-usuario/mi-proyecto-dual
```

### Error: "Permission denied" al clonar
```bash
# Verificar autenticación
gh auth status

# Re-autenticar si es necesario
gh auth login
```

### Error: Git no reconoce el remote
```bash
# Verificar remotes
git remote -v

# Agregar remote si falta
git remote add origin https://github.com/tu-usuario/mi-proyecto-dual.git
```

## ✅ Checklist de Creación

- [ ] ✅ Repositorio creado en GitHub
- [ ] ✅ Repositorio clonado localmente
- [ ] ✅ Archivos iniciales verificados (README, .gitignore, LICENSE)
- [ ] ✅ Configuración de Git local verificada
- [ ] ✅ GitHub Codespaces habilitado
- [ ] ✅ README inicial actualizado
- [ ] ✅ Settings del repositorio configurados
- [ ] ✅ Script de verificación ejecutado exitosamente

## ➡️ Siguiente Paso

Una vez creado y configurado el repositorio, continúa con:
👉 **[03-estructura-proyecto.md](03-estructura-proyecto.md)** - Organización de archivos y directorios
