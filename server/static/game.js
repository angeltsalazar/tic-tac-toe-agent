class TicTacToeClient {
    constructor(size = 3) {
        this.size = size;
        this.ws = null;
        this.boardElement = document.querySelector('.game-board');
        this.board = Array(this.size * this.size).fill(null);
        this.currentPlayer = 'X';
        this.gameOver = false;
        this.isWaitingForResponse = false;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 3;

        console.log(`Inicializando juego con tamaño ${size}x${size}`);
        this.setupBoard();
        this.setupEventListeners();
        this.setupNewGameButton();
        this.connectWebSocket();
    }

    connectWebSocket() {
        return new Promise((resolve, reject) => {
            if (this.ws && this.ws.readyState === WebSocket.OPEN) {
                console.log('Cerrando conexión WebSocket existente');
                this.ws.close();
            }

            console.log(`Intentando conectar al WebSocket (intento ${this.reconnectAttempts + 1}/${this.maxReconnectAttempts})`);
            this.ws = new WebSocket(`ws://localhost:8000/game?size=${this.size}`);

            this.ws.onopen = () => {
                console.log("Conexión WebSocket establecida exitosamente");
                this.reconnectAttempts = 0;
                this.updateStatusMessage('Conectado al servidor');

                // After reconnection, send current game state to server
                const currentState = {
                    type: "reset_game",
                    size: this.size,
                    board: this.board,
                    current_player: this.currentPlayer
                };
                this.ws.send(JSON.stringify(currentState));
                resolve();
            };

            this.ws.onmessage = (event) => {
                const message = JSON.parse(event.data);
                console.log("Mensaje recibido del servidor:", message);
                
                if (message.type === "game_state") {
                    console.log("Actualizando estado del juego:", message);
                    this.board = message.board;
                    this.currentPlayer = message.current_player;
                    this.size = message.size;
                    this.updateUI();
                    this.isWaitingForResponse = false;
                } else if (message.type === "game_over") {
                    this.gameOver = true;
                    if (message.winner === "Tie") {
                        alert(`The game is a ${message.winner}!`);
                    } else {
                        alert(`Player ${message.winner} wins!`);
                    }
                    this.updateUI();
                    this.isWaitingForResponse = false;
                } else if (message.type === "error") {
                    console.error("Error recibido del servidor:", message.message);
                    this.updateStatusMessage(`Error: ${message.message}`);
                    this.isWaitingForResponse = false;
                }
            };

            this.ws.onclose = () => {
                console.log("Conexión WebSocket cerrada");
                this.updateStatusMessage('Desconectado del servidor');
                
                if (this.reconnectAttempts < this.maxReconnectAttempts) {
                    console.log("Intentando reconexión...");
                    this.reconnectAttempts++;
                    setTimeout(() => this.connectWebSocket(), 2000);
                } else {
                    console.error("Máximo número de intentos de reconexión alcanzado");
                    this.updateStatusMessage('Error de conexión. Por favor, recarga la página.');
                }
            };

            this.ws.onerror = (error) => {
                console.error("Error en WebSocket:", error);
                this.updateStatusMessage('Error de conexión');
                reject(error);
            };

            setTimeout(() => {
                if (this.ws.readyState !== WebSocket.OPEN) {
                    console.error("Timeout de conexión WebSocket");
                    this.ws.close();
                    reject(new Error("Timeout de conexión WebSocket"));
                }
            }, 5000);
        });
    }

    updateStatusMessage(message) {
        let statusElement = document.getElementById('status-message');
        if (!statusElement) {
            statusElement = document.createElement('div');
            statusElement.id = 'status-message';
            document.body.insertBefore(statusElement, this.boardElement);
        }
        statusElement.textContent = message;
    }

    setupBoard() {
        console.log(`Configurando tablero ${this.size}x${this.size}`);
        this.boardElement.innerHTML = '';
        this.boardElement.style.gridTemplateColumns = `repeat(${this.size}, 100px)`;
        
        for (let i = 0; i < this.size * this.size; i++) {
            const cell = document.createElement('div');
            cell.classList.add('cell');
            cell.dataset.index = i;
            this.boardElement.appendChild(cell);
        }
        console.log('Tablero configurado');
    }

    setupEventListeners() {
        console.log("Configurando event listeners");
        this.boardElement.addEventListener('click', async (e) => {
            const cell = e.target;
            if (!cell.classList.contains('cell')) return;

            const cellIndex = parseInt(cell.dataset.index);
            console.log(`Celda ${cellIndex} clickeada`);

            if (this.gameOver) {
                console.log('Juego terminado, click ignorado');
                return;
            }

            if (this.isWaitingForResponse) {
                console.log('Esperando respuesta del servidor, click ignorado');
                return;
            }

            if (this.board[cellIndex] !== null) {
                console.log('Celda ocupada, click ignorado');
                return;
            }

            console.log(`Intentando movimiento en celda ${cellIndex}`);
            this.isWaitingForResponse = true;
            cell.style.backgroundColor = '#eee'; // Feedback visual
            await this.makeMove(cellIndex);
            cell.style.backgroundColor = ''; // Restaurar color
        });

        document.getElementById('boardSize').addEventListener('change', (e) => {
            const newSize = parseInt(e.target.value);
            console.log(`Cambiando tamaño del tablero a ${newSize}x${newSize}`);
            this.resetGame(newSize);
        });
    }

    setupNewGameButton() {
        document.getElementById('newGame').addEventListener('click', () => {
            const size = parseInt(document.getElementById('boardSize').value);
            this.resetGame(size);
        });
    }

    resetGame(size) {
        this.size = size;
        this.board = Array(this.size * this.size).fill(null);
        this.currentPlayer = 'X';
        this.gameOver = false;
        this.setupBoard(); // Re-create the board with the new size
        this.setupEventListeners();
        this.updateUI();

        // Notificar al servidor del reinicio
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify({
                type: "reset_game",
                size: this.size
            }));
        } else {
            this.connectWebSocket();
        }
    }

    async makeMove(position) {
        if (this.board[position] !== null || this.gameOver) {
            return; // Prevent invalid moves
        }

        try {
            if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
                await this.connectWebSocket();
            }

            if (this.ws.readyState === WebSocket.OPEN) {
                const moveData = {
                    type: "player_move",
                    position: position,
                    board: this.board,
                    current_player: this.currentPlayer,
                    size: this.size
                };
                this.ws.send(JSON.stringify(moveData));
                console.log("Move sent:", moveData);
            } else {
                console.error("WebSocket connection failed");
                alert("Connection error. Please try again.");
            }
        } catch (error) {
            console.error("Error sending move:", error);
            this.isWaitingForResponse = false;
            alert("Error making move. Please try again.");
        }
    }

    updateUI() {
        this.boardElement.querySelectorAll('.cell').forEach((cell, index) => {
            cell.textContent = this.board[index] === null ? '' : this.board[index];
        });
    }
}

let game; // Declare game outside the event listener

document.addEventListener('DOMContentLoaded', () => {
    const size = parseInt(document.getElementById('boardSize').value);
    game = new TicTacToeClient(size); // Initialize game here
});
