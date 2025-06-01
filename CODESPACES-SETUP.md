# 🚀 Configuración para GitHub Codespaces

## ⚠️ IMPORTANTE: URLs y WebSockets en GitHub Codespaces

### Problema Común: "El tablero no se ve"

Si el tablero del tic-tac-toe no aparece en el navegador, **NO es un problema del código**, sino de la URL utilizada.

### ✅ Solución

**En GitHub Codespaces, NO uses `localhost:8000`**

**✅ USA la URL de Codespaces:**

#### 🔍 Patrón de URL de GitHub Codespaces:
```
https://[nombre-del-codespace]-[puerto].app.github.dev/
```

#### 📝 Componentes de la URL:
- **`nombre-del-codespace`**: Nombre generado automáticamente por GitHub (ejemplo: `super-duper-space-fortnight-w5ww5xqrwhwx9`)
- **`puerto`**: Puerto del servidor (en nuestro caso `8000`)
- **`app.github.dev`**: Dominio fijo de GitHub Codespaces

#### 🎯 Ejemplos Reales:
```
https://super-duper-space-fortnight-w5ww5xqrwhwx9-8000.app.github.dev/
https://magical-enigma-abc123xyz-8000.app.github.dev/
https://friendly-invention-def456-8000.app.github.dev/
```

#### 🚨 ¿Cómo obtener TU URL específica?

1. **Método 1 - Panel PORTS en VS Code:**
   - Ve al panel "PORTS" (Puertos) en la parte inferior
   - Busca la línea del puerto `8000`
   - Haz clic en el ícono del mundo 🌐 para abrir en el navegador
   
2. **Método 2 - Notificación automática:**
   - Cuando ejecutes `python server.py`, VS Code mostrará una notificación
   - Haz clic en "Open in Browser" / "Abrir en Navegador"

3. **Método 3 - Construir manualmente:**
   - Mira la URL actual de tu Codespace en el navegador
   - Reemplaza el final con `-8000.app.github.dev/`

### 🔧 Configuración Automática

El código JavaScript ya está configurado para detectar automáticamente GitHub Codespaces:

```javascript
// Detectar si estamos en GitHub Codespaces o localhost
const isCodespaces = window.location.hostname.includes('app.github.dev');
const wsProtocol = isCodespaces ? 'wss:' : 'ws:';
const wsHost = isCodespaces ? window.location.host : 'localhost:8000';
```

### 🚀 Inicio Rápido

1. **Iniciar el servidor:**
   ```bash
   cd /workspaces/tic-tac-toe-agent/server
   python server.py
   ```

2. **Acceder a la aplicación:**
   - VS Code mostrará una notificación para abrir en el navegador
   - O usar la URL que aparece en el panel PORTS
   - **NO usar `localhost:8000`**

### 🧪 Páginas de Prueba Disponibles

- `/` - Aplicación principal
- `/debug` - Página con logs de debugging
- `/test-forced` - Test del tablero forzado
- `/simple` - Versión simplificada

### 🐛 Troubleshooting

Si el tablero sigue sin aparecer:

1. ✅ Verificar que usas la URL de Codespaces (no localhost)
2. ✅ Comprobar que el servidor está ejecutándose
3. ✅ Revisar la consola del navegador para errores de WebSocket
4. ✅ Verificar que Ollama está ejecutándose si quieres usar IA avanzada

### 🔧 Troubleshooting URLs

#### ❓ "¿Cómo sé cuál es MI URL específica?"

**Opción A - Desde la barra de direcciones actual:**
Si estás viendo este archivo en GitHub Codespaces, tu URL actual probablemente se ve así:
```
https://[tu-codespace-name].github.dev
```

Para el juego, necesitas cambiarla a:
```
https://[tu-codespace-name]-8000.app.github.dev/
```

**Opción B - Desde el panel PORTS:**
1. Presiona `Ctrl+Shift+` ` (acento grave) para abrir terminal
2. Ve al panel "PORTS" (al lado de TERMINAL)
3. Busca el puerto `8000` 
4. Haz clic en el ícono 🌐 "Open in Browser"

#### ⚠️ Errores Comunes:

**❌ Error:** "WebSocket connection failed"
**✅ Solución:** Verifica que uses `https://` y NO `localhost`

**❌ Error:** "El tablero no carga"
**✅ Solución:** Asegúrate de que el puerto en la URL sea `-8000`

**❌ Error:** "Connection refused"
**✅ Solución:** Verifica que el servidor esté ejecutándose (`python server.py`)

### 📝 Notas Técnicas

- **WebSocket**: Usa `wss://` en Codespaces (no `ws://`)
- **Puerto**: GitHub Codespaces mapea el puerto 8000 automáticamente
- **CORS**: Configurado para permitir todas las origins
- **Archivos estáticos**: Servidos desde `/static/`

---

**Fecha de creación:** 1 de junio de 2025  
**Estado del proyecto:** ✅ Funcional en GitHub Codespaces  
**Última verificación:** Tablero visible y WebSocket funcionando
