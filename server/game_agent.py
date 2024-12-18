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
    """Realiza un movimiento inteligente en el tablero basado en el algoritmo Minimax."""
    board = ctx.deps.get("board")
    player = ctx.deps.get("current_player")
    opponent = 'O' if player == 'X' else 'X'

    # Función Minimax
    def minimax(board, depth, is_maximizing):
        winner = check_winner(board)
        if winner == player:
            return 1
        elif winner == opponent:
            return -1
        elif all(spot is not None for spot in board):
            return 0

        if is_maximizing:
            best_score = -float('inf')
            for i in range(9):
                if board[i] is None:
                    board[i] = player
                    score = minimax(board, depth + 1, False)
                    board[i] = None
                    best_score = max(best_score, score)
            return best_score
        else:
            best_score = float('inf')
            for i in range(9):
                if board[i] is None:
                    board[i] = opponent
                    score = minimax(board, depth + 1, True)
                    board[i] = None
                    best_score = min(best_score, score)
            return best_score

    best_score = -float('inf')
    best_move = None
    for i in range(9):
        if board[i] is None:
            board[i] = player
            score = minimax(board, 0, False)
            board[i] = None
            if score > best_score:
                best_score = score
                best_move = i

    if best_move is not None:
        board[best_move] = player
        return {"position": best_move, "player": player, "board": board}
    else:
        return {"error": "No hay movimientos disponibles"}


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
