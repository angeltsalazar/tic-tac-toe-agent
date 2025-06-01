# 🌐 Encontrar tu URL de GitHub Codespaces

## 🎯 Pasos Rápidos

### 1️⃣ Método Automático (Recomendado)
```bash
# Ejecuta este comando en la terminal:
echo "Tu URL del juego es: https://$(echo $CODESPACE_NAME)-8000.app.github.dev/"
```

### 2️⃣ Método Manual

**Paso 1:** Mira la URL actual en tu navegador
Ejemplo: `https://super-duper-space-fortnight-w5ww5xqrwhwx9.github.dev`

**Paso 2:** Toma la parte antes de `.github.dev` 
Ejemplo: `super-duper-space-fortnight-w5ww5xqrwhwx9`

**Paso 3:** Construye la URL del juego:
```
https://[nombre-de-tu-codespace]-8000.app.github.dev/
```

**Resultado final:**
```
https://super-duper-space-fortnight-w5ww5xqrwhwx9-8000.app.github.dev/
```

## 🚀 Script de Inicio Completo

```bash
#!/bin/bash
echo "🎮 INICIANDO TIC-TAC-TOE CON IA"
echo "================================="
echo ""
echo "📂 Cambiando al directorio del servidor..."
cd /workspaces/tic-tac-toe-agent/server

echo "🌐 Tu URL del juego es:"
echo "https://$(echo $CODESPACE_NAME)-8000.app.github.dev/"
echo ""
echo "🚀 Iniciando servidor..."
python server.py
```

## 📋 Checklist de Verificación

- [ ] ✅ El servidor está ejecutándose (`python server.py`)
- [ ] 🌐 Usas la URL de Codespaces (NO `localhost:8000`)
- [ ] 🔗 La URL incluye `-8000` antes de `.app.github.dev`
- [ ] 🌍 Usas `https://` (NO `http://`)

## 🆘 Si Nada Funciona

1. **Reinicia el servidor:**
   ```bash
   # Presiona Ctrl+C para detener, luego:
   python server.py
   ```

2. **Verifica la variable de entorno:**
   ```bash
   echo $CODESPACE_NAME
   ```

3. **Usa el panel PORTS:**
   - Ve al panel "PORTS" en la parte inferior de VS Code
   - Busca puerto `8000`
   - Haz clic en el ícono 🌐 para abrir

## 🔍 Debugging URLs

Si quieres ver todas las variables de entorno relacionadas con Codespaces:
```bash
env | grep CODESPACE
```

Esto te mostrará:
- `CODESPACE_NAME` - Nombre de tu Codespace
- `GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN` - Dominio base
- Y otras variables útiles
