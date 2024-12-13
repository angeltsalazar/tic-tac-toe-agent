from fastapi import FastAPI, WebSocket
from game_logic import TicTacToeGame
from game_agent import agent

app = FastAPI()

@app.websocket("/game")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    game = TicTacToeGame()
    
    while True:
        data = await websocket.receive_json()
        # Game logic implementation
