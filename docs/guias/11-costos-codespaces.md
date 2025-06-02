# 11. 💰 Costos y Gestión Financiera de GitHub Codespaces

Esta guía cubre todo lo relacionado con costos, facturación y mejores prácticas para optimizar el uso de GitHub Codespaces.

## 📋 Tabla de Contenidos

1. [Métodos de Acceso](#-métodos-de-acceso-y-conexiones)
2. [Modelo de Precios](#-modelo-de-precios)
3. [Gestión de Máquinas](#-gestión-de-máquinas)
4. [Monitoreo y Control](#-monitoreo-y-control)
5. [Mejores Prácticas](#-mejores-prácticas)
6. [Optimización Financiera](#-optimización-financiera)
7. [Troubleshooting](#-troubleshooting)

## 🌐 Métodos de Acceso y Conexiones

### 🖥️ Opciones de Acceso a Codespaces

#### 1. **VS Code Desktop (Recomendado)**
```bash
# Instalar la extensión oficial
code --install-extension GitHub.codespaces

# Conectar desde Command Palette
# Ctrl+Shift+P → "Codespaces: Connect to Codespace"
```

**Ventajas:**
- ✅ Rendimiento superior (especialmente teclado)
- ✅ Extensiones completas disponibles
- ✅ Integración nativa con herramientas locales
- ✅ Mejor experiencia de debugging

**Desventajas:**
- ❌ Requiere instalación local
- ❌ Depende de la máquina local para el cliente

#### 2. **VS Code Desktop Insiders**
```bash
# Para características experimentales
code-insiders --install-extension GitHub.codespaces

# Acceso a funciones beta de Codespaces
```

**Cuándo usar:**
- 🧪 Testing de nuevas funciones
- 🔬 Desarrollo con características experimentales
- 📈 Feedback temprano a Microsoft

#### 3. **Browser (github.dev)**
```bash
# Acceso directo desde GitHub
# 1. Ve a tu repositorio en GitHub.com
# 2. Presiona "." (punto) para abrir github.dev
# 3. O cambia .com por .dev en la URL

# Crear Codespace desde el navegador
# GitHub.com → Tu Repo → Code → Codespaces → Create codespace
```

**Ventajas:**
- ✅ Sin instalaciones requeridas
- ✅ Acceso desde cualquier dispositivo
- ✅ Perfecto para edición rápida
- ✅ Ideal para revisiones de código

**Desventajas:**
- ❌ Rendimiento limitado (especialmente teclado)
- ❌ Extensiones limitadas
- ❌ Sin acceso a terminal completo (en github.dev)

#### 4. **GitHub CLI**
```bash
# Gestión completa desde terminal
gh codespace create --repo OWNER/REPO
gh codespace list
gh codespace ssh --codespace NAME
gh codespace stop --codespace NAME
```

**Ideal para:**
- 🤖 Automatización y scripts
- 🔧 Gestión en masa de Codespaces
- 📊 Integración con pipelines CI/CD

#### 5. **JetBrains IDEs (Gateway)**
```bash
# Instalar JetBrains Gateway
# Configurar conexión a Codespace
# Acceso con PyCharm, IntelliJ, etc.
```

### 🔄 Gestión de Conexiones y Sesiones

#### 🔌 **Conectar a Codespace Existente**

```bash
# Desde VS Code Desktop
# 1. Command Palette (Ctrl+Shift+P)
# 2. "Codespaces: Connect to Codespace"
# 3. Seleccionar de la lista

# Desde terminal
gh codespace ssh --codespace NAME

# Desde navegador
# GitHub.com → Codespaces → Open in Browser
```

#### ⏸️ **Cerrar Sesiones (Sin Detener Codespace)**

```bash
# VS Code Desktop
# File → Close Remote Connection
# O: Ctrl+Shift+P → "Codespaces: Close Connection"

# Browser
# Simplemente cerrar la pestaña

# Terminal SSH
exit
```

#### ⏹️ **Detener Codespace Completamente**

```bash
# Desde VS Code (cuando conectado)
# Ctrl+Shift+P → "Codespaces: Stop Current Codespace"

# Desde Command Line
gh codespace stop --codespace NAME

# Desde GitHub.com
# Ir a github.com/codespaces → Stop
```

### 🚫 **Remote Tunnels vs Codespaces**

#### ⚠️ **Remote Tunnels NO es para Codespaces**

```json
// .vscode/settings.json
{
  "remote.tunnels.access.enablePublic": false,
  "remote.tunnels.access.host": "disabled"
}
```

**Diferencias clave:**

| Aspecto | Codespaces | Remote Tunnels |
|---------|------------|----------------|
| **Infraestructura** | GitHub/Azure | Tu máquina local |
| **Costo** | Facturado por GitHub | Gratis (tu hardware) |
| **Configuración** | Dev Container | Tu entorno local |
| **Acceso** | Navegador + VS Code | Navegador + VS Code |
| **Uso simultáneo** | ✅ Recomendado | ❌ Redundante |

#### 🎯 **Cuándo usar cada uno:**

```bash
# Usar Codespaces cuando:
# - Quieres entorno consistente
# - Trabajas en equipo
# - Necesitas recursos específicos
# - Quieres acceso desde cualquier lugar

# Usar Remote Tunnels cuando:
# - Quieres usar tu máquina poderosa
# - Evitar costos de cloud
# - Trabajar con datos locales sensibles
# - Tienes configuración personalizada compleja
```

### 📱 **Acceso Multi-Dispositivo**

#### 🖥️ **Workflow Desktop → Móvil**

```bash
# 1. Desarrollar en VS Code Desktop
# 2. Commit y push cambios
# 3. Acceder desde tablet/móvil via browser
# 4. Hacer ediciones menores
# 5. Continuar en desktop
```

#### 📊 **Monitoreo de Sesiones Activas**

```bash
#!/bin/bash
# scripts/monitor-sessions.sh

echo "🌐 SESIONES ACTIVAS DE CODESPACES"
echo "================================"

# Listar todas las conexiones
gh codespace list --json name,state,lastUsedAt,machine | jq -r '
  .[] | 
  select(.state == "Active") | 
  "🟢 " + .name + " (" + .machine.displayName + ")"'

echo
echo "📱 ACCESOS RECIENTES:"
gh codespace list --json name,lastUsedAt | jq -r '
  .[] | 
  select(.lastUsedAt > (now - 3600)) |
  "- " + .name + ": " + (.lastUsedAt | strftime("%H:%M"))'
```

### ⚡ **Optimización de Conexiones**

#### 🚀 **Configuración de Rendimiento**

```json
// .vscode/settings.json para Codespaces
{
  // Optimizar conexión
  "remote.autoForwardPorts": false,
  "remote.localPortHost": "localhost",
  
  // Reducir latencia de teclado
  "terminal.integrated.fastScrollSensitivity": 5,
  "editor.smoothScrolling": false,
  
  // Optimizar sincronización
  "files.autoSave": "onFocusChange",
  "git.autofetch": false
}
```

#### 🔧 **Scripts de Conexión Rápida**

```bash
#!/bin/bash
# scripts/quick-connect.sh

echo "🚀 Conexión Rápida a Codespace"

# Listar Codespaces disponibles
codespaces=$(gh codespace list --json name,state | jq -r '.[] | select(.state != "Shutdown") | .name')

if [ -z "$codespaces" ]; then
    echo "❌ No hay Codespaces disponibles"
    echo "💡 ¿Crear uno nuevo? (y/n)"
    read -r create_new
    if [ "$create_new" = "y" ]; then
        gh codespace create
    fi
    exit 1
fi

echo "📋 Codespaces disponibles:"
echo "$codespaces" | nl

echo "🔢 Selecciona el número:"
read -r selection

selected=$(echo "$codespaces" | sed -n "${selection}p")

if [ -n "$selected" ]; then
    echo "🔌 Conectando a: $selected"
    gh codespace ssh --codespace "$selected"
else
    echo "❌ Selección inválida"
fi
```

### 📡 **Port Forwarding y Servicios**

#### 🌐 **Exponer Servicios desde Codespace**

```bash
# Port forwarding automático en VS Code
# Los puertos se detectan automáticamente

# Manual port forwarding
gh codespace ports forward 3000:3000 --codespace NAME

# Ver puertos activos
gh codespace ports --codespace NAME

# Hacer puerto público (cuidado con seguridad)
gh codespace ports visibility 3000:public --codespace NAME
```

#### 🔒 **Configuración de Seguridad**

```json
// .devcontainer/devcontainer.json
{
  "forwardPorts": [3000, 8080],
  "portsAttributes": {
    "3000": {
      "label": "App Frontend",
      "onAutoForward": "notify"
    },
    "8080": {
      "label": "API Backend", 
      "visibility": "private"
    }
  }
}
```

### 🎛️ **Gestión Avanzada de Sesiones**

#### 🔄 **Cambio Fluido Entre Entornos**

```bash
#!/bin/bash
# scripts/session-manager.sh

function switch_to_local() {
    echo "🏠 Cambiando a entorno local..."
    # Sincronizar cambios
    git add . && git commit -m "Sync from codespace" && git push
    # Cerrar conexión remota
    code --command workbench.action.remote.close
}

function switch_to_codespace() {
    echo "☁️ Cambiando a Codespace..."
    # Pull últimos cambios
    git pull
    # Conectar a Codespace
    gh codespace code
}

function sync_settings() {
    echo "⚙️ Sincronizando configuraciones..."
    # Subir settings a gist privado
    gh gist create ~/.vscode/settings.json --secret
}
```

### 📊 **Dashboard de Conexiones**

```bash
#!/bin/bash
# scripts/connection-dashboard.sh

echo "🌐 DASHBOARD DE CONEXIONES CODESPACES"
echo "===================================="
echo "📅 $(date)"
echo

# Estado actual de conexiones
echo "🔌 ESTADO ACTUAL:"
current_remote=$(code --status | grep -o "Remote.*")
if [ -n "$current_remote" ]; then
    echo "- VS Code: Conectado ($current_remote)"
else
    echo "- VS Code: Local"
fi

# Codespaces activos
echo
echo "🟢 CODESPACES ACTIVOS:"
gh codespace list --state Active --json name,machine,lastUsedAt | \
  jq -r '.[] | "- \(.name) (\(.machine.displayName)) - Activo desde: \(.lastUsedAt)"'

# Historial de conexiones recientes
echo
echo "📈 CONEXIONES RECIENTES (últimas 24h):"
gh codespace list --json name,lastUsedAt | \
  jq -r --arg day_ago "$(date -d '24 hours ago' --iso-8601)" \
  '.[] | select(.lastUsedAt > $day_ago) | "- \(.name): \(.lastUsedAt)"' | \
  sort -r | head -5

# Recomendaciones
echo
echo "💡 RECOMENDACIONES:"
active_count=$(gh codespace list --state Active --json name | jq length)
if [ "$active_count" -gt 1 ]; then
    echo "⚠️  Tienes $active_count Codespaces activos"
    echo "   Considera detener los no utilizados para reducir costos"
fi

total_count=$(gh codespace list --json name | jq length)
if [ "$total_count" -gt 5 ]; then
    echo "🗑️  Tienes $total_count Codespaces totales"
    echo "   Considera eliminar los antiguos"
fi
```

## 💰 Modelo de Precios

### ⚠️ Importante: Copilot Pro ≠ Codespaces
**GitHub Copilot Pro NO incluye Codespaces gratuitos.** Son servicios separados con facturación independiente.

### 🆓 Límites Gratuitos (Cuentas Personales)
- **120 horas/mes** con máquinas de 2-core
- **15 GB-mes** de almacenamiento
- Incluye prebuilds básicos

### 💸 Costos Después del Límite Gratuito

| Tipo de Máquina | Cores | RAM | Costo/Hora (USD) | Uso Recomendado |
|-----------------|-------|-----|------------------|------------------|
| Basic           | 2     | 8GB | ~$0.18          | Desarrollo básico |
| Standard        | 4     | 16GB| ~$0.36          | Proyectos medianos |
| Large           | 8     | 32GB| ~$0.72          | ML/Data Science |
| Extra Large     | 32    | 64GB| ~$1.44          | CI/CD intensivo |

**Almacenamiento**: ~$0.07/GB por mes

### 📊 Calculadora de Costos Estimados

```bash
# Script para calcular costos estimados
#!/bin/bash
echo "=== Calculadora de Costos Codespaces ==="
read -p "Horas de uso diarias: " daily_hours
read -p "Días de trabajo por mes: " work_days
read -p "Tipo de máquina (2|4|8|32 cores): " cores

# Tarifas por hora según cores
case $cores in
    2) rate=0.18 ;;
    4) rate=0.36 ;;
    8) rate=0.72 ;;
    32) rate=1.44 ;;
    *) echo "Cores no válidos"; exit 1 ;;
esac

monthly_hours=$((daily_hours * work_days))
free_hours=120
billable_hours=$((monthly_hours > free_hours ? monthly_hours - free_hours : 0))
monthly_cost=$(echo "$billable_hours * $rate" | bc -l)

echo "📊 Resumen de Costos:"
echo "- Horas totales/mes: $monthly_hours"
echo "- Horas gratuitas: $free_hours"
echo "- Horas facturables: $billable_hours"
echo "- Costo estimado/mes: \$$(printf '%.2f' $monthly_cost)"
```

## 🔧 Gestión de Máquinas

### 📋 Verificar Configuración Actual

```bash
# Ver todos los Codespaces
gh codespace list

# Ver detalles específicos
gh api user/codespaces --jq '.codespaces[] | {name, machine: .machine.name, state, last_used_at}'

# Ver uso de recursos en tiempo real
gh codespace ssh -- 'htop'
```

### 🔄 Cambio de Tipo de Máquina

#### Impactos del Cambio:
- ✅ **Datos preservados**: Archivos y configuración se mantienen
- ⚠️ **Costo diferente**: Facturación cambia según la nueva máquina
- ⚠️ **Reinicio requerido**: El Codespace se reinicia al cambiar
- 🔄 **Tiempo de cambio**: ~2-5 minutos dependiendo del tamaño

#### Configuración en DevContainer:

```json
// .devcontainer/devcontainer.json
{
  "name": "Mi Proyecto Optimizado",
  "hostRequirements": {
    "cpus": 2,
    "memory": "8gb",
    "storage": "32gb"
  },
  "customizations": {
    "codespaces": {
      "machines": {
        "premiumLinux": "standardLinux32gb"
      }
    }
  },
  "postCreateCommand": "echo 'Configuración optimizada para costos' && npm install"
}
```

### 🎯 Recomendaciones por Tipo de Proyecto

```bash
# Para desarrollo web básico
echo '{
  "hostRequirements": {
    "cpus": 2,
    "memory": "8gb"
  }
}' > .devcontainer/machine-config.json

# Para proyectos con Docker
echo '{
  "hostRequirements": {
    "cpus": 4,
    "memory": "16gb"
  }
}' > .devcontainer/machine-config.json

# Para ML/Data Science
echo '{
  "hostRequirements": {
    "cpus": 8,
    "memory": "32gb"
  }
}' > .devcontainer/machine-config.json
```

## 📊 Monitoreo y Control

### 🔍 Verificar Uso Actual

```bash
# Script de monitoreo de costos
#!/bin/bash
# scripts/monitor-costs.sh

echo "=== Monitoreo de Codespaces ==="
echo "📅 $(date)"
echo

# Codespaces activos (consumen recursos)
echo "🟢 ACTIVOS (Facturándose):"
gh codespace list --state Active --json name,machine,lastUsedAt | \
  jq -r '.[] | "- \(.name) (\(.machine.displayName)) - Último uso: \(.lastUsedAt)"'

echo

# Codespaces disponibles pero no activos
echo "🟡 DISPONIBLES (Sin facturar):"
gh codespace list --state Available --json name,lastUsedAt | \
  jq -r '.[] | "- \(.name) - Último uso: \(.lastUsedAt)"'

echo

# Advertencia de costos
active_count=$(gh codespace list --state Active --json name | jq length)
if [ $active_count -gt 1 ]; then
    echo "⚠️  ADVERTENCIA: Tienes $active_count Codespaces activos"
    echo "   Considera detener los que no estés usando"
fi
```

### ⏹️ Gestión de Codespaces

```bash
# Detener un Codespace específico
gh codespace stop -c CODESPACE_NAME

# Detener todos los Codespaces activos
gh codespace list --state Active --json name | \
  jq -r '.[].name' | \
  xargs -I {} gh codespace stop -c {}

# Eliminar Codespaces no utilizados (>7 días)
#!/bin/bash
echo "🗑️ Codespaces antiguos (>7 días):"
gh codespace list --json name,lastUsedAt | \
  jq -r --arg week_ago "$(date -d '7 days ago' --iso-8601)" \
  '.[] | select(.lastUsedAt < $week_ago) | .name'

# Después de revisar, eliminar manualmente:
# gh codespace delete -c CODESPACE_NAME
```

### ⏰ Configurar Auto-Suspend

```bash
# Configurar timeout de inactividad
gh api user/codespaces/CODESPACE_NAME \
  -f idle_timeout_minutes="15"  # 15 minutos para desarrollo activo

# Para proyectos de larga duración
gh api user/codespaces/CODESPACE_NAME \
  -f idle_timeout_minutes="60"  # 1 hora para análisis de datos
```

## 🏆 Mejores Prácticas

### 1. 🎯 Optimización de Recursos

```bash
# .devcontainer/optimize-resources.sh
#!/bin/bash

echo "🚀 Optimizando recursos para reducir costos..."

# Limpiar paquetes innecesarios
apt autoremove -y
apt autoclean

# Configurar npm para reducir uso de memoria
npm config set fund false
npm config set audit false

# Configurar Python para optimizar memoria
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

echo "✅ Optimización completada"
```

### 2. 📝 Script de Setup Eficiente

```bash
#!/bin/bash
# .devcontainer/setup-efficient.sh

echo "⚡ Setup eficiente iniciado..."

# Instalar solo dependencias esenciales
pip install --no-cache-dir -r requirements-minimal.txt

# Precompilar assets si es necesario
if [ -f "package.json" ]; then
    npm ci --omit=dev  # Solo dependencias de producción
fi

# Configurar herramientas de desarrollo ligeras
git config --global core.preloadindex true
git config --global core.fscache true

echo "✅ Setup eficiente completado en $(date)"
```

### 3. 🔄 Gestión Proactiva

```bash
#!/bin/bash
# scripts/daily-cleanup.sh

echo "🧹 Limpieza diaria de Codespaces..."

# Verificar Codespaces antiguos
old_codespaces=$(gh codespace list --json name,lastUsedAt | \
  jq -r --arg three_days_ago "$(date -d '3 days ago' --iso-8601)" \
  '.[] | select(.lastUsedAt < $three_days_ago) | .name')

if [ -n "$old_codespaces" ]; then
    echo "📋 Codespaces sin usar por 3+ días:"
    echo "$old_codespaces"
    echo "💡 Considera eliminarlos para reducir costos"
fi

# Detener Codespaces activos no utilizados recientemente
gh codespace list --state Active --json name,lastUsedAt | \
  jq -r --arg one_hour_ago "$(date -d '1 hour ago' --iso-8601)" \
  '.[] | select(.lastUsedAt < $one_hour_ago) | .name' | \
  while read -r name; do
    echo "⏹️ Deteniendo Codespace inactivo: $name"
    gh codespace stop -c "$name"
  done
```

## 💡 Optimización Financiera

### 📋 Configuración de Prebuilds

```yaml
# .github/workflows/codespaces-prebuilds.yml
name: Optimize Codespaces Prebuilds
on:
  push:
    branches: [main]
    paths: ['.devcontainer/**', 'requirements.txt', 'package.json']

jobs:
  createPrebuilds:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger optimized prebuild
        run: |
          gh api repos/${{ github.repository }}/codespaces/prebuilds \
            -f ref="${{ github.ref }}" \
            -f devcontainer_path=".devcontainer/devcontainer.json" \
            -f machine="standardLinux"  # Usar máquina básica para prebuilds
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 🎛️ Configurar Límites de Gasto

```bash
# Configurar límite de gasto mensual
gh api user/codespaces/billing \
  -f spending_limit="50" \
  -f included_minutes_used_action="block"

# Verificar configuración actual
gh api user/codespaces/billing
```

### 📊 Dashboard de Uso Personalizado

```bash
#!/bin/bash
# scripts/cost-dashboard.sh

echo "📊 DASHBOARD DE COSTOS CODESPACES"
echo "================================="
echo "📅 $(date)"
echo

# Información de facturación actual
echo "💰 FACTURACIÓN ACTUAL:"
gh api user/codespaces/billing | jq -r '
  "- Límite de gasto: $" + (.spending_limit // "ilimitado") + "/mes",
  "- Horas incluidas usadas: " + (.included_minutes_used // 0 | tostring),
  "- Acción al exceder: " + (.included_minutes_used_action // "none")'

echo

# Resumen de máquinas en uso
echo "🖥️ MÁQUINAS EN USO:"
gh codespace list --json name,machine,state | jq -r '
  group_by(.machine.name) | 
  .[] | 
  "- " + .[0].machine.displayName + ": " + (length | tostring) + " codespace(s)"'

echo

# Estimación de costos del día
echo "📈 ESTIMACIÓN HOY:"
active_time=$(gh codespace list --state Active --json lastUsedAt | \
  jq -r --arg now "$(date --iso-8601)" \
  '[.[] | select(.lastUsedAt > ($now | split("T")[0] + "T00:00:00Z"))] | length')
echo "- Horas activas estimadas hoy: $active_time"
echo "- Costo estimado del día: \$$(echo "$active_time * 0.18" | bc -l | head -c 5)"
```

## 🛠️ Troubleshooting

### ❓ Problemas Comunes

#### 1. "No puedo conectarme a mi Codespace"

```bash
# Verificar estado del Codespace
gh codespace list --json name,state | jq -r '.[] | "\(.name): \(.state)"'

# Si está "Shutdown", iniciarlo
gh codespace start --codespace NAME

# Verificar conectividad
gh codespace ssh --codespace NAME -- echo "Conexión exitosa"

# Reiniciar Codespace si hay problemas persistentes
gh codespace stop --codespace NAME
gh codespace start --codespace NAME
```

#### 2. "VS Code Desktop no encuentra mi Codespace"

```bash
# Verificar extensión instalada
code --list-extensions | grep GitHub.codespaces

# Instalar si no está presente
code --install-extension GitHub.codespaces

# Refrescar lista desde Command Palette
# Ctrl+Shift+P → "Developer: Reload Window"
# Ctrl+Shift+P → "Codespaces: Connect to Codespace"
```

#### 3. "Rendimiento lento en browser vs desktop"

```bash
# Optimizar configuración del navegador
# 1. Cerrar otras pestañas
# 2. Desactivar extensiones innecesarias
# 3. Usar Chrome/Edge para mejor compatibilidad

# Configurar VS Code para browser
echo '{
  "terminal.integrated.gpuAcceleration": "off",
  "editor.smoothScrolling": false,
  "editor.fastScrollSensitivity": 5
}' > .vscode/settings.json
```

#### 4. "Mi factura es más alta de lo esperado"

```bash
# Investigar uso detallado
echo "🔍 Investigando uso elevado..."

# Verificar Codespaces que estuvieron activos por mucho tiempo
gh api user/codespaces --jq '
  .codespaces[] | 
  select(.state == "Available") | 
  {name, last_used: .last_used_at, created: .created_at}'

# Buscar patrones de uso
echo "📊 Patrón de uso reciente:"
gh codespace list --json name,lastUsedAt | \
  jq -r 'sort_by(.lastUsedAt) | reverse | .[:5] | .[] | 
  "- " + .name + ": " + .lastUsedAt'
```

#### 2. "No puedo cambiar el tipo de máquina"

```bash
# Verificar restricciones de la organización
gh api user/codespaces/machines

# Verificar configuración del repositorio
gh api repos/OWNER/REPO/codespaces/machines
```

#### 3. "Los prebuilds no están funcionando"

```bash
# Verificar estado de prebuilds
gh api repos/OWNER/REPO/codespaces/prebuilds

# Triggerar prebuild manual
gh api repos/OWNER/REPO/codespaces/prebuilds \
  -f ref="main" \
  -f devcontainer_path=".devcontainer/devcontainer.json"
```

#### 5. "Tengo múltiples sesiones y no sé cuáles cerrar"

```bash
# Auditar todas las sesiones activas
#!/bin/bash
echo "🔍 AUDITORÍA DE SESIONES"

# Verificar qué Codespaces están realmente activos
gh codespace list --state Active --json name,lastUsedAt,machine | \
  jq -r '.[] | 
  "🟢 " + .name + " (" + .machine.displayName + ") - Último uso: " + 
  (.lastUsedAt | strftime("%Y-%m-%d %H:%M"))'

echo
echo "💡 Recomendación: Detén los que no hayas usado en las últimas 2 horas"

# Identificar sesiones zombi
gh codespace list --state Active --json name,lastUsedAt | \
  jq -r --arg two_hours_ago "$(date -d '2 hours ago' --iso-8601)" \
  '.[] | select(.lastUsedAt < $two_hours_ago) | 
  "⚠️ Candidato a detener: " + .name'
```

#### 6. "No puedo acceder desde mi tablet/móvil"

```bash
# Verificar que el Codespace esté ejecutándose
gh codespace list --state Active

# Obtener URL directa para navegador
gh codespace list --json name,webUrl | \
  jq -r '.[] | "📱 " + .name + ": " + .webUrl'

# Para acceso optimizado en móvil:
# 1. Usar github.dev para edición rápida
# 2. Usar github.com/codespaces para gestión
# 3. Evitar tareas intensivas en móvil
```

#### 7. "Remote Tunnels interfiere con Codespaces"

```bash
# Deshabilitar Remote Tunnels cuando uses Codespaces
echo '{
  "remote.tunnels.access.enablePublic": false,
  "remote.tunnels.access.host": "disabled",
  "remote.tunnels.access.preventSleep": false
}' > .vscode/settings.json

# Verificar conflictos de puerto
netstat -tulpn | grep :3000  # Ejemplo para puerto 3000

# Limpiar configuración de tunnels
rm -rf ~/.config/code-server/
```

#### 8. "Port forwarding no funciona"

```bash
# Verificar puertos configurados
gh codespace ports --codespace NAME

# Forzar forward de puerto específico
gh codespace ports forward 3000:3000 --codespace NAME

# Verificar en devcontainer.json
cat .devcontainer/devcontainer.json | jq '.forwardPorts'

# Debug de conectividad
curl -I http://localhost:3000  # Desde dentro del Codespace
```

### 🚨 Alertas y Notificaciones

```bash
#!/bin/bash
# scripts/cost-alerts.sh

# Configurar alertas via webhook (opcional)
WEBHOOK_URL="https://hooks.slack.com/your-webhook"
SPENDING_THRESHOLD=40  # USD

current_spending=$(gh api user/codespaces/billing | jq -r '.spending_limit')

if [ "$current_spending" -gt "$SPENDING_THRESHOLD" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"⚠️ Codespaces: Gasto actual \$${current_spending} excede el umbral de \$${SPENDING_THRESHOLD}\"}" \
        "$WEBHOOK_URL"
fi
```

## 📝 Checklist de Optimización de Costos

### Configuración Inicial
- [ ] Configurar auto-suspend a 15-30 minutos
- [ ] Definir `hostRequirements` apropiados en devcontainer.json
- [ ] Establecer límite de gasto mensual
- [ ] Configurar prebuilds para proyectos frecuentes
- [ ] Instalar extensión GitHub.codespaces en VS Code Desktop
- [ ] Deshabilitar Remote Tunnels si usas Codespaces

### Gestión Diaria
- [ ] Revisar Codespaces activos antes de cerrar sesión
- [ ] Usar "Close Remote Connection" en vez de cerrar VS Code
- [ ] Detener Codespaces completamente al terminar el día
- [ ] Verificar que no hay sesiones zombi ejecutándose
- [ ] Usar la máquina más pequeña posible para cada tarea
- [ ] Monitorear tiempo de uso activo

### Gestión de Conexiones
- [ ] Cerrar sesiones browser cuando uses VS Code Desktop
- [ ] Verificar semanalmente conexiones activas con `gh codespace list`
- [ ] Optimizar configuraciones de rendimiento para browser
- [ ] Documentar flujo de trabajo entre dispositivos

### Gestión Semanal
- [ ] Revisar facturación acumulada
- [ ] Eliminar Codespaces antiguos no utilizados
- [ ] Optimizar configuraciones de devcontainer
- [ ] Evaluar necesidad de máquinas más grandes

### Gestión Mensual
- [ ] Analizar reporte de facturación completo
- [ ] Ajustar límites de gasto si es necesario
- [ ] Optimizar prebuilds y configuraciones
- [ ] Documentar lecciones aprendidas

## 🔗 Enlaces Útiles

- [📊 Portal de Facturación GitHub](https://github.com/settings/billing)
- [📖 Documentación Oficial de Precios](https://docs.github.com/en/billing/managing-billing-for-github-codespaces)
- [🛠️ GitHub CLI - Codespaces](https://cli.github.com/manual/gh_codespace)
- [⚙️ Configuración de DevContainer](https://containers.dev/)
- [🖥️ VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [🌐 GitHub.dev Documentation](https://docs.github.com/en/codespaces/developing-in-codespaces/web-based-editor)
- [🔌 Port Forwarding Guide](https://docs.github.com/en/codespaces/developing-in-codespaces/forwarding-ports-in-your-codespace)

---

**💡 Tip Final**: La gestión proactiva de costos puede mantener la mayoría de proyectos de desarrollo dentro del tier gratuito. Monitorea regularmente y ajusta según tus patrones de uso reales.
