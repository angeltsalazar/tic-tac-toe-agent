import os
import platform
from typing import Optional

class Config:
    """Configuración multiplataforma para el proyecto"""
    
    # Configuración de Ollama
    OLLAMA_HOST = os.getenv('OLLAMA_HOST', 'localhost')
    OLLAMA_PORT = int(os.getenv('OLLAMA_PORT', '11434'))
    OLLAMA_MODEL = os.getenv('OLLAMA_MODEL', 'llama2')
    
    # Configuración del servidor
    SERVER_HOST = os.getenv('SERVER_HOST', '0.0.0.0')
    SERVER_PORT = int(os.getenv('SERVER_PORT', '8000'))
    
    # Configuración específica por plataforma
    PLATFORM = platform.system().lower()
    
    @classmethod
    def get_ollama_url(cls) -> str:
        """Obtiene la URL completa de Ollama"""
        return f"http://{cls.OLLAMA_HOST}:{cls.OLLAMA_PORT}"
    
    @classmethod
    def is_development(cls) -> bool:
        """Detecta si estamos en desarrollo"""
        return os.getenv('ENVIRONMENT', 'development') == 'development'
    
    @classmethod
    def get_platform_info(cls) -> dict:
        """Información de la plataforma actual"""
        return {
            'system': cls.PLATFORM,
            'is_mac': cls.PLATFORM == 'darwin',
            'is_linux': cls.PLATFORM == 'linux',
            'is_windows': cls.PLATFORM == 'windows',
            'is_development': cls.is_development()
        }
