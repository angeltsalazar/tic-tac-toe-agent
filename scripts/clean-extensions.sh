#!/bin/bash
# 🧹 Script de limpieza de extensiones para Codespaces
# Desinstala extensiones no deseadas que se sincronizan desde VS Code local

echo "🧹 Limpiando extensiones no deseadas en Codespace..."

# Lista de extensiones que normalmente se sincronizan pero no queremos en Codespaces
UNWANTED_EXTENSIONS=(
    # Extensiones de frontend que no necesitamos en un proyecto Python
    "bradlc.vscode-tailwindcss"
    "esbenp.prettier-vscode"
    "ms-vscode.vscode-typescript-next"
    
    # Extensiones de otros lenguajes
    "golang.go"
    "rust-lang.rust-analyzer"
    "ms-dotnettools.csharp"
    
    # Extensiones de Docker/K8s que pueden ser pesadas
    "ms-azuretools.vscode-docker"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    
    # Extensiones de temas que pueden no funcionar bien en web
    "PKief.material-icon-theme"
    "zhuangtongfa.material-theme"
    "monokai.theme-monokai-pro-vscode"
    
    # Extensiones de productividad que pueden ser distractoras
    "vscodevim.vim"
    "ms-vscode.wordcount"
)

echo "📋 Verificando extensiones instaladas..."

# Obtener lista de extensiones instaladas
INSTALLED_EXTENSIONS=$(code --list-extensions 2>/dev/null || true)

if [ -z "$INSTALLED_EXTENSIONS" ]; then
    echo "⚠️  No se pudo obtener la lista de extensiones (posiblemente ejecutándose en terminal web)"
    echo "💡 Ejecuta este script desde VS Code local conectado al Codespace"
    exit 0
fi

echo "🔍 Extensiones actualmente instaladas:"
echo "$INSTALLED_EXTENSIONS" | sed 's/^/   - /'

echo ""
echo "🗑️  Desinstalando extensiones no deseadas..."

REMOVED_COUNT=0

for extension in "${UNWANTED_EXTENSIONS[@]}"; do
    if echo "$INSTALLED_EXTENSIONS" | grep -q "^$extension$"; then
        echo "   ❌ Desinstalando: $extension"
        code --uninstall-extension "$extension" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            ((REMOVED_COUNT++))
        else
            echo "   ⚠️  Error al desinstalar: $extension"
        fi
    fi
done

echo ""
if [ $REMOVED_COUNT -gt 0 ]; then
    echo "✅ Limpieza completada: $REMOVED_COUNT extensiones desinstaladas"
    echo "🔄 Reinicia VS Code para que los cambios surtan efecto completo"
else
    echo "✨ No se encontraron extensiones no deseadas para desinstalar"
fi

echo ""
echo "💡 Para evitar que se reinstalen automáticamente:"
echo "   1. En VS Code local: Ctrl+Shift+P → 'Settings Sync: Configure'"
echo "   2. Desmarca 'Extensions' en la lista"
echo "   3. O usa el archivo .vscode/settings.json ya configurado"

echo ""
echo "📊 Extensiones restantes:"
code --list-extensions 2>/dev/null | wc -l | sed 's/^/   Total: /'
