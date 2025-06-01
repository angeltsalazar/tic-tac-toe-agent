from fastapi import FastAPI
import uvicorn

# Crear la aplicación sin middleware por ahora
app = FastAPI(title="Tic-Tac-Toe Server")

@app.get("/")
async def root():
    return {"message": "🎯 Servidor Tic-Tac-Toe funcionando en Linux!", "status": "OK"}

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "platform": "Linux",
        "message": "Servidor funcionando correctamente"
    }

@app.get("/ollama-test")
async def test_ollama():
    """Endpoint para probar conectividad con Ollama"""
    import httpx
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get("http://localhost:11434/api/tags")
            if response.status_code == 200:
                return {"ollama_status": "conectado", "models": response.json()}
            else:
                return {"ollama_status": "error", "code": response.status_code}
    except Exception as e:
        return {"ollama_status": "no disponible", "error": str(e)}

if __name__ == "__main__":
    print("🚀 Iniciando servidor mínimo...")
    uvicorn.run(
        "minimal_server:app",
        host="0.0.0.0",
        port=8000,
        reload=False
    )
