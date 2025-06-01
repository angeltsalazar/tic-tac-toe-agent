// Versión forzada de game.js para diagnosticar problemas
console.log('🔧 game-forced.js cargado');

// Función para forzar la creación del tablero
function forceCreateBoard() {
    console.log('💪 Forzando creación del tablero');
    
    const boardElement = document.querySelector('.game-board');
    if (!boardElement) {
        console.error('❌ No se encontró .game-board');
        return;
    }
    
    // Forzar estilos inline
    boardElement.style.display = 'grid';
    boardElement.style.gridTemplateColumns = 'repeat(3, 100px)';
    boardElement.style.gridGap = '5px';
    boardElement.style.margin = '20px auto';
    boardElement.style.width = 'fit-content';
    boardElement.style.border = '3px solid red'; // Borde rojo para debugging
    boardElement.style.padding = '10px';
    boardElement.style.backgroundColor = '#f0f8ff';
    
    // Limpiar contenido
    boardElement.innerHTML = '';
    
    // Crear 9 celdas con contenido visible
    for (let i = 0; i < 9; i++) {
        const cell = document.createElement('div');
        cell.className = 'cell';
        cell.style.width = '100px';
        cell.style.height = '100px';
        cell.style.border = '2px solid #333';
        cell.style.display = 'flex';
        cell.style.alignItems = 'center';
        cell.style.justifyContent = 'center';
        cell.style.fontSize = '40px';
        cell.style.fontWeight = 'bold';
        cell.style.cursor = 'pointer';
        cell.style.backgroundColor = 'white';
        
        // Contenido inicial para verificar visibilidad
        if (i === 0) cell.innerHTML = '❌';
        else if (i === 4) cell.innerHTML = '⭕';
        else if (i === 8) cell.innerHTML = '❌';
        else cell.innerHTML = (i + 1).toString();
        
        cell.onclick = function() {
            console.log(`🖱️ Click en celda ${i}`);
            if (cell.innerHTML === (i + 1).toString()) {
                cell.innerHTML = i % 2 === 0 ? '❌' : '⭕';
            } else {
                cell.innerHTML = (i + 1).toString();
            }
        };
        
        boardElement.appendChild(cell);
        console.log(`✅ Celda ${i} creada y agregada`);
    }
    
    console.log('🎉 Tablero forzado completado');
    console.log('📊 Estado final:');
    console.log('  - Elemento:', boardElement);
    console.log('  - Hijos:', boardElement.children.length);
    console.log('  - Display:', boardElement.style.display);
    console.log('  - Grid:', boardElement.style.gridTemplateColumns);
}

// Múltiples intentos de inicialización
console.log('🚀 Iniciando múltiples intentos de creación del tablero');

// Intento 1: Inmediato
if (document.readyState !== 'loading') {
    console.log('📄 DOM ya listo, intento inmediato');
    forceCreateBoard();
}

// Intento 2: DOMContentLoaded
document.addEventListener('DOMContentLoaded', () => {
    console.log('📄 DOMContentLoaded disparado');
    setTimeout(forceCreateBoard, 100);
});

// Intento 3: window.onload
window.addEventListener('load', () => {
    console.log('🪟 Window load disparado');
    setTimeout(forceCreateBoard, 200);
});

// Intento 4: Delay largo
setTimeout(() => {
    console.log('⏰ Intento con delay largo');
    forceCreateBoard();
}, 1000);
