from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, List
import logging
import asyncio

# Importar nuestro cliente Ollama personalizado
from ollama_integration import tic_tac_toe_ai, ollama_client

logger = logging.getLogger(__name__)

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


# Rutas de la API
@router.post("/make_move")
async def make_move_api(state: GameState):
    """Endpoint para realizar un movimiento usando IA o Minimax."""
    try:
        # Usar el agente de IA con Ollama
        position = await tic_tac_toe_ai.make_move(state.board, state.current_player)
        
        if position == -1:
            return {"error": "No hay movimientos disponibles"}
        
        # Crear tablero actualizado
        new_board = state.board.copy()
        new_board[position] = state.current_player
        
        return {
            "position": position,
            "player": state.current_player,
            "board": new_board,
            "used_ai": await ollama_client.is_available()
        }
    except Exception as e:
        logger.error(f"Error en make_move_api: {e}")
        return {"error": str(e)}

@router.post("/check_winner")
async def check_winner_api(state: BoardState):
    """Endpoint para verificar si hay un ganador."""
    winner = check_winner(state.board, state.size)
    return {"winner": winner}

@router.post("/start_game")
async def start_game():
    """Endpoint para iniciar un nuevo juego."""
    game_state = GameState(board=[None] * 9, current_player="X", size=3)
    return game_state

@router.get("/ai_status")
async def ai_status():
    """Endpoint para verificar el estado del sistema de IA."""
    ollama_available = await ollama_client.is_available()
    models = await ollama_client.list_models() if ollama_available else []
    
    return {
        "ollama_available": ollama_available,
        "models": models,
        "fallback": "minimax" if not ollama_available else None
    }


# Algoritmo Minimax para uso como fallback
def minimax_algorithm(board: List[Optional[str]], current_player: str, size: int = 3) -> int:
    """
    Implementación del algoritmo Minimax que retorna solo la posición del mejor movimiento.
    Usado como fallback cuando Ollama no está disponible.
    """
    if len(board) < size * size:
        raise ValueError(f"El board debe tener al menos {size*size} posiciones, tiene {len(board)}.")

    opponent = 'O' if current_player == 'X' else 'X'

    # Función Minimax
    def minimax(board, depth, is_maximizing):
        winner = check_winner(board, size)
        if winner == current_player:
            return 1
        elif winner == opponent:
            return -1
        elif all(spot is not None for spot in board):
            return 0

        if is_maximizing:
            best_score = -float('inf')
            for i in range(size * size):
                if board[i] is None:
                    board[i] = current_player
                    score = minimax(board, depth + 1, False)
                    board[i] = None
                    best_score = max(best_score, score)
            return best_score
        else:
            best_score = float('inf')
            for i in range(size * size):
                if board[i] is None:
                    board[i] = opponent
                    score = minimax(board, depth + 1, True)
                    board[i] = None
                    best_score = min(best_score, score)
            return best_score

    best_score = -float('inf')
    best_move = None
    for i in range(size * size):
        if board[i] is None:
            board[i] = current_player
            score = minimax(board, 0, False)
            board[i] = None
            if score > best_score:
                best_score = score
                best_move = i

    if best_move is not None:
        return best_move
    else:
        return -1  # No hay movimientos disponibles


# Implementación de movimiento inteligente usando Minimax (función legacy para compatibilidad)
def make_move_endpoint(board: List[Optional[str]], current_player: str, size: int = 3) -> dict:
    """Realiza un movimiento inteligente en el tablero basado en el algoritmo Minimax."""
    position = minimax_algorithm(board, current_player, size)
    
    if position != -1:
        board_copy = board.copy()
        board_copy[position] = current_player
        return {"position": position, "player": current_player, "board": board_copy}
    else:
        return {"error": "No hay movimientos disponibles"}


# Función para verificar ganador
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
