from fastapi import FastAPI, WebSocket, Query, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from game_logic import TicTacToeGame
from game_agent import router as agent_router, check_winner
from ollama_integration import tic_tac_toe_ai, ollama_client
from config import Config
import json
import logging
import uvicorn

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# Add CORS middleware to allow requests from the web client
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with your actual frontend origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include the routes from game_agent.py
app.include_router(agent_router)

import os
# Obtener el directorio actual del script
current_dir = os.path.dirname(os.path.abspath(__file__))
static_dir = os.path.join(current_dir, "static")
client_dir = os.path.join(current_dir, "..", "client")

app.mount("/static", StaticFiles(directory=static_dir), name="static")

@app.get('/favicon.ico', include_in_schema=False)
async def favicon():
    favicon_path = os.path.join(client_dir, 'favicon.ico')
    if os.path.exists(favicon_path):
        return FileResponse(favicon_path)
    else:
        return {"error": "Favicon not found"}

@app.get('/', include_in_schema=False)
async def root():
    index_path = os.path.join(client_dir, 'index.html')
    if os.path.exists(index_path):
        return FileResponse(index_path)
    else:
        return {"error": "Index file not found"}

@app.get('/debug', include_in_schema=False)
async def debug():
    debug_path = os.path.join(current_dir, "..", 'debug.html')
    if os.path.exists(debug_path):
        return FileResponse(debug_path)
    else:
        return {"error": "Debug file not found"}

@app.get('/test', include_in_schema=False)
async def test():
    test_path = os.path.join(current_dir, "..", 'test-simple.html')
    if os.path.exists(test_path):
        return FileResponse(test_path)
    else:
        return {"error": "Test file not found"}

@app.get('/test-forced', include_in_schema=False)
async def test_forced():
    test_path = os.path.join(current_dir, "..", 'test-forced.html')
    if os.path.exists(test_path):
        return FileResponse(test_path)
    else:
        return {"error": "Test forced file not found"}

@app.get('/test-reset', include_in_schema=False)
async def test_reset():
    test_path = os.path.join(current_dir, "..", 'test-reset.html')
    if os.path.exists(test_path):
        return FileResponse(test_path)
    else:
        return {"error": "Test reset file not found"}

@app.get('/test-gameover', include_in_schema=False)
async def test_gameover():
    test_path = os.path.join(current_dir, "..", 'test-gameover.html')
    if os.path.exists(test_path):
        return FileResponse(test_path)
    else:
        return {"error": "Test gameover file not found"}

@app.get('/simple', include_in_schema=False)
async def simple():
    simple_path = os.path.join(client_dir, 'index-simple.html')
    if os.path.exists(simple_path):
        return FileResponse(simple_path)
    else:
        return {"error": "Simple index file not found"}

@app.get('/forced', include_in_schema=False)
async def forced():
    forced_path = os.path.join(current_dir, "..", 'test-forced.html')
    if os.path.exists(forced_path):
        return FileResponse(forced_path)
    else:
        return {"error": "Forced test file not found"}

# Diccionario para almacenar los juegos por conexión
games = {}

@app.websocket("/game")
async def websocket_endpoint(websocket: WebSocket, size: int = Query(3, ge=3, le=9)):
    await websocket.accept()
    # Crear juego con jugador X siempre como inicial
    game = TicTacToeGame(size=size, current_player='X')
    games[websocket] = game
    logger.info(f"Nueva conexión WebSocket establecida. Tamaño del tablero: {size}")
    
    try:
        # Enviar el estado inicial del juego al cliente
        initial_state = {
            "type": "game_state",
            "board": game.board,
            "current_player": game.current_player,
            "size": game.size
        }
        await websocket.send_json(initial_state)
        logger.info(f"Estado inicial enviado: {initial_state}")

        while True:
            data = await websocket.receive_json()
            logger.info(f"Mensaje recibido del cliente: {data}")
            
            if data["type"] == "player_move":
                if game.game_over:
                    logger.info("Juego ya terminado, ignorando movimiento")
                    continue
                    
                position = data["position"]
                logger.info(f"Intento de movimiento en posición {position}")
                
                if game.make_move(position):
                    logger.info(f"Movimiento válido del jugador en posición {position}")
                    
                    # Enviar actualización después del movimiento del jugador
                    player_move_state = {
                        "type": "game_state",
                        "board": game.board,
                        "current_player": game.current_player,
                        "size": game.size
                    }
                    await websocket.send_json(player_move_state)
                    logger.info(f"Estado actualizado enviado después del movimiento del jugador: {player_move_state}")
                    
                    # Verificar si hay ganador después del movimiento del jugador
                    winner = check_winner(game.board, game.size)
                    if winner is not None:
                        game.game_over = True
                        # Determinar si se usó IA en este juego
                        is_ai_used = await ollama_client.is_available()
                        await websocket.send_json({
                            "type": "game_over",
                            "winner": winner,
                            "ai_used": is_ai_used
                        })
                        logger.info(f"Juego terminado. Ganador: {winner}. IA usada: {is_ai_used}")
                        continue
                    
                    # Obtener movimiento del agente usando IA + Ollama
                    if not game.game_over:
                        logger.info("Solicitando movimiento del agente IA...")
                        try:
                            agent_position = await tic_tac_toe_ai.make_move(
                                game.board, 
                                game.current_player
                            )
                            
                            if agent_position != -1:
                                logger.info(f"Agente IA eligió la posición {agent_position}")
                                is_ai_used = await ollama_client.is_available()
                                logger.info(f"Usando {'Ollama AI' if is_ai_used else 'Minimax fallback'}")
                                
                                game.make_move(agent_position)
                                
                                # Enviar actualización después del movimiento del agente
                                agent_move_state = {
                                    "type": "game_state",
                                    "board": game.board,
                                    "current_player": game.current_player,
                                    "size": game.size,
                                    "ai_used": is_ai_used
                                }
                                await websocket.send_json(agent_move_state)
                                logger.info(f"Estado actualizado enviado después del movimiento del agente: {agent_move_state}")
                                
                                # Verificar si hay ganador después del movimiento del agente
                                winner = check_winner(game.board, game.size)
                                if winner is not None:
                                    game.game_over = True
                                    await websocket.send_json({
                                        "type": "game_over",
                                        "winner": winner,
                                        "ai_used": is_ai_used
                                    })
                                    logger.info(f"Juego terminado. Ganador: {winner}")
                            else:
                                logger.warning("Agente no pudo hacer un movimiento")
                                await websocket.send_json({
                                    "type": "error",
                                    "message": "Agente no pudo hacer un movimiento"
                                })
                        except Exception as e:
                            logger.error(f"Error en el movimiento del agente: {e}")
                            await websocket.send_json({
                                "type": "error",
                                "message": "Error interno del agente"
                            })
                else:
                    logger.warning(f"Movimiento inválido intentado en posición {position}")
                    await websocket.send_json({
                        "type": "error",
                        "message": "Movimiento inválido"
                    })
            
            elif data["type"] == "reset_game":
                logger.info(f"Reiniciando juego con tamaño {data['size']}")
                # Crear un nuevo juego completamente limpio
                new_size = data["size"]
                game = TicTacToeGame(size=new_size, current_player='X')
                game.game_over = False
                games[websocket] = game
                
                new_state = {
                    "type": "game_state",
                    "board": game.board,
                    "current_player": game.current_player,
                    "size": game.size
                }
                await websocket.send_json(new_state)
                logger.info(f"Juego reiniciado. Nuevo estado: {new_state}")
                
    except WebSocketDisconnect:
        logger.info("Cliente desconectado")
    except Exception as e:
        logger.error(f"Error en la conexión WebSocket: {str(e)}", exc_info=True)
    finally:
        if websocket in games:
            del games[websocket]
        await websocket.close()

@app.get("/health")
async def health_check():
    """Endpoint de health check para verificar que el servidor está funcionando"""
    platform_info = Config.get_platform_info()
    return {
        "status": "OK",
        "platform": platform_info,
        "ollama_url": Config.get_ollama_url()
    }

@app.get("/ollama-status")
async def ollama_status():
    """Endpoint para verificar el estado de Ollama"""
    try:
        is_available = await ollama_client.is_available()
        models = await ollama_client.list_models() if is_available else []
        
        return {
            "ollama_available": is_available,
            "ollama_url": Config.get_ollama_url(),
            "model": ollama_client.model,
            "models_available": [model.get("name", "unknown") for model in models],
            "fallback": "minimax" if not is_available else None
        }
    except Exception as e:
        logger.error(f"Error checking Ollama status: {e}")
        return {
            "ollama_available": False,
            "error": str(e),
            "fallback": "minimax"
        }

if __name__ == "__main__":
    platform_info = Config.get_platform_info()
    logger.info(f"🚀 Iniciando servidor Tic-Tac-Toe en {platform_info['system']}")
    logger.info(f"🤖 Ollama URL: {Config.get_ollama_url()}")
    logger.info(f"🌐 Servidor en: http://{Config.SERVER_HOST}:{Config.SERVER_PORT}")
    
    uvicorn.run(
        "server:app",
        host=Config.SERVER_HOST,
        port=Config.SERVER_PORT,
        reload=Config.is_development(),
        log_level="info"
    )
