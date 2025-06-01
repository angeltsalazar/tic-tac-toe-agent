// Test básico de tablero
console.log('🔧 test-board.js cargado');

function initTestBoard() {
    console.log('🚀 Iniciando test de tablero');
    
    // Verificar elementos
    const boardElement = document.querySelector('.game-board');
    const statusElement = document.getElementById('status');
    
    console.log('📍 Elementos encontrados:');
    console.log('  - boardElement:', boardElement ? '✅ Encontrado' : '❌ No encontrado');
    console.log('  - statusElement:', statusElement ? '✅ Encontrado' : '❌ No encontrado');
    
    if (!boardElement) {
        console.error('❌ No se encontró .game-board');
        return;
    }
    
    if (statusElement) {
        statusElement.textContent = '🔧 Modo debug - Test de tablero';
        statusElement.className = 'status connected';
    }
    
    // Limpiar y configurar tablero
    console.log('🧹 Limpiando tablero...');
    boardElement.innerHTML = '';
    boardElement.style.gridTemplateColumns = 'repeat(3, 100px)';
    
    console.log('🎯 Creando 9 celdas de prueba...');
    for (let i = 0; i < 9; i++) {
        const cell = document.createElement('div');
        cell.classList.add('cell');
        cell.textContent = i.toString();
        cell.style.fontSize = '20px';
        cell.style.color = '#666';
        cell.onclick = () => {
            console.log(`📱 Click en celda ${i}`);
            if (cell.textContent === i.toString()) {
                cell.textContent = i % 2 === 0 ? '❌' : '⭕';
                cell.style.fontSize = '40px';
                cell.style.color = i % 2 === 0 ? '#e74c3c' : '#3498db';
            } else {
                cell.textContent = i.toString();
                cell.style.fontSize = '20px';
                cell.style.color = '#666';
            }
        };
        boardElement.appendChild(cell);
        console.log(`  ✅ Celda ${i} creada`);
    }
    
    console.log('🎉 Tablero de prueba completado!');
    console.log('📊 Estado del tablero:');
    console.log('  - Hijos:', boardElement.children.length);
    console.log('  - Estilo grid:', boardElement.style.gridTemplateColumns);
    console.log('  - Contenido HTML:', boardElement.innerHTML.substring(0, 100) + '...');
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    console.log('📄 DOM listo');
    setTimeout(initTestBoard, 100); // Pequeño delay para asegurar que todo esté listo
});

// También intentar inicializar inmediatamente si el DOM ya está listo
if (document.readyState === 'loading') {
    console.log('⏳ DOM cargando...');
} else {
    console.log('✅ DOM ya listo, inicializando inmediatamente');
    setTimeout(initTestBoard, 100);
}
