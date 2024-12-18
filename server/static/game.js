class TicTacToeClient {
    constructor() {
        this.ws = new WebSocket('ws://localhost:8000/game');
        this.boardElement = document.querySelector('.game-board');
        this.board = Array(9).fill(null); // Internal representation of board
        this.currentPlayer = 'X';  // Player X always goes first.
        this.gameOver = false; // Track if the game has ended.

        // Create cells and add them to the board
        this.boardElement.innerHTML = '';
        for (let i = 0; i < 9; i++) {
            const cell = document.createElement('div');
            cell.classList.add('cell');
            cell.dataset.index = i;
            this.boardElement.appendChild(cell);
        }
        this.setupEventListeners();
        this.setupNewGameButton();

        this.ws.onmessage = (event) => {
            const message = JSON.parse(event.data);
            if (message.type == "player_move") {
                this.updateBoard(message.board);
            }
        }
    }

    setupEventListeners() {
        this.boardElement.addEventListener('click', (e) => {
            if (e.target.classList.contains('cell') && !this.gameOver) {
                const cellIndex = parseInt(e.target.dataset.index);
                if (this.board[cellIndex] == null) {
                    this.makeMove(cellIndex);
                }

            }
        });
    }

    setupNewGameButton() {
        document.getElementById('newGame').addEventListener('click', () => {
            this.resetGame();
        });
    }

    resetGame() {
        this.board = Array(9).fill(null);
        this.currentPlayer = 'X';
        this.gameOver = false;
        this.updateUI();

        // Notificar al servidor del reinicio
        this.ws.send(JSON.stringify({
            type: "reset_game"
        }));
    }

    async makeMove(position) {
        // Optimistic update: update UI before sending the message (faster UX)
        this.board[position] = this.currentPlayer;
        this.updateUI();

        // Check for winner immediately after player's move
        const winner = await this.checkWinner();
        if (winner) {
            this.gameOver = true;
            if (winner === "Tie") {
                alert(`The game is a ${winner}!`);
            } else {
                alert(`Player ${winner} wins!`);
            }
            return; // Exit early if game is won
        }

        const moveData = {
            type: "player_move",
            position: position,
            board: this.board,
            current_player: this.currentPlayer
        };
        this.ws.send(JSON.stringify(moveData));


        // Only proceed with agent's move if game isn't over
        try {
            const response = await fetch('http://localhost:8000/make_move', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    board: this.board,
                    current_player: this.currentPlayer === "X" ? "O" : "X"
                }),
            });

            if (!response.ok) {
                console.error('Failed to fetch agent move', response.status, await response.text());
                // Make sure to update UI even when there's an error
                this.updateUI();
                return;
            }

            const data = await response.json();
            // Keep the current board state if there's an error
            if (data.error) {
                console.log(data.error);
                // Make sure to update UI when there's an error message
                this.updateUI();
                return;
            }
            this.board = data.board;
            this.updateUI();

            // Check for winner after agent's move
            const agentWinner = await this.checkWinner();
            if (agentWinner) {
                this.gameOver = true;

                // Para permitir que el tablero se refresque antes de mostrar el mensaje
                setTimeout(() => {
                    if (agentWinner == "Tie") {
                        alert(`The game is a ${agentWinner}!`);
                    } else {
                        alert(`Player ${agentWinner} wins!`);
                    }
                }, 50); // milisegundos
            }
        } catch (error) {
            console.error('Error fetching agent move', error);
        }


    }

    updateBoard(newBoard) {
        this.board = newBoard;
        this.updateUI();
    }

    updateUI() {
        this.boardElement.querySelectorAll('.cell').forEach((cell, index) => {
            cell.textContent = this.board[index] || '';
        });
    }

    async checkWinner() {
        try {
            const response = await fetch('http://localhost:8000/check_winner', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ board: this.board }),
            });

            if (!response.ok) {
                console.error('Error checking winner:', response.status, await response.text());
                return null;
            }

            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Error fetching game status:', error);
            return null;
        }
    }
}


const game = new TicTacToeClient();
