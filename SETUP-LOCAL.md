# 🏠 Configuración para Desarrollo Local

## 🚀 Inicio Rápido - Desarrollo Local

### 📋 Prerrequisitos:
```bash
# Python 3.8 o superior
python --version

# Node.js (opcional, para herramientas adicionales)
node --version

# Git
git --version
```

### 🔧 Instalación Local:

#### 1️⃣ **Clonar el Repositorio:**
```bash
git clone https://github.com/tu-usuario/tic-tac-toe-agent.git
cd tic-tac-toe-agent
```

#### 2️⃣ **Configurar Entorno Virtual:**
```bash
# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
# En Linux/Mac:
source venv/bin/activate
# En Windows:
venv\Scripts\activate
```

#### 3️⃣ **Instalar Dependencias:**
```bash
pip install -r requirements.txt
```

#### 4️⃣ **Iniciar el Juego:**
```bash
# Método 1: Script automático
./start-local.sh

# Método 2: Manual
cd server && python server.py
```

#### 5️⃣ **Abrir en Navegador:**
```bash
# La URL será SIEMPRE:
http://localhost:8000
```

## 🔄 **Diferencias con Codespaces:**

| Aspecto | Local | Codespaces |
|---------|-------|------------|
| URL | `localhost:8000` | `https://[codespace]-8000.app.github.dev/` |
| Setup | Manual | Automático |
| Dependencias | Instalar manualmente | Pre-instaladas |
| VS Code | Local | Browser/Remote |
| Performance | Depende de tu PC | Consistente |
| Colaboración | Git push/pull | Directo en cloud |

## 🛠️ **Herramientas de Monitoreo en Local:**

```bash
# Todas las herramientas funcionan igual:
./monitor-visual.sh          # Monitor visual
./monitor-latency.sh         # Diagnóstico latencia
./benchmark-report.sh        # Reportes HTML

# Diferencias en local:
# - Mejor rendimiento generalmente
# - GPU local disponible (si tienes)
# - Sin límites de Codespaces
```

## 🔧 **Configuración VS Code Local:**

Crear `.vscode/settings.json` para desarrollo local:
```json
{
  "python.defaultInterpreterPath": "./venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "typescript.preferences.includePackageJsonAutoImports": "auto",
  "editor.quickSuggestions": {
    "other": true,
    "comments": false,
    "strings": false
  }
}
```

## 🚀 **Scripts Específicos para Local:**

### `start-local.sh`:
```bash
#!/bin/bash
echo "🏠 Iniciando Tic-Tac-Toe en DESARROLLO LOCAL"
echo "==========================================="

# Verificar entorno virtual
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "⚠️  Activar entorno virtual primero:"
    echo "   source venv/bin/activate"
    exit 1
fi

# Iniciar servidor
echo "🚀 Iniciando servidor en http://localhost:8000"
cd server && python server.py
```

## 🐛 **Troubleshooting Local:**

### ❌ **Puerto ocupado:**
```bash
# Encontrar proceso en puerto 8000
lsof -i :8000
# Matarlo si es necesario
kill -9 <PID>
```

### ❌ **Dependencias faltantes:**
```bash
# Reinstalar dependencias
pip install -r requirements.txt --force-reinstall
```

### ❌ **Python no encontrado:**
```bash
# Verificar Python
which python
which python3

# Usar python3 si es necesario
python3 -m venv venv
```

## 💡 **Mejores Prácticas Locales:**

1. **🔄 Usar entorno virtual siempre**
2. **📝 Commitear desde local para mejor control**
3. **🧪 Testing local antes de push**
4. **🔧 Configurar Git correctamente**:
   ```bash
   git config user.name "Tu Nombre"
   git config user.email "tu@email.com"
   ```

5. **📊 Usar herramientas de monitoreo para optimizar**

---

**✅ Desarrollo local configurado - Compatible con Codespaces**
