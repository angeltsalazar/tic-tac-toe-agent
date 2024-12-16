from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from game_logic import TicTacToeGame
from game_agent import router as agent_router

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

@app.websocket("/game")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    game = TicTacToeGame()
    
    try:
        while True:
            data = await websocket.receive_json()
            if data["type"] == "player_move":
                position = data["position"]
                if game.make_move(position):
                    await websocket.send_json({
                        "type": "player_move",
                        "board": game.board
                    })
            elif data["type"] == "reset_game":
                game = TicTacToeGame()  # Crear nuevo juego
                await websocket.send_json({
                    "type": "game_reset",
                    "board": game.board
                })
    except:
        await websocket.close()
