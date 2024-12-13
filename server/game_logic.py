class TicTacToeGame:
    def __init__(self):
        self.board = ['' for _ in range(9)]
        self.current_player = 'X'
    
    def make_move(self, position: int) -> bool:
        if self.board[position] == '':
            self.board[position] = self.current_player
            self.current_player = 'O' if self.current_player == 'X' else 'X'
            return True
        return False
