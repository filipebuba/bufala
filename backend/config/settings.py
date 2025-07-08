"""
Configurações do Bu Fala Backend
"""

import os
from pathlib import Path

class BackendConfig:
    """Configurações principais do backend"""
    
    # Configurações do servidor
    HOST = "0.0.0.0"
    PORT = 5000
    DEBUG = True
    
    # Configurações de timeout - AUMENTADOS para melhor geração
    REQUEST_TIMEOUT = 300  # 5 minutos para requests complexos
    SEND_FILE_MAX_AGE_DEFAULT = 0  # Desabilitar cache
    
    # Configurações do modelo Gemma-3n
    MODEL_PATH = r"C:\Users\fbg67\.cache\kagglehub\models\google\gemma-3n\transformers\gemma-3n-e2b-it\1"
    MODEL_NAME = "google/gemma-3n-e2b-it"
    
    # Configurações de geração - MELHORADAS para respostas mais completas
    MAX_NEW_TOKENS = 512  # Aumentado de 150 para 512
    TEMPERATURE = 0.7     # Aumentado de 0.3 para 0.7 (mais criativo)
    TOP_P = 0.9           # Aumentado de 0.85 para 0.9
    TOP_K = 50            # Aumentado de 40 para 50
    REPETITION_PENALTY = 1.2  # Aumentado de 1.1 para 1.2
    NO_REPEAT_NGRAM_SIZE = 3
    MAX_TIME = 30.0       # Aumentado de 12.0 para 30.0 segundos
    
    # Configurações de contexto
    MAX_CONTEXT_TOKENS = 32768  # 32K tokens (limite oficial Gemma-3n)
    MAX_INPUT_LENGTH = 512      # Para otimização de velocidade
    
    # Configurações de dispositivo
    USE_CUDA = True
    USE_BFLOAT16 = True
    ENABLE_OPTIMIZATIONS = True
    
    # Configurações de logging
    LOG_LEVEL = "INFO"
    LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    # Configurações multimodais (Gemma-3n)
    ENABLE_MULTIMODAL = True
    MAX_IMAGE_SIZE = 768  # Tamanho máximo de imagem (768x768)
    MAX_AUDIO_DURATION = 60  # Duração máxima de áudio em segundos
    SUPPORTED_IMAGE_FORMATS = ["JPEG", "PNG", "WEBP", "BMP"]
    SUPPORTED_AUDIO_FORMATS = ["WAV", "MP3", "M4A"]
    IMAGE_TOKENS_PER_IMAGE = 256  # Tokens por imagem conforme documentação
    AUDIO_TOKENS_PER_SECOND = 6.25  # Tokens por segundo de áudio
    
    @classmethod
    def get_device(cls):
        """Detectar dispositivo disponível"""
        import torch
        return "cuda" if torch.cuda.is_available() and cls.USE_CUDA else "cpu"
    
    @classmethod
    def get_torch_dtype(cls):
        """Obter dtype do torch baseado no dispositivo"""
        import torch
        if cls.get_device() == "cuda" and cls.USE_BFLOAT16:
            return torch.bfloat16
        return torch.float32
    
    @classmethod
    def get_generation_config(cls):
        """Obter configurações de geração otimizadas"""
        return {
            'max_new_tokens': cls.MAX_NEW_TOKENS,
            'do_sample': True,
            'temperature': cls.TEMPERATURE,
            'top_p': cls.TOP_P,
            'top_k': cls.TOP_K,
            'repetition_penalty': cls.REPETITION_PENALTY,
            'no_repeat_ngram_size': cls.NO_REPEAT_NGRAM_SIZE,
            'early_stopping': True,
            'max_time': cls.MAX_TIME
        }

class SystemPrompts:
    """Prompts de sistema para diferentes domínios"""
    
    MEDICAL = "Você é um assistente médico especializado. Forneça conselhos gerais de saúde. Sempre recomende consultar um médico para casos específicos."
    EDUCATION = "Você é um professor educativo. Explique conceitos de forma clara e didática."
    AGRICULTURE = "Você é um especialista em agricultura. Forneça conselhos práticos sobre cultivo e manejo de plantas."
    WELLNESS = "Você é um coach de bem-estar. Forneça orientações para uma vida mais saudável e equilibrada."
    TRANSLATION = "Você é um tradutor profissional. Traduza o texto de forma precisa e natural."
    GENERAL = "Você é um assistente útil e educativo. Responda de forma clara e precisa."
    ENVIRONMENTAL = "Você é um especialista em meio ambiente e sustentabilidade. Forneça orientações ecológicas práticas."
    
    # Prompts multimodais
    IMAGE_ANALYSIS = "Você é um especialista em análise de imagens. Descreva o que vê de forma detalhada e precisa."
    MEDICAL_IMAGE = "Você é um radiologista especializado. Analise esta imagem médica cuidadosamente e forneça observações clínicas relevantes. IMPORTANTE: Esta análise não substitui consulta médica profissional."
    AUDIO_TRANSCRIPTION = "Você é um especialista em transcrição de áudio. Transcreva com precisão o conteúdo do áudio e complete contextos quando necessário."
    
    @classmethod
    def get_prompt(cls, subject):
        """Obter prompt de sistema para um assunto específico"""
        prompts = {
            'medical': cls.MEDICAL,
            'education': cls.EDUCATION,
            'agriculture': cls.AGRICULTURE,
            'wellness': cls.WELLNESS,
            'translate': cls.TRANSLATION,
            'environmental': cls.ENVIRONMENTAL,
            'general': cls.GENERAL
        }
        return prompts.get(subject, cls.GENERAL)
