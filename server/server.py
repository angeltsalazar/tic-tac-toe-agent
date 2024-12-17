from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
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

app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get('/favicon.ico', include_in_schema=False)
async def favicon():
    return FileResponse('../client/favicon.ico')

@app.get('/', include_in_schema=False)
async def root():
    return FileResponse('../client/index.html')

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
