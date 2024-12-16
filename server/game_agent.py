from fastapi import APIRouter
from pydantic import BaseModel
from pydantic_ai import Agent, RunContext
from typing import Optional, List
import random

# Definición del agente
agent = Agent(
    "groq:llama-3.3-70b-versatile",
    deps_type=dict,
    system_prompt=(
        "You're a Tic-tac-toe game agent. You analyze the board state "
        "and make strategic moves. You should try to win while also "
        "blocking the opponent from winning."
    ),
)


# Modelo de datos para el estado del juego
class GameState(BaseModel):
    board: List[Optional[str]]  # Representación del tablero como lista de 9 elementos
    current_player: str  # 'X' o 'O'


class BoardState(BaseModel):
    board: List[Optional[str]]


# Definición de la aplicación FastAPI
router = APIRouter()


# Ruta para hacer un movimiento
@router.post("/make_move")
def make_move_endpoint(state: GameState):
    """Realiza un movimiento basado en el estado actual del tablero."""
    ctx = RunContext(deps=state.model_dump(), retry=0)
    result = make_move(ctx)
    return result


@router.post("/check_winner")
def check_winner_endpoint(state: BoardState):
    """Verifica si hay un ganador en el estado actual del tablero."""
    winner = check_winner(state.board)
    return winner


@router.post("/start_game")
def start_game():
    game_state = GameState(board=[None] * 9, current_player="X")
    # Aquí debes almacenar el estado inicial del juego
    return game_state


# Implementación del tool 'make_move' del agente
@agent.tool
def make_move(ctx: RunContext[dict]) -> dict:
    """Realiza un movimiento en el tablero basado en el estado actual."""
    board = ctx.deps.get("board")
    player = ctx.deps.get("current_player")

    # Lógica para seleccionar la posición
    available_positions = [i for i, spot in enumerate(board) if spot is None]
    if not available_positions:
        return {"error": "No hay movimientos disponibles"}

    # Seleccionar una posición de forma aleatoria (puedes reemplazar con IA)
    selected_position = random.choice(available_positions)
    board[selected_position] = player

    return {"position": selected_position, "player": player, "board": board}


# Implementación del tool 'check_winner' del agente
@agent.tool_plain
def check_winner(board: List[Optional[str]]) -> Optional[str]:
    """Verifica si hay un ganador en el tablero."""
    # Combinaciones ganadoras
    winning_combinations = [
        (0, 1, 2),
        (3, 4, 5),
        (6, 7, 8),  # Horizontales
        (0, 3, 6),
        (1, 4, 7),
        (2, 5, 8),  # Verticales
        (0, 4, 8),
        (2, 4, 6),  # Diagonales
    ]

    for combo in winning_combinations:
        a, b, c = combo
        if board[a] == board[b] == board[c] and board[a] is not None:
            return board[a]  # Retorna 'X' o 'O' como ganador

    if all(spot is not None for spot in board):
        return "Tie"  # Empate

    return None  # El juego continúa
