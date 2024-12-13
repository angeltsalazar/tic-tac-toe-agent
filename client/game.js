class TicTacToeClient {
    constructor() {
        this.ws = new WebSocket('ws://localhost:8000/game');
        this.board = document.querySelector('.game-board');
        this.setupEventListeners();
    }

    setupEventListeners() {
        this.board.addEventListener('click', (e) => {
            if (e.target.classList.contains('cell')) {
                this.makeMove(e.target.dataset.index);
            }
        });
    }

    makeMove(position) {
        this.ws.send(JSON.stringify({
            type: 'move',
            position: position
        }));
    }
}

const game = new TicTacToeClient();
