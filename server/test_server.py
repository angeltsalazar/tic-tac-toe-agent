from fastapi import FastAPI
import uvicorn
import os

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Servidor funcionando en Linux!"}

@app.get("/health")
async def health():
    return {
        "status": "OK",
        "platform": "Linux",
        "directory": os.getcwd()
    }

if __name__ == "__main__":
    print("🚀 Iniciando servidor de prueba...")
    uvicorn.run(
        "test_server:app",
        host="0.0.0.0",
        port=8000,
        reload=False,
        log_level="info"
    )
