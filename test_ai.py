#!/usr/bin/env python3
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'server'))

try:
    from game_agent import GameAgent
    print("✅ Importación exitosa")
    
    agent = GameAgent()
    print("✅ GameAgent creado")
    
    board = [None] * 9
    move = agent.get_move(board, 'O')
    print(f"✅ Movimiento obtenido: {move}")
    print(f"✅ Tipo: {type(move)}")
    print(f"✅ Rango válido: {move is not None and 0 <= move <= 8}")
    
    if move is not None and 0 <= move <= 8:
        print("🎉 ¡IA funciona correctamente!")
        sys.exit(0)
    else:
        print("❌ IA no funciona correctamente")
        sys.exit(1)
        
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
