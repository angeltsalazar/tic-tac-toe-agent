from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
import json
import logging
import uvicorn
import os

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Tic-Tac-Toe Game")

# Obtener directorios
current_dir = os.path.dirname(os.path.abspath(__file__))
static_dir = os.path.join(current_dir, "static")
client_dir = os.path.join(current_dir, "..", "client")

# Montar archivos estáticos
if os.path.exists(static_dir):
    app.mount("/static", StaticFiles(directory=static_dir), name="static")

@app.get("/")
async def root():
    index_path = os.path.join(client_dir, 'index.html')
    if os.path.exists(index_path):
        return FileResponse(index_path)
    else:
        return HTMLResponse("<h1>Tic-Tac-Toe Server Running!</h1><p>Client files not found, but server is working.</p>")

@app.get("/health")
async def health():
    return {
        "status": "OK",
        "platform": "Linux",
        "server_dir": current_dir,
        "static_dir_exists": os.path.exists(static_dir),
        "client_dir_exists": os.path.exists(client_dir)
    }

# Simple WebSocket endpoint para testing
@app.websocket("/test")
async def websocket_test(websocket: WebSocket):
    await websocket.accept()
    await websocket.send_json({"message": "WebSocket conectado correctamente!"})
    try:
        while True:
            data = await websocket.receive_text()
            await websocket.send_json({"echo": data})
    except WebSocketDisconnect:
        logger.info("Cliente desconectado del WebSocket de prueba")

if __name__ == "__main__":
    logger.info("🚀 Iniciando servidor Tic-Tac-Toe simplificado...")
    uvicorn.run(
        "simple_server:app",
        host="0.0.0.0",
        port=8000,
        reload=False,
        log_level="info"
    )
