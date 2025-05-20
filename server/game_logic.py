class TicTacToeGame:
    def __init__(self, size=3, board=None, current_player='X'):
        self.size = size
        self.board = board if board is not None else [None for _ in range(size * size)]
        self.current_player = current_player
        self.last_move = None
        self.moves_history = []
        self.game_over = False
    
    def make_move(self, position: int) -> bool:
        """
        Realiza un movimiento en el tablero.
        Retorna True si el movimiento fue válido, False si no.
        """
        if not self._is_valid_move(position) or self.game_over:
            return False
            
        self.board[position] = self.current_player
        self.last_move = position
        self.moves_history.append({
            'position': position,
            'player': self.current_player
        })
        self.current_player = 'O' if self.current_player == 'X' else 'X'
        return True
    
    def _is_valid_move(self, position: int) -> bool:
        """Verifica si un movimiento es válido"""
        if not isinstance(position, int):
            return False
        if position < 0 or position >= len(self.board):
            return False
        if self.board[position] is not None:
            return False
        return True
    
    def get_valid_moves(self) -> list:
        """Retorna una lista de movimientos válidos"""
        return [i for i, cell in enumerate(self.board) if cell is None]
    
    def is_board_full(self) -> bool:
        """Verifica si el tablero está lleno"""
        return None not in self.board
    
    def undo_last_move(self) -> bool:
        """Deshace el último movimiento"""
        if not self.moves_history:
            return False
        last_move = self.moves_history.pop()
        self.board[last_move['position']] = None
        self.current_player = last_move['player']
        return True
