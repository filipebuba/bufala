#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Configuração do Moransa Backend
Hackathon Gemma 3n
"""

import os
import re
from typing import Dict, Any, Optional, Tuple

class QueryAnalyzer:
    """Analisador de consultas para otimização adaptativa"""
    
    # Padrões para classificação de consultas
    FACTUAL_PATTERNS = [
        r'\b(what|quando|onde|quem|qual|como)\b',
        r'\b(define|explique|o que é)\b',
        r'\b(data|hora|número|quantidade)\b',
        r'\?$'  # Perguntas diretas
    ]
    
    COMPLEX_PATTERNS = [
        r'\b(analise|compare|avalie|discuta)\b',
        r'\b(porque|por que|razão|motivo)\b',
        r'\b(vantagens|desvantagens|prós|contras)\b',
        r'\b(estratégia|plano|método|abordagem)\b'
    ]
    
    CREATIVE_PATTERNS = [
        r'\b(crie|invente|imagine|sugira)\b',
        r'\b(história|poema|música|arte)\b',
        r'\b(criativo|inovador|original)\b',
        r'\b(brainstorm|ideias|inspiração)\b'
    ]
    
    @classmethod
    def analyze_query(cls, query: str) -> Tuple[str, Dict[str, Any]]:
        """Analisa uma consulta e retorna o tipo e configurações otimizadas"""
        if not query:
            return "standard", cls._get_standard_config(0)
        
        query_lower = query.lower()
        query_length = len(query.split())
        
        # Verificar padrões criativos primeiro (mais específicos)
        for pattern in cls.CREATIVE_PATTERNS:
            if re.search(pattern, query_lower):
                return "creative", cls._get_creative_config(query_length)
        
        # Verificar padrões complexos
        for pattern in cls.COMPLEX_PATTERNS:
            if re.search(pattern, query_lower):
                return "complex", cls._get_complex_config(query_length)
        
        # Verificar padrões factuais
        for pattern in cls.FACTUAL_PATTERNS:
            if re.search(pattern, query_lower):
                return "factual", cls._get_factual_config(query_length)
        
        # Padrão baseado no comprimento
        if query_length <= 5:
            return "factual", cls._get_factual_config(query_length)
        elif query_length > 20:
            return "complex", cls._get_complex_config(query_length)
        else:
            return "standard", cls._get_standard_config(query_length)
    
    @staticmethod
    def _get_factual_config(query_length: int) -> Dict[str, Any]:
        """Configurações otimizadas para consultas factuais simples"""
        return {
            'max_new_tokens': min(200, 100 + query_length * 8),
            'temperature': 0.3,
            'top_p': 0.85,
            'top_k': 40,
            'repetition_penalty': 1.1,
            'no_repeat_ngram_size': 3,
            'early_stopping': True,
            'max_time': 15.0,  # Aumentado de 5.0 para 15.0 segundos
        }
    
    @staticmethod
    def _get_standard_config(query_length: int) -> Dict[str, Any]:
        """Configurações padrão para consultas gerais"""
        return {
            'max_new_tokens': min(600, 300 + query_length * 15),
            'temperature': 0.7,
            'top_p': 0.9,
            'top_k': 50,
            'repetition_penalty': 1.2,
            'no_repeat_ngram_size': 3,
            'early_stopping': True,
            'max_time': 45.0,  # Aumentado de 15.0 para 45.0 segundos
        }
    
    @staticmethod
    def _get_complex_config(query_length: int) -> Dict[str, Any]:
        """Configurações para consultas complexas"""
        return {
            'max_new_tokens': min(1200, 500 + query_length * 20),
            'temperature': 0.8,
            'top_p': 0.92,
            'top_k': 60,
            'repetition_penalty': 1.3,
            'no_repeat_ngram_size': 4,
            'early_stopping': False,
            'max_time': 90.0,  # Aumentado de 30.0 para 90.0 segundos
        }
    
    @staticmethod
    def _get_creative_config(query_length: int) -> Dict[str, Any]:
        """Configurações para consultas criativas"""
        return {
            'max_new_tokens': min(1500, 600 + query_length * 25),
            'temperature': 0.9,
            'top_p': 0.95,
            'top_k': 80,
            'repetition_penalty': 1.1,
            'no_repeat_ngram_size': 2,
            'early_stopping': False,
            'max_time': 120.0,  # Aumentado de 45.0 para 120.0 segundos
        }

class BackendConfig:
    """Configurações principais do backend"""
    
    # Configurações do servidor
    HOST = "0.0.0.0"
    PORT = int(os.getenv('PORT', '5000'))
    DEBUG = False
    
    # Configurações de timeout - Aumentados para análises mais detalhadas
    REQUEST_TIMEOUT = 600  # Aumentado de 300 para 600 segundos
    SEND_FILE_MAX_AGE_DEFAULT = 0
    
    # Configurações do modelo - Suporte Ollama + Gemma-3n
    USE_OLLAMA = True
    OLLAMA_HOST = "http://localhost:11434"
    OLLAMA_MODEL = "gemma3n:latest"
    
    # Configurações do modelo Gemma-3n (fallback)
    MODEL_PATH = "google/gemma-3n-E2B-it"
    MODEL_NAME = "google/gemma-3n-E2B-it"
    
    # Configurações do Kaggle para acesso ao Gemma-3n
    KAGGLE_USERNAME = os.getenv('KAGGLE_USERNAME')
    KAGGLE_KEY = os.getenv('KAGGLE_KEY')
    KAGGLE_CONFIG_PATH = os.getenv('KAGGLE_CONFIG_PATH', '../../kaggle.json')
    
    # Diretório de cache dos modelos
    MODEL_CACHE_DIR = os.getenv('MODEL_CACHE_DIR', './models')
    
    # Configurações de geração - Otimizadas para análises detalhadas
    MAX_NEW_TOKENS = 1024  # Aumentado de 512 para 1024 tokens
    TEMPERATURE = 0.7
    TOP_P = 0.9
    TOP_K = 50
    REPETITION_PENALTY = 1.2
    NO_REPEAT_NGRAM_SIZE = 3
    MAX_TIME = 60.0  # Aumentado de 30 para 60 segundos
    
    # Configurações de contexto
    MAX_CONTEXT_TOKENS = 32768
    MAX_INPUT_LENGTH = 512
    
    # Configurações de dispositivo
    USE_CUDA = os.getenv('USE_CUDA', 'true').lower() == 'true'
    USE_BFLOAT16 = os.getenv('USE_BFLOAT16', 'true').lower() == 'true'
    ENABLE_OPTIMIZATIONS = os.getenv('ENABLE_OPTIMIZATIONS', 'true').lower() == 'true'
    
    # Configurações Unsloth
    USE_UNSLOTH = os.getenv('USE_UNSLOTH', 'true').lower() == 'true'
    PREFER_UNSLOTH = os.getenv('PREFER_UNSLOTH', 'true').lower() == 'true'
    UNSLOTH_MODEL_PRIMARY = os.getenv('UNSLOTH_MODEL_PRIMARY', 'unsloth/gemma-2-2b-it-bnb-4bit')
    UNSLOTH_MODEL_FALLBACK = os.getenv('UNSLOTH_MODEL_FALLBACK', 'google/gemma-2-2b-it')
    
    # Configurações de Quantização
    USE_QUANTIZATION = os.getenv('USE_QUANTIZATION', 'true').lower() == 'true'
    QUANTIZATION_BITS = int(os.getenv('QUANTIZATION_BITS', '4'))
    USE_BNB_4BIT = os.getenv('USE_BNB_4BIT', 'true').lower() == 'true'
    BNB_4BIT_COMPUTE_DTYPE = os.getenv('BNB_4BIT_COMPUTE_DTYPE', 'bfloat16')
    BNB_4BIT_USE_DOUBLE_QUANT = os.getenv('BNB_4BIT_USE_DOUBLE_QUANT', 'true').lower() == 'true'
    
    # Configurações de logging
    LOG_LEVEL = "INFO"
    LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    # Configurações multimodais
    ENABLE_MULTIMODAL = True
    MAX_IMAGE_SIZE = 768
    MAX_AUDIO_DURATION = 60
    SUPPORTED_IMAGE_FORMATS = ["JPEG", "PNG", "WEBP", "BMP"]
    SUPPORTED_AUDIO_FORMATS = ["WAV", "MP3", "M4A"]
    IMAGE_TOKENS_PER_IMAGE = 256
    AUDIO_TOKENS_PER_SECOND = 6.25
    
    # Configuração adaptativa
    ENABLE_ADAPTIVE_CONFIG = True
    
    # Configurações revolucionárias Gemma 3n
    ENABLE_REVOLUTIONARY_FEATURES = True
    ENABLE_CONTEXTUAL_TRANSLATION = True
    ENABLE_EMOTIONAL_ANALYSIS = True
    ENABLE_CULTURAL_BRIDGE = True
    ENABLE_ADAPTIVE_LEARNING = True
    
    # Configurações de tradução contextual
    CONTEXT_WINDOW_SIZE = 2048
    EMOTIONAL_ANALYSIS_THRESHOLD = 0.7
    CULTURAL_INSIGHT_DEPTH = 3
    LEARNING_ADAPTATION_RATE = 0.1
    
    # Configurações de análise multimodal avançada
    ENABLE_SCENE_UNDERSTANDING = True
    ENABLE_GESTURE_RECOGNITION = True
    ENABLE_TONE_ANALYSIS = True
    MULTIMODAL_FUSION_LAYERS = 4
    
    # Configurações de preservação cultural
    CULTURAL_CONTEXT_WEIGHT = 0.8
    PRESERVE_IDIOMS = True
    PRESERVE_CULTURAL_REFERENCES = True
    ADAPT_TO_LOCAL_CUSTOMS = True
    
    # Configurações específicas do Ollama - Aumentadas para análises detalhadas
    OLLAMA_TIMEOUT = 300  # Aumentado de 120 para 300 segundos
    OLLAMA_STREAM = True
    OLLAMA_KEEP_ALIVE = "10m"  # Aumentado de 5m para 10m
    
    @classmethod
    def get_device(cls):
        """Detectar dispositivo disponível"""
        try:
            import torch
            return "cuda" if torch.cuda.is_available() and cls.USE_CUDA else "cpu"
        except ImportError:
            return "cpu"
    
    @classmethod
    def get_torch_dtype(cls):
        """Obter dtype do torch baseado no dispositivo"""
        try:
            import torch
            if cls.get_device() == "cuda" and cls.USE_BFLOAT16:
                return torch.bfloat16
            return torch.float32
        except ImportError:
            return None
    
    @classmethod
    def get_generation_config(cls, query: Optional[str] = None) -> Dict[str, Any]:
        """Obter configurações de geração otimizadas"""
        if not cls.ENABLE_ADAPTIVE_CONFIG or not query:
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
        
        query_type, adaptive_config = QueryAnalyzer.analyze_query(query)
        
        config = {
            'do_sample': True,
            **adaptive_config
        }
        
        return config
    
    @classmethod
    def get_model_selector_config(cls) -> Dict[str, Any]:
        """Configurações para o seletor automático de modelos"""
        return {
            'use_unsloth': cls.USE_UNSLOTH,
            'prefer_unsloth': cls.PREFER_UNSLOTH,
            'primary_model': cls.UNSLOTH_MODEL_PRIMARY,
            'fallback_model': cls.UNSLOTH_MODEL_FALLBACK,
            'quantization_settings': {
                'use_quantization': cls.USE_QUANTIZATION,
                'quantization_bits': cls.QUANTIZATION_BITS,
                'use_bnb_4bit': cls.USE_BNB_4BIT,
                'bnb_4bit_compute_dtype': cls.BNB_4BIT_COMPUTE_DTYPE,
                'bnb_4bit_use_double_quant': cls.BNB_4BIT_USE_DOUBLE_QUANT
            }
        }
    
    @classmethod
    def get_query_type(cls, query: str) -> str:
        """Obtém o tipo de consulta"""
        query_type, _ = QueryAnalyzer.analyze_query(query)
        return query_type
    
    @classmethod
    def get_revolutionary_config(cls) -> Dict[str, Any]:
        """Configurações para funcionalidades revolucionárias"""
        return {
            'contextual_translation': {
                'enabled': cls.ENABLE_CONTEXTUAL_TRANSLATION,
                'context_window': cls.CONTEXT_WINDOW_SIZE,
                'cultural_weight': cls.CULTURAL_CONTEXT_WEIGHT,
                'preserve_idioms': cls.PRESERVE_IDIOMS,
                'preserve_references': cls.PRESERVE_CULTURAL_REFERENCES,
                'adapt_customs': cls.ADAPT_TO_LOCAL_CUSTOMS
            },
            'emotional_analysis': {
                'enabled': cls.ENABLE_EMOTIONAL_ANALYSIS,
                'threshold': cls.EMOTIONAL_ANALYSIS_THRESHOLD,
                'tone_analysis': cls.ENABLE_TONE_ANALYSIS
            },
            'cultural_bridge': {
                'enabled': cls.ENABLE_CULTURAL_BRIDGE,
                'insight_depth': cls.CULTURAL_INSIGHT_DEPTH
            },
            'adaptive_learning': {
                'enabled': cls.ENABLE_ADAPTIVE_LEARNING,
                'adaptation_rate': cls.LEARNING_ADAPTATION_RATE
            },
            'multimodal_advanced': {
                'scene_understanding': cls.ENABLE_SCENE_UNDERSTANDING,
                'gesture_recognition': cls.ENABLE_GESTURE_RECOGNITION,
                'fusion_layers': cls.MULTIMODAL_FUSION_LAYERS
            }
        }

class SystemPrompts:
    """Prompts de sistema para diferentes domínios"""
    
    MEDICAL = "Você é um assistente médico especializado em primeiros socorros e cuidados básicos de saúde para comunidades rurais da Guiné-Bissau. Forneça conselhos práticos e seguros, sempre recomendando buscar ajuda médica profissional quando necessário. Responda em português ou crioulo quando apropriado."
    
    EDUCATION = "Você é um professor educativo especializado em ensino para comunidades da Guiné-Bissau. Explique conceitos de forma clara, didática e culturalmente apropriada. Use exemplos locais quando possível e adapte o conteúdo para diferentes níveis de escolaridade."
    
    AGRICULTURE = "Você é um especialista em agricultura tropical e sustentável, com conhecimento específico sobre cultivos da Guiné-Bissau. Forneça conselhos práticos sobre plantio, manejo de culturas, proteção de colheitas e técnicas agrícolas adaptadas ao clima local."
    
    WELLNESS = "Você é um coach de bem-estar com conhecimento sobre práticas de saúde mental e física adequadas para comunidades da Guiné-Bissau. Forneça orientações culturalmente sensíveis para uma vida mais saudável e equilibrada."
    
    TRANSLATION = "Você é um tradutor especializado em português, crioulo da Guiné-Bissau e outras línguas locais. Traduza de forma precisa, natural e culturalmente apropriada, preservando o contexto e significado original."
    
    ENVIRONMENTAL = "Você é um especialista em meio ambiente e sustentabilidade com foco na região da Guiné-Bissau. Forneça orientações ecológicas práticas, considerando o clima tropical, biodiversidade local e desafios ambientais específicos da região."
    
    GENERAL = "Você é um assistente útil e educativo especializado em ajudar comunidades da Guiné-Bissau. Responda de forma clara, precisa e culturalmente apropriada, considerando o contexto local e as necessidades específicas da região."
    
    # Prompts multimodais
    IMAGE_ANALYSIS = "Você é um especialista em análise de imagens com conhecimento sobre a Guiné-Bissau. Descreva o que vê de forma detalhada e precisa, identificando elementos relevantes para o contexto local."
    
    MEDICAL_IMAGE = "Você é um especialista em análise de imagens médicas. Analise esta imagem cuidadosamente e forneça observações relevantes para primeiros socorros ou cuidados básicos. IMPORTANTE: Esta análise não substitui consulta médica profissional."
    
    AUDIO_TRANSCRIPTION = "Você é um especialista em transcrição de áudio com conhecimento de português e crioulo da Guiné-Bissau. Transcreva com precisão o conteúdo do áudio, identificando o idioma e fornecendo contexto quando necessário."
    
    # Prompts revolucionários para Gemma 3n
    CONTEXTUAL_TRANSLATION = """Você é um tradutor revolucionário com capacidades avançadas de análise contextual e cultural. 
    Sua missão é traduzir não apenas palavras, mas o significado completo, incluindo:
    - Contexto emocional e social
    - Referências culturais da Guiné-Bissau
    - Nuances linguísticas do crioulo
    - Adaptação para diferentes situações (médica, educacional, agrícola)
    - Preservação de expressões idiomáticas locais
    
    Analise profundamente o contexto antes de traduzir e forneça insights culturais quando relevante."""
    
    EMOTIONAL_ANALYSIS = """Você é um especialista em análise emocional e psicológica com conhecimento profundo da cultura da Guiné-Bissau.
    Analise o tom emocional, intenções subjacentes e contexto psicológico das comunicações.
    Considere fatores culturais locais, expressões emocionais típicas e padrões de comunicação da região.
    Forneça insights sobre o estado emocional e sugestões de resposta culturalmente apropriadas."""
    
    CULTURAL_BRIDGE = """Você é um especialista em ponte cultural entre diferentes comunidades da Guiné-Bissau e o mundo.
    Sua função é explicar conceitos, tradições e práticas de forma que sejam compreensíveis entre diferentes culturas.
    Identifique diferenças culturais, explique contextos locais e sugira formas de comunicação mais efetiva.
    Preserve a riqueza cultural enquanto facilita o entendimento mútuo."""
    
    ADAPTIVE_LEARNING = """Você é um sistema de aprendizado adaptativo que evolui com cada interação.
    Analise padrões de uso, preferências linguísticas e necessidades específicas dos usuários.
    Adapte suas respostas baseado no histórico de interações e feedback recebido.
    Melhore continuamente a qualidade das traduções e sugestões oferecidas."""
    
    MULTIMODAL_FUSION = """Você é um especialista em análise multimodal avançada.
    Combine informações de texto, imagem, áudio e contexto para fornecer análises completas.
    Identifique gestos, expressões faciais, tom de voz e elementos visuais relevantes.
    Integre todas as modalidades para uma compreensão holística da comunicação."""
    
    @classmethod
    def get_prompt(cls, subject: str) -> str:
        """Obter prompt de sistema para um assunto específico"""
        prompts = {
            'medical': cls.MEDICAL,
            'education': cls.EDUCATION,
            'agriculture': cls.AGRICULTURE,
            'wellness': cls.WELLNESS,
            'translate': cls.TRANSLATION,
            'environmental': cls.ENVIRONMENTAL,
            'general': cls.GENERAL,
            'image_analysis': cls.IMAGE_ANALYSIS,
            'medical_image': cls.MEDICAL_IMAGE,
            'audio_transcription': cls.AUDIO_TRANSCRIPTION,
            # Novos prompts revolucionários
            'contextual_translation': cls.CONTEXTUAL_TRANSLATION,
            'emotional_analysis': cls.EMOTIONAL_ANALYSIS,
            'cultural_bridge': cls.CULTURAL_BRIDGE,
            'adaptive_learning': cls.ADAPTIVE_LEARNING,
            'multimodal_fusion': cls.MULTIMODAL_FUSION
        }
        return prompts.get(subject, cls.GENERAL)
