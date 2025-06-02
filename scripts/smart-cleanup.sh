#!/bin/bash
# 🎯 Script de limpieza inteligente para proyecto Tic-Tac-Toe
# Identifica y desinstala extensiones no relevantes para este proyecto específico

echo "🎯 Limpieza inteligente de extensiones para proyecto Python/Tic-Tac-Toe..."

# Obtener lista actual de extensiones
INSTALLED_EXTENSIONS=$(code --list-extensions 2>/dev/null || true)

if [ -z "$INSTALLED_EXTENSIONS" ]; then
    echo "⚠️  No se pudo obtener la lista de extensiones"
    echo "💡 Asegúrate de estar ejecutando desde VS Code conectado al Codespace"
    exit 0
fi

# Limpiar la lista (remover header si existe)
CLEAN_EXTENSIONS=$(echo "$INSTALLED_EXTENSIONS" | grep -E "^[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+$" || echo "$INSTALLED_EXTENSIONS")

echo "📊 Extensiones instaladas: $(echo "$CLEAN_EXTENSIONS" | wc -l)"

# Extensiones ESENCIALES para este proyecto (NO remover)
ESSENTIAL_EXTENSIONS=(
    "ms-python.python"
    "ms-python.pylint" 
    "ms-python.black-formatter"
    "ms-python.debugpy"
    "ms-python.vscode-pylance"
    "ms-python.autopep8"
    "github.copilot"
    "github.copilot-chat"
    "github.codespaces"
    "ms-vscode.vscode-json"
    "eamodio.gitlens"
    "github.vscode-pull-request-github"
    "github.github-vscode-theme"
)

# Extensiones INNECESARIAS para proyecto Python puro
UNNECESSARY_EXTENSIONS=()

echo ""
echo "🔍 Analizando extensiones innecesarias para proyecto Python..."

# Analizar cada extensión instalada
while IFS= read -r extension; do
    if [[ -z "$extension" ]]; then
        continue
    fi
    
    # Verificar si es esencial
    is_essential=false
    for essential in "${ESSENTIAL_EXTENSIONS[@]}"; do
        if [[ "$extension" == "$essential" ]]; then
            is_essential=true
            break
        fi
    done
    
    if [[ "$is_essential" == "true" ]]; then
        continue
    fi
    
    # Categorizar extensiones innecesarias
    case "$extension" in
        # Frontend/JavaScript/TypeScript
        *typescript* | *javascript* | *react* | *vue* | *angular* | *prettier* | *eslint* | *tailwind*)
            echo "   🟡 Frontend: $extension"
            UNNECESSARY_EXTENSIONS+=("$extension")
            ;;
        # Otros lenguajes
        *golang* | *rust* | *csharp* | *dotnet* | *java* | *kotlin* | *swift*)
            echo "   🟠 Otro lenguaje: $extension"
            UNNECESSARY_EXTENSIONS+=("$extension")
            ;;
        # PHP
        *php* | *intelephense* | *phpfmt*)
            echo "   🟣 PHP: $extension"
            UNNECESSARY_EXTENSIONS+=("$extension")
            ;;
        # Bases de datos avanzadas (para proyecto simple)
        *postgres* | *mongodb* | *redis* | *oracle*)
            echo "   🔵 BD avanzada: $extension"
            UNNECESSARY_EXTENSIONS+=("$extension")
            ;;
        # Solidity/Blockchain
        *solidity* | *blockchain*)
            echo "   🟤 Blockchain: $extension"
            UNNECESSARY_EXTENSIONS+=("$extension")
            ;;
        # Testing frameworks específicos (no nativos Python)
        *jest* | *mocha* | *jasmine*)
            echo "   🧪 Testing JS: $extension"
            UNNECESSARY_EXTENSIONS+=("$extension")
            ;;
        # Herramientas pesadas innecesarias
        *kubernetes* | *terraform* | *ansible*)
            echo "   ⚙️ DevOps pesado: $extension"
            UNNECESSARY_EXTENSIONS+=("$extension")
            ;;
        # Extensiones de productividad que pueden distraer
        *vim* | *emacs* | *wordcount* | *bookmarks*)
            echo "   📝 Productividad: $extension"
            # UNNECESSARY_EXTENSIONS+=("$extension")  # Comentado, pueden ser útiles
            ;;
        # Temas redundantes (dejar solo uno)
        *theme* | *icon*)
            if [[ "$extension" != "github.github-vscode-theme" && "$extension" != "pkief.material-icon-theme" ]]; then
                echo "   🎨 Tema extra: $extension"
                UNNECESSARY_EXTENSIONS+=("$extension")
            fi
            ;;
        # SQL tools específicos para BD que no usamos
        *sqltools*)
            echo "   🗄️ SQL tools: $extension"
            UNNECESSARY_EXTENSIONS+=("$extension")
            ;;
        *)
            # Las demás extensiones las dejamos (pueden ser útiles)
            ;;
    esac
    
done <<< "$CLEAN_EXTENSIONS"

echo ""
echo "📋 Resumen del análisis:"
echo "   ✅ Extensiones esenciales: ${#ESSENTIAL_EXTENSIONS[@]}"
echo "   ⚠️  Extensiones innecesarias detectadas: ${#UNNECESSARY_EXTENSIONS[@]}"

if [ ${#UNNECESSARY_EXTENSIONS[@]} -eq 0 ]; then
    echo ""
    echo "✨ ¡Perfecto! No se detectaron extensiones innecesarias"
    echo "🎯 Tu configuración está optimizada para este proyecto"
    exit 0
fi

echo ""
echo "🗑️  Extensiones marcadas para desinstalación:"
for ext in "${UNNECESSARY_EXTENSIONS[@]}"; do
    echo "   - $ext"
done

echo ""
read -p "¿Desinstalar estas extensiones? [y/N]: " CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo ""
    echo "🧹 Desinstalando extensiones innecesarias..."
    
    REMOVED_COUNT=0
    for extension in "${UNNECESSARY_EXTENSIONS[@]}"; do
        echo "   ❌ Desinstalando: $extension"
        if code --uninstall-extension "$extension" >/dev/null 2>&1; then
            ((REMOVED_COUNT++))
            echo "   ✅ Desinstalado: $extension"
        else
            echo "   ⚠️  Error al desinstalar: $extension"
        fi
    done
    
    echo ""
    echo "✅ Limpieza completada: $REMOVED_COUNT extensiones desinstaladas"
    echo "📊 Extensiones restantes: $(code --list-extensions 2>/dev/null | wc -l)"
    echo ""
    echo "🔄 Reinicia VS Code para que los cambios surtan efecto completo"
    
else
    echo ""
    echo "ℹ️  Limpieza cancelada. Las extensiones se mantienen instaladas."
fi

echo ""
echo "💡 Para prevenir instalaciones futuras:"
echo "   - Las configuraciones en .vscode/settings.json están activas"
echo "   - El archivo .vscode/extensions.json define las recomendadas"
echo "   - Considera desactivar sync de extensiones en VS Code local"
