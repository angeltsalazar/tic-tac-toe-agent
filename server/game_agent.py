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
    board: List[Optional[str]]  # Representación del tablero como lista de elementos
    current_player: str  # 'X' o 'O'
    size: int  # Tamaño del tablero


class BoardState(BaseModel):
    board: List[Optional[str]]
    size: int  # Tamaño del tablero


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
    winner = check_winner(state.board, state.size)
    return winner


@router.post("/start_game")
def start_game():
    game_state = GameState(board=[None] * 9, current_player="X", size=3)
    # Aquí debes almacenar el estado inicial del juego
    return game_state


# Implementación del tool 'make_move' del agente
@agent.tool
def make_move(ctx: RunContext[dict]) -> dict:
    """Realiza un movimiento inteligente en el tablero basado en el algoritmo Minimax."""
    board = ctx.deps.get("board")
    player = ctx.deps.get("current_player")
    size = ctx.deps.get("size", 3)
    if len(board) != size * size: # Ensure board is exactly size*size
        raise ValueError(f"El board debe tener {size*size} posiciones, tiene {len(board)}.")

    opponent = 'O' if player == 'X' else 'X'

    # Determine max_depth based on board size
    if size == 3:
        max_search_depth = 9  # Full search for 3x3
    elif size == 4:
        max_search_depth = 3  # Limit depth for 4x4 (4-ply total: AI -> Opp -> AI -> Opp)
    elif size == 5:
        max_search_depth = 2  # Limit depth for 5x5 (3-ply total)
    else:  # size > 5
        max_search_depth = 1  # Limit depth for larger boards (2-ply total)

    # Función Minimax
    def minimax(current_board, current_depth, is_maximizing_player):
        winner = check_winner(current_board, size)
        if winner == player:
            return 10 - current_depth  # Prioritize faster wins
        elif winner == opponent:
            return current_depth - 10  # Prioritize opponent losing faster (AI delays loss)
        elif all(spot is not None for spot in current_board):
            return 0  # Tie

        if current_depth >= max_search_depth:
            return 0  # Depth limit reached, return neutral score (heuristic could be improved)

        if is_maximizing_player:  # AI's (player's) turn
            best_score_val = -float('inf')
            for i in range(size * size):
                if current_board[i] is None:
                    current_board[i] = player
                    score_val = minimax(current_board, current_depth + 1, False)
                    current_board[i] = None  # Backtrack
                    best_score_val = max(best_score_val, score_val)
            return best_score_val
        else:  # Opponent's turn
            best_score_val = float('inf')
            for i in range(size * size):
                if current_board[i] is None:
                    current_board[i] = opponent
                    score_val = minimax(current_board, current_depth + 1, True)
                    current_board[i] = None  # Backtrack
                    best_score_val = min(best_score_val, score_val)
            return best_score_val

    best_overall_score = -float('inf')
    best_move_idx = -1

    possible_empty_spots = [i for i, spot in enumerate(board) if spot is None]

    if not possible_empty_spots:
        return {"error": "No hay movimientos disponibles, tablero lleno."}

    random.shuffle(possible_empty_spots) # Shuffle for variety if scores are tied

    for move_idx in possible_empty_spots:
        board[move_idx] = player  # Make the hypothetical move
        # Call minimax for the opponent's turn (is_maximizing_player=False)
        # current_depth is 0 for the first level of minimax recursion
        current_score = minimax(board, 0, False)
        board[move_idx] = None  # Backtrack the hypothetical move

        if current_score > best_overall_score:
            best_overall_score = current_score
            best_move_idx = move_idx
    
    # If best_move_idx remained -1, it means all moves resulted in -inf or possible_empty_spots was empty.
    # However, if possible_empty_spots was not empty, best_move_idx will be set to at least the first shuffled move.
    # This check ensures a move is made if available, even if all evaluated scores are -inf (e.g. forced loss)
    if best_move_idx == -1 and possible_empty_spots:
        best_move_idx = possible_empty_spots[0] # Fallback to the first available (shuffled)

    if best_move_idx != -1:
        board[best_move_idx] = player  # Apply the chosen move to the actual board
        return {"position": best_move_idx, "player": player, "board": board}
    else:
        # This path should ideally not be reached if there were available spots.
        return {"error": "No se pudo determinar un movimiento válido."}


# Implementación del tool 'check_winner' del agente
@agent.tool_plain
def check_winner(board: List[Optional[str]], size: int) -> Optional[str]:
    """Verifica si hay un ganador en el tablero."""
    # Combinaciones ganadoras
    winning_combinations = []

    # Horizontales y verticales
    for i in range(size):
        # Horizontales
        winning_combinations.append([i * size + j for j in range(size)])
        # Verticales
        winning_combinations.append([j * size + i for j in range(size)])

    # Diagonales
    winning_combinations.append([i * size + i for i in range(size)])
    winning_combinations.append([i * size + (size - 1 - i) for i in range(size)])

    for combo in winning_combinations:
        if all(board[pos] == board[combo[0]] and board[pos] is not None for pos in combo):
            return board[combo[0]]  # Retorna 'X' o 'O' como ganador

    if all(spot is not None for spot in board):
        return "Tie"  # Empate

    return None  # El juego continúa
