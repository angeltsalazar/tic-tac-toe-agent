// Tic Tac Toe Client con soporte para IA Ollama
// 
// ⚠️ IMPORTANTE PARA GITHUB CODESPACES:
// Este código detecta automáticamente si está ejecutándose en GitHub Codespaces
// y ajusta las URLs de WebSocket apropiadamente (wss:// vs ws://)
// 
// Si el tablero no aparece, verificar que se use la URL de Codespaces
// (NO localhost:8000) - Ver CODESPACES-SETUP.md para más detalles
//
class TicTacToeClient {
    constructor(size = 3) {
        console.log(`🏗️ Construyendo TicTacToeClient con tamaño ${size}`);
        this.size = size;
        this.ws = null;
        this.boardElement = document.querySelector('.game-board');
        this.statusElement = document.getElementById('status');
        this.aiStatusElement = document.getElementById('aiStatus');
        this.board = Array(this.size * this.size).fill(null);
        this.currentPlayer = 'X';
        this.gameOver = false;
        this.isWaitingForResponse = false;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 3;

        console.log('🔍 Verificando elementos DOM:');
        console.log('  - boardElement:', this.boardElement ? '✅' : '❌');
        console.log('  - statusElement:', this.statusElement ? '✅' : '❌');
        console.log('  - aiStatusElement:', this.aiStatusElement ? '✅' : '❌');

        console.log(`Inicializando juego con tamaño ${size}x${size}`);
        this.updateStatusMessage('Inicializando...', 'disconnected');
        this.updateAIStatus('Verificando IA...');
        this.setupBoard();
        this.setupEventListeners();
        this.setupNewGameButton();
        this.checkAIStatus();
        this.connectWebSocket();
    }

    updateStatusMessage(message, type = 'connected') {
        if (this.statusElement) {
            this.statusElement.textContent = message;
            this.statusElement.className = `status ${type}`;
        }
        console.log(`Status: ${message}`);
    }

    updateAIStatus(message, type = '') {
        if (this.aiStatusElement) {
            this.aiStatusElement.textContent = message;
            this.aiStatusElement.className = `ai-status ${type}`;
        }
    }

    async checkAIStatus() {
        try {
            const response = await fetch('/ollama-status');
            const data = await response.json();
            
            if (data.ollama_available) {
                this.updateAIStatus(`🤖 IA Ollama activa (${data.model})`, 'ollama');
            } else {
                this.updateAIStatus(`⚙️ IA Minimax (fallback)`, 'fallback');
            }
        } catch (error) {
            this.updateAIStatus('❌ Error verificando IA');
            console.error('Error checking AI status:', error);
        }
    }

    connectWebSocket() {
        return new Promise((resolve, reject) => {
            if (this.ws && this.ws.readyState === WebSocket.OPEN) {
                console.log('Cerrando conexión WebSocket existente');
                this.ws.close();
            }

            console.log(`Conectando al WebSocket (intento ${this.reconnectAttempts + 1}/${this.maxReconnectAttempts})`);
            
            // Detectar si estamos en GitHub Codespaces o localhost
            const isCodespaces = window.location.hostname.includes('app.github.dev');
            const wsProtocol = isCodespaces ? 'wss:' : 'ws:';
            const wsHost = isCodespaces ? window.location.host : 'localhost:8000';
            const wsUrl = `${wsProtocol}//${wsHost}/game?size=${this.size}`;
            
            console.log(`🔌 Conectando a: ${wsUrl}`);
            this.ws = new WebSocket(wsUrl);

            this.ws.onopen = () => {
                console.log("✅ Conexión WebSocket establecida");
                this.reconnectAttempts = 0;
                this.updateStatusMessage('🟢 Conectado al servidor', 'connected');
                resolve();
            };

            this.ws.onmessage = (event) => {
                const message = JSON.parse(event.data);
                console.log("📩 Mensaje del servidor:", message);
                
                if (message.type === "game_state") {
                    this.board = message.board;
                    this.currentPlayer = message.current_player;
                    this.size = message.size;
                    
                    // Validación adicional para asegurar estado correcto
                    if (!this.currentPlayer) {
                        console.warn('⚠️ current_player es null, estableciendo a X');
                        this.currentPlayer = 'X';
                    }
                    
                    // Si el tablero está vacío, probablemente es un nuevo juego
                    const isEmpty = this.board.every(cell => cell === null);
                    if (isEmpty) {
                        console.log('🆕 Tablero vacío detectado - reiniciando estado del juego');
                        this.gameOver = false;
                        this.isWaitingForResponse = false;
                        this.updateStatusMessage('🟢 Nuevo juego iniciado', 'connected');
                    }
                    
                    console.log(`🎯 Estado actualizado: turno de ${this.currentPlayer}`);
                    this.updateUI();
                    this.isWaitingForResponse = false;
                    
                    // Mostrar información de IA si está disponible
                    if (message.ai_used !== undefined) {
                        const aiType = message.ai_used ? '🤖 Ollama' : '⚙️ Minimax';
                        console.log(`IA usada: ${aiType}`);
                    }
                    
                } else if (message.type === "game_over") {
                    console.log("🏁 Mensaje de fin de juego recibido:", message);
                    this.gameOver = true;
                    this.isWaitingForResponse = false;
                    
                    let winMessage = '';
                    if (message.winner === "Tie") {
                        winMessage = "🤝 ¡Empate!";
                    } else if (message.winner === "X") {
                        winMessage = "🎉 ¡Ganaste! (X)";
                    } else if (message.winner === "O") {
                        winMessage = "🤖 ¡La IA ganó! (O)";
                    }
                    
                    // Actualizar UI primero
                    this.updateUI();
                    
                    // Mostrar mensaje de ganador
                    console.log("🏆 Mostrando mensaje de victoria:", winMessage);
                    const aiType = message.ai_used ? 'Ollama' : (message.ai_used === false ? 'Minimax' : 'N/A');
                    
                    // Mostrar inmediatamente y también con timeout como respaldo
                    alert(`${winMessage}\n\nIA utilizada: ${aiType}`);
                    
                    // Actualizar estado en pantalla también
                    this.updateStatusMessage(`🏁 Juego terminado - ${winMessage}`, 'connected');
                    
                } else if (message.type === "error") {
                    console.error("❌ Error del servidor:", message.message);
                    this.updateStatusMessage(`❌ Error: ${message.message}`, 'disconnected');
                    this.isWaitingForResponse = false;
                }
            };

            this.ws.onclose = () => {
                console.log("🔌 Conexión WebSocket cerrada");
                this.updateStatusMessage('🔴 Desconectado', 'disconnected');
                
                if (this.reconnectAttempts < this.maxReconnectAttempts) {
                    console.log("🔄 Intentando reconexión...");
                    this.reconnectAttempts++;
                    setTimeout(() => this.connectWebSocket(), 2000);
                } else {
                    console.error("💥 Máximo de reconexiones alcanzado");
                    this.updateStatusMessage('❌ Error de conexión. Recarga la página.', 'disconnected');
                }
            };

            this.ws.onerror = (error) => {
                console.error("💥 Error en WebSocket:", error);
                this.updateStatusMessage('❌ Error de conexión', 'disconnected');
                reject(error);
            };

            setTimeout(() => {
                if (this.ws.readyState !== WebSocket.OPEN) {
                    console.error("⏰ Timeout de conexión");
                    this.ws.close();
                    reject(new Error("Timeout de conexión WebSocket"));
                }
            }, 5000);
        });
    }

    setupBoard() {
        console.log(`🎯 Configurando tablero ${this.size}x${this.size}`);
        
        if (!this.boardElement) {
            console.error('❌ boardElement es null, no se puede configurar el tablero');
            return;
        }
        
        console.log('📋 Limpiando tablero...');
        this.boardElement.innerHTML = '';
        this.boardElement.style.gridTemplateColumns = `repeat(${this.size}, 100px)`;
        
        console.log(`🔢 Creando ${this.size * this.size} celdas...`);
        for (let i = 0; i < this.size * this.size; i++) {
            const cell = document.createElement('div');
            cell.classList.add('cell');
            cell.dataset.index = i;
            cell.addEventListener('click', () => this.handleCellClick(i));
            this.boardElement.appendChild(cell);
            console.log(`  - Celda ${i} creada`);
        }
        console.log('✅ Tablero configurado');
        console.log('📊 Estado final del tablero:', this.boardElement.innerHTML.length, 'caracteres HTML');
    }

    async handleCellClick(cellIndex) {
        console.log(`🖱️ Click en celda ${cellIndex}`);
        console.log(`🎮 Estado actual: jugador=${this.currentPlayer}, gameOver=${this.gameOver}, waiting=${this.isWaitingForResponse}`);

        if (this.gameOver) {
            console.log('🚫 Juego terminado');
            return;
        }

        if (this.isWaitingForResponse) {
            console.log('⏳ Esperando respuesta del servidor');
            return;
        }

        if (this.board[cellIndex] !== null) {
            console.log('🚫 Celda ocupada');
            return;
        }

        if (this.currentPlayer !== 'X') {
            console.log(`🚫 No es tu turno (turno actual: ${this.currentPlayer})`);
            return;
        }

        console.log('✅ Movimiento válido, enviando al servidor...');
        await this.makeMove(cellIndex);
    }

    setupEventListeners() {
        document.getElementById('boardSize').addEventListener('change', (e) => {
            const newSize = parseInt(e.target.value);
            console.log(`🔄 Cambiando tamaño a ${newSize}x${newSize}`);
            this.resetGame(newSize);
        });
    }

    setupNewGameButton() {
        document.getElementById('newGame').addEventListener('click', () => {
            const size = parseInt(document.getElementById('boardSize').value);
            console.log(`🆕 Nuevo juego ${size}x${size}`);
            this.resetGame(size);
        });
    }

    resetGame(size) {
        console.log(`🔄 Reiniciando juego ${size}x${size}`);
        
        // Limpiar todo el estado del juego
        this.size = size;
        this.board = Array(this.size * this.size).fill(null);
        this.currentPlayer = 'X';
        this.gameOver = false;
        this.isWaitingForResponse = false;
        this.reconnectAttempts = 0;
        
        // Limpiar mensajes de estado
        this.updateStatusMessage('🟡 Iniciando nuevo juego...', 'connected');
        this.updateAIStatus('Verificando IA...');
        
        // Reconfigurar el tablero
        this.setupBoard();
        this.updateUI();
        this.checkAIStatus();
        
        console.log('✅ Estado del juego limpiado completamente');

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
            return;
        }

        console.log(`🎯 Haciendo movimiento en posición ${position}`);
        this.isWaitingForResponse = true;
        this.updateStatusMessage('⏳ Enviando movimiento...', 'connected');

        try {
            if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
                await this.connectWebSocket();
            }

            if (this.ws.readyState === WebSocket.OPEN) {
                const moveData = {
                    type: "player_move",
                    position: position
                };
                this.ws.send(JSON.stringify(moveData));
                console.log("📤 Movimiento enviado:", moveData);
                this.updateStatusMessage('🤖 IA pensando...', 'connected');
            } else {
                throw new Error("No hay conexión WebSocket");
            }
        } catch (error) {
            console.error("💥 Error enviando movimiento:", error);
            this.isWaitingForResponse = false;
            this.updateStatusMessage('❌ Error de conexión', 'disconnected');
            alert("Error al hacer el movimiento. Inténtalo de nuevo.");
        }
    }

    updateUI() {
        console.log('🎨 Actualizando interfaz de usuario');
        this.boardElement.querySelectorAll('.cell').forEach((cell, index) => {
            const value = this.board[index];
            
            // Limpiar completamente la celda primero
            cell.textContent = '';
            cell.style.color = '#333';
            cell.style.backgroundColor = 'white';
            cell.style.cursor = 'pointer';
            cell.classList.remove('waiting');
            
            // Aplicar el estado actual
            if (value === 'X') {
                cell.textContent = '❌';
                cell.style.color = '#e74c3c';
                cell.style.backgroundColor = '#f8f9fa';
                cell.style.cursor = 'not-allowed';
            } else if (value === 'O') {
                cell.textContent = '⭕';
                cell.style.color = '#3498db';
                cell.style.backgroundColor = '#f8f9fa';
                cell.style.cursor = 'not-allowed';
            }
        });
        
        // Aplicar clase de espera si es necesario
        if (this.isWaitingForResponse) {
            this.boardElement.querySelectorAll('.cell').forEach(cell => {
                if (!cell.textContent) {
                    cell.classList.add('waiting');
                }
            });
        }
    }
}

// Inicialización cuando el DOM esté listo
let game;
console.log('🔧 Script game.js cargado');

document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 DOM listo, iniciando Tic Tac Toe con IA');
    
    // Verificar elementos necesarios
    const boardSizeElement = document.getElementById('boardSize');
    const boardElement = document.querySelector('.game-board');
    
    if (!boardSizeElement) {
        console.error('❌ Elemento boardSize no encontrado');
        return;
    }
    
    if (!boardElement) {
        console.error('❌ Elemento game-board no encontrado');
        return;
    }
    
    console.log('✅ Elementos encontrados correctamente');
    const size = parseInt(boardSizeElement.value) || 3;
    console.log(`📏 Tamaño del tablero: ${size}`);
    
    game = new TicTacToeClient(size);
});
