from fastapi import FastAPI, WebSocket, Query, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from game_logic import TicTacToeGame
from game_agent import router as agent_router, make_move_endpoint, check_winner, GameState # Added GameState import
import json
import logging

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

app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get('/favicon.ico', include_in_schema=False)
async def favicon():
    return FileResponse('../client/favicon.ico')

@app.get('/', include_in_schema=False)
async def root():
    return FileResponse('../client/index.html')

# Diccionario para almacenar los juegos por conexión
games = {}

@app.websocket("/game")
async def websocket_endpoint(websocket: WebSocket, size: int = Query(3, ge=3, le=9)):
    await websocket.accept()
    game = TicTacToeGame(size=size)
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
                        await websocket.send_json({
                            "type": "game_over",
                            "winner": winner
                        })
                        logger.info(f"Juego terminado. Ganador: {winner}")
                        continue
                    
                    # Get agent's move si el juego no ha terminado
                    if not game.game_over:
                        logger.info("Solicitando movimiento del agente...")
                        # Create GameState instance for the agent
                        game_state_for_agent = GameState(
                            board=game.board,
                            current_player=game.current_player,
                            size=game.size
                        )
                        agent_response = make_move_endpoint(game_state_for_agent)
                        
                        if "position" in agent_response:
                            agent_position = agent_response["position"]
                            logger.info(f"Agente eligió la posición {agent_position}")
                            game.make_move(agent_position)
                            
                            # Enviar actualización después del movimiento del agente
                            agent_move_state = {
                                "type": "game_state",
                                "board": game.board,
                                "current_player": game.current_player,
                                "size": game.size
                            }
                            await websocket.send_json(agent_move_state)
                            logger.info(f"Estado actualizado enviado después del movimiento del agente: {agent_move_state}")
                            
                            # Verificar si hay ganador después del movimiento del agente
                            winner = check_winner(game.board, game.size)
                            if winner is not None:
                                game.game_over = True
                                await websocket.send_json({
                                    "type": "game_over",
                                    "winner": winner
                                })
                                logger.info(f"Juego terminado. Ganador: {winner}")
                else:
                    logger.warning(f"Movimiento inválido intentado en posición {position}")
                    await websocket.send_json({
                        "type": "error",
                        "message": "Movimiento inválido"
                    })
            
            elif data["type"] == "reset_game":
                logger.info(f"Reiniciando juego con tamaño {data['size']}")
                # Create new game with preserved state if provided
                preserved_board = data.get('board')
                preserved_player = data.get('current_player')
                game = TicTacToeGame(
                    size=data["size"],
                    board=preserved_board,
                    current_player=preserved_player
                )
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
        try:
            await websocket.close()
        except RuntimeError:
            logger.info("WebSocket already closed when attempting to close in finally.")
