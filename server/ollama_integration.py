"""
Cliente personalizado para integrar Ollama con el agente de Tic-Tac-Toe.
Como pydantic-ai no tiene soporte directo para Ollama, creamos nuestro propio cliente.
"""

import httpx
import json
from typing import List, Optional, Dict, Any
import logging

logger = logging.getLogger(__name__)

class OllamaClient:
    """Cliente para interactuar con Ollama API"""
    
    def __init__(self, base_url: str = "http://localhost:11434", model: str = "phi3:mini"):
        self.base_url = base_url
        self.model = model
        
    async def generate(self, prompt: str, system_prompt: Optional[str] = None) -> str:
        """Generar respuesta usando Ollama"""
        url = f"{self.base_url}/api/generate"
        
        payload = {
            "model": self.model,
            "prompt": prompt,
            "stream": False
        }
        
        if system_prompt:
            payload["system"] = system_prompt
            
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(url, json=payload)
                response.raise_for_status()
                
                result = response.json()
                return result.get("response", "")
                
        except Exception as e:
            logger.error(f"Error llamando a Ollama: {e}")
            raise
    
    async def is_available(self) -> bool:
        """Verificar si Ollama está disponible"""
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                if response.status_code != 200:
                    return False
                    
                # Test model availability
                test_response = await client.post(
                    f"{self.base_url}/api/generate",
                    json={
                        "model": self.model,
                        "prompt": "test",
                        "stream": False
                    }
                )
                
                # If we get a memory error or model error, consider unavailable
                if test_response.status_code != 200:
                    result = test_response.json()
                    if "memory" in result.get("error", "").lower():
                        logger.warning(f"Ollama no disponible por memoria insuficiente: {result.get('error')}")
                        return False
                        
                return True
        except Exception as e:
            logger.warning(f"Ollama no disponible: {e}")
            return False
    
    async def list_models(self) -> List[Dict[str, Any]]:
        """Listar modelos disponibles"""
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                response.raise_for_status()
                
                result = response.json()
                return result.get("models", [])
        except Exception as e:
            logger.error(f"Error obteniendo modelos: {e}")
            return []


class TicTacToeAI:
    """Agente de IA para Tic-Tac-Toe usando Ollama"""
    
    def __init__(self, ollama_client: OllamaClient):
        self.ollama = ollama_client
        self.system_prompt = """
Eres un experto jugador de Tic-Tac-Toe (3 en raya). Tu objetivo es:
1. GANAR el juego cuando sea posible (completar 3 en línea)
2. BLOQUEAR al oponente cuando esté a punto de ganar
3. Hacer movimientos estratégicos para crear oportunidades de victoria

REGLAS DEL TABLERO:
- El tablero tiene 9 posiciones numeradas del 0 al 8:
  0 | 1 | 2
  ---------
  3 | 4 | 5
  ---------  
  6 | 7 | 8

- Un número (0-8) significa casilla vacía
- 'X' es el jugador humano, 'O' eres tú (la IA)
- Para ganar necesitas 3 símbolos en línea (horizontal, vertical o diagonal)

INSTRUCCIONES DE RESPUESTA:
- Responde ÚNICAMENTE con el número de la posición donde quieres jugar (0-8)
- NO agregues explicaciones, comentarios o texto adicional
- Si no hay movimientos válidos, responde "FULL"

ESTRATEGIA PRIORITARIA:
1. Si puedes ganar inmediatamente (completar 3 en línea), hazlo
2. Si el oponente puede ganar en su siguiente turno, bloquéalo
3. Controla el centro (posición 4) si está disponible
4. Prefiere esquinas (0,2,6,8) sobre bordes laterales (1,3,5,7)
5. Busca crear dos amenazas simultáneas (fork)
"""
    
    async def make_move(self, board: List[Optional[str]], player: str = 'O') -> int:
        """Hacer un movimiento inteligente usando IA"""
        
        # Verificar si Ollama está disponible
        if not await self.ollama.is_available():
            logger.warning("Ollama no disponible, usando algoritmo Minimax")
            return self._minimax_move(board, player)
        
        # Crear el prompt para la IA con análisis del tablero
        board_str = [str(i) if cell is None else cell for i, cell in enumerate(board)]
        
        # Analizar estado del juego
        empty_positions = [i for i, cell in enumerate(board) if cell is None]
        player_positions = [i for i, cell in enumerate(board) if cell == player]
        opponent = 'X' if player == 'O' else 'O'
        opponent_positions = [i for i, cell in enumerate(board) if cell == opponent]
        
        prompt = f"""
ESTADO ACTUAL DEL TABLERO:
{board_str[0]} | {board_str[1]} | {board_str[2]}
---------
{board_str[3]} | {board_str[4]} | {board_str[5]}
---------
{board_str[6]} | {board_str[7]} | {board_str[8]}

TU SÍMBOLO: {player}
OPONENTE: {opponent}
POSICIONES VACÍAS: {empty_positions}
TUS POSICIONES: {player_positions}
POSICIONES OPONENTE: {opponent_positions}

Analiza cuidadosamente:
1. ¿Puedes ganar en este turno?
2. ¿Necesitas bloquear al oponente?
3. ¿Qué movimiento es más estratégico?

Responde SOLO con el número de tu mejor movimiento (0-8):
"""
        
        try:
            response = await self.ollama.generate(prompt, self.system_prompt)
            
            # Parsear la respuesta de la IA
            response = response.strip()
            
            if response == "FULL":
                return -1  # Tablero lleno
            
            try:
                position = int(response)
                if 0 <= position <= 8 and board[position] is None:
                    return position
                else:
                    logger.warning(f"IA sugirió posición inválida: {position}")
                    return self._minimax_move(board, player)
            except ValueError:
                logger.warning(f"IA respondió formato inválido: {response}")
                return self._minimax_move(board, player)
                
        except Exception as e:
            logger.error(f"Error usando IA: {e}")
            return self._minimax_move(board, player)
    
    def _minimax_move(self, board: List[Optional[str]], player: str) -> int:
        """Algoritmo Minimax como fallback"""
        # Importar directamente desde el módulo local
        try:
            from game_agent import minimax_algorithm
            return minimax_algorithm(board, player)
        except ImportError:
            # Fallback manual simple si hay problemas de importación
            logger.warning("No se pudo importar minimax_algorithm, usando fallback básico")
            return self._simple_fallback(board, player)
    
    def _simple_fallback(self, board: List[Optional[str]], player: str) -> int:
        """Fallback básico: elegir primera posición disponible o centro"""
        # Intentar el centro primero
        if board[4] is None:
            return 4
        
        # Buscar primera posición disponible
        for i, cell in enumerate(board):
            if cell is None:
                return i
        
        return -1  # Tablero lleno


# Instancia global del cliente Ollama
ollama_client = OllamaClient()
tic_tac_toe_ai = TicTacToeAI(ollama_client)
