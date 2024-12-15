from fastapi.testclient import TestClient
from server.game_agent import app, check_winner

# para ejecutar los tests, ejecuta el siguiente comando en la terminal:
# cd /Volumes/SSDWD2T/projects/tic-tac-toe-agent
# PYTHONPATH=$PYTHONPATH:. pytest tests/test_game_agent.py

client = TestClient(app)

def test_make_move():
    response = client.post("/make_move", json={
        "board": [None, None, None, None, None, None, None, None, None],
        "current_player": "X"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["player"] == "X"
    assert data["position"] in range(9)
    assert data["board"][data["position"]] == "X"

def test_check_winner():
    board = ["X", "X", "X", None, None, None, None, None, None]
    winner = check_winner(board)
    assert winner == "X"
