#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Seletor Inteligente de Modelos Gemma
Seleciona automaticamente o modelo mais adequado baseado na criticidade e contexto
"""

import logging
import psutil
import platform
from typing import Dict, Any, Optional, Tuple
from enum import Enum
from dataclasses import dataclass

logger = logging.getLogger(__name__)

class CriticalityLevel(Enum):
    """Níveis de criticidade para seleção de modelo"""
    LOW = "low"           # Conversas gerais, perguntas simples
    MEDIUM = "medium"     # Educação, agricultura básica
    HIGH = "high"         # Primeiros socorros, emergências médicas
    CRITICAL = "critical" # Alertas ambientais, emergências extremas

class ContextType(Enum):
    """Tipos de contexto da aplicação"""
    GENERAL = "general"
    EDUCATION = "education"
    AGRICULTURE = "agriculture"
    HEALTH = "health"
    EMERGENCY = "emergency"
    ENVIRONMENTAL = "environmental"
    ACCESSIBILITY = "accessibility"

class DeviceQuality(Enum):
    """Qualidade do dispositivo baseada em especificações de hardware"""
    LOW = "low"           # RAM < 2GB, CPU fraco, armazenamento limitado
    MEDIUM = "medium"     # RAM 2-4GB, CPU médio
    HIGH = "high"         # RAM 4-8GB, CPU bom
    PREMIUM = "premium"   # RAM > 8GB, CPU excelente

@dataclass
class ModelConfig:
    """Configuração de modelo"""
    name: str
    ollama_model: str
    description: str
    criticality_threshold: CriticalityLevel
    contexts: list[ContextType]
    device_quality_threshold: DeviceQuality
    temperature: float = 0.7
    top_p: float = 0.9
    max_tokens: int = 2048
    ram_requirement_gb: float = 2.0  # RAM mínima necessária em GB
    cpu_cores_min: int = 2           # Núcleos de CPU mínimos
    storage_requirement_gb: float = 1.0  # Armazenamento mínimo em GB

class DeviceDetector:
    """Detector de qualidade do dispositivo baseado em especificações de hardware"""
    
    @staticmethod
    def get_device_specs() -> Dict[str, Any]:
        """Obtém especificações do dispositivo"""
        try:
            # Informações de memória
            memory = psutil.virtual_memory()
            ram_gb = memory.total / (1024**3)  # Converte bytes para GB
            
            # Informações de CPU
            cpu_count = psutil.cpu_count(logical=False)  # Núcleos físicos
            cpu_logical = psutil.cpu_count(logical=True)  # Núcleos lógicos
            cpu_freq = psutil.cpu_freq()
            
            # Informações de armazenamento
            disk = psutil.disk_usage('/')
            storage_total_gb = disk.total / (1024**3)
            storage_free_gb = disk.free / (1024**3)
            
            # Informações do sistema
            system_info = {
                'platform': platform.system(),
                'architecture': platform.architecture()[0],
                'processor': platform.processor()
            }
            
            return {
                'ram_gb': round(ram_gb, 2),
                'cpu_cores_physical': cpu_count,
                'cpu_cores_logical': cpu_logical,
                'cpu_freq_mhz': cpu_freq.current if cpu_freq else 0,
                'storage_total_gb': round(storage_total_gb, 2),
                'storage_free_gb': round(storage_free_gb, 2),
                'system': system_info
            }
        except Exception as e:
            logger.warning(f"Erro ao detectar especificações do dispositivo: {e}")
            # Retorna especificações mínimas como fallback
            return {
                'ram_gb': 1.0,
                'cpu_cores_physical': 1,
                'cpu_cores_logical': 1,
                'cpu_freq_mhz': 1000,
                'storage_total_gb': 8.0,
                'storage_free_gb': 2.0,
                'system': {'platform': 'Unknown', 'architecture': 'Unknown', 'processor': 'Unknown'}
            }
    
    @staticmethod
    def detect_device_quality(specs: Optional[Dict[str, Any]] = None) -> DeviceQuality:
        """Detecta a qualidade do dispositivo baseada nas especificações"""
        if specs is None:
            specs = DeviceDetector.get_device_specs()
        
        ram_gb = specs.get('ram_gb', 1.0)
        cpu_cores = specs.get('cpu_cores_physical', 1)
        cpu_freq = specs.get('cpu_freq_mhz', 1000)
        
        # Lógica de classificação baseada em RAM, CPU e frequência
        if ram_gb >= 8 and cpu_cores >= 4 and cpu_freq >= 2500:
            return DeviceQuality.PREMIUM
        elif ram_gb >= 4 and cpu_cores >= 2 and cpu_freq >= 2000:
            return DeviceQuality.HIGH
        elif ram_gb >= 2 and cpu_cores >= 2 and cpu_freq >= 1500:
            return DeviceQuality.MEDIUM
        else:
            return DeviceQuality.LOW
    
    @staticmethod
    def can_run_model(model_config: ModelConfig, specs: Optional[Dict[str, Any]] = None) -> bool:
        """Verifica se o dispositivo pode executar um modelo específico"""
        if specs is None:
            specs = DeviceDetector.get_device_specs()
        
        ram_gb = specs.get('ram_gb', 1.0)
        cpu_cores = specs.get('cpu_cores_physical', 1)
        storage_free_gb = specs.get('storage_free_gb', 1.0)
        
        # Verifica se atende aos requisitos mínimos
        ram_ok = ram_gb >= model_config.ram_requirement_gb
        cpu_ok = cpu_cores >= model_config.cpu_cores_min
        storage_ok = storage_free_gb >= model_config.storage_requirement_gb
        
        return ram_ok and cpu_ok and storage_ok

class IntelligentModelSelector:
    """Seletor inteligente de modelos baseado em criticidade, contexto e qualidade do dispositivo"""
    
    # Configuração dos modelos Ollama disponíveis
    MODELS = {
        "gemma3n:e4b": ModelConfig(
            name="Gemma 3n E4B",
            ollama_model="gemma3n:e4b",
            description="Modelo de 4B parâmetros com máxima capacidade (requer ~3GB RAM)",
            criticality_threshold=CriticalityLevel.CRITICAL,
            contexts=[ContextType.EMERGENCY, ContextType.HEALTH, ContextType.ENVIRONMENTAL, ContextType.EDUCATION, ContextType.AGRICULTURE],
            device_quality_threshold=DeviceQuality.HIGH,
            temperature=0.2,
            top_p=0.7,
            max_tokens=8192,
            ram_requirement_gb=3.0,  # Conforme especificação oficial (não 4GB)
            cpu_cores_min=4,
            storage_requirement_gb=2.5
        ),
        "gemma3n:e2b": ModelConfig(
            name="Gemma 3n E2B",
            ollama_model="gemma3n:e2b",
            description="Modelo de 2B parâmetros otimizado para emergências (requer ~2GB RAM)",
            criticality_threshold=CriticalityLevel.HIGH,
            contexts=[ContextType.EMERGENCY, ContextType.HEALTH, ContextType.ENVIRONMENTAL],
            device_quality_threshold=DeviceQuality.MEDIUM,
            temperature=0.3,
            top_p=0.8,
            max_tokens=4096,
            ram_requirement_gb=2.0,  # Conforme especificação oficial
            cpu_cores_min=2,
            storage_requirement_gb=1.5
        ),
        "gemma3n:latest": ModelConfig(
            name="Gemma 3n Latest",
            ollama_model="gemma3n:latest",
            description="Versão mais recente (geralmente aponta para E4B)",
            criticality_threshold=CriticalityLevel.MEDIUM,
            contexts=[ContextType.GENERAL, ContextType.HEALTH, ContextType.EDUCATION, ContextType.AGRICULTURE],
            device_quality_threshold=DeviceQuality.MEDIUM,
            temperature=0.5,
            top_p=0.85,
            max_tokens=4096,
            ram_requirement_gb=2.5,  # Valor intermediário já que aponta para E4B
            cpu_cores_min=2,
            storage_requirement_gb=2.0
        ),
        "gemma3n:lite": ModelConfig(
            name="Gemma 3n Lite",
            ollama_model="gemma3n:lite",
            description="Modelo ultra-leve para dispositivos com RAM muito baixa",
            criticality_threshold=CriticalityLevel.LOW,
            contexts=[ContextType.GENERAL, ContextType.ACCESSIBILITY],
            device_quality_threshold=DeviceQuality.LOW,
            temperature=0.8,
            top_p=0.95,
            max_tokens=1024,
            ram_requirement_gb=0.5,
            cpu_cores_min=1,
            storage_requirement_gb=0.3
        )
    }
    
    # Mapeamento de contextos para níveis de criticidade
    CONTEXT_CRITICALITY = {
        ContextType.ENVIRONMENTAL: CriticalityLevel.CRITICAL,
        ContextType.EMERGENCY: CriticalityLevel.CRITICAL,
        ContextType.HEALTH: CriticalityLevel.HIGH,
        ContextType.EDUCATION: CriticalityLevel.MEDIUM,
        ContextType.AGRICULTURE: CriticalityLevel.MEDIUM,
        ContextType.ACCESSIBILITY: CriticalityLevel.MEDIUM,
        ContextType.GENERAL: CriticalityLevel.LOW
    }
    
    # Palavras-chave para detecção automática de criticidade
    CRITICAL_KEYWORDS = {
        CriticalityLevel.CRITICAL: [
            "emergência", "urgente", "perigo", "risco", "alerta", "catástrofe",
            "desastre", "tsunami", "terremoto", "incêndio", "inundação",
            "envenenamento", "overdose", "parada cardíaca", "asfixia",
            "emergency", "urgent", "danger", "risk", "alert", "catastrophe"
        ],
        CriticalityLevel.HIGH: [
            "dor", "ferimento", "sangramento", "febre", "infecção", "fratura",
            "queimadura", "corte", "machucado", "doente", "mal estar",
            "pain", "injury", "bleeding", "fever", "infection", "fracture",
            "burn", "cut", "hurt", "sick", "illness"
        ],
        CriticalityLevel.MEDIUM: [
            "ensinar", "aprender", "estudar", "plantar", "colher", "cultivar",
            "praga", "doença da planta", "fertilizante", "irrigação",
            "teach", "learn", "study", "plant", "harvest", "cultivate",
            "pest", "plant disease", "fertilizer", "irrigation"
        ]
    }
    
    @classmethod
    def detect_criticality_from_text(cls, text: str) -> CriticalityLevel:
        """Detecta nível de criticidade baseado no texto"""
        text_lower = text.lower()
        
        # Verifica palavras críticas primeiro
        for keyword in cls.CRITICAL_KEYWORDS[CriticalityLevel.CRITICAL]:
            if keyword in text_lower:
                return CriticalityLevel.CRITICAL
        
        # Verifica palavras de alta prioridade
        for keyword in cls.CRITICAL_KEYWORDS[CriticalityLevel.HIGH]:
            if keyword in text_lower:
                return CriticalityLevel.HIGH
        
        # Verifica palavras de média prioridade
        for keyword in cls.CRITICAL_KEYWORDS[CriticalityLevel.MEDIUM]:
            if keyword in text_lower:
                return CriticalityLevel.MEDIUM
        
        return CriticalityLevel.LOW
    
    @classmethod
    def detect_criticality(cls, text: str) -> CriticalityLevel:
        """Detecta o nível de criticidade baseado no texto"""
        text_lower = text.lower()
        
        # Palavras-chave para criticidade alta/crítica
        critical_keywords = [
            'urgente', 'emergência', 'crítico', 'alerta', 'evacuação',
            'perigo', 'risco', 'morte', 'ferimento', 'sangramento',
            'inconsciente', 'parada', 'ataque', 'envenenamento'
        ]
        
        high_keywords = [
            'importante', 'sério', 'preocupante', 'ajuda',
            'problema', 'dificuldade', 'tratamento', 'cuidado'
        ]
        
        # Verificar criticidade
        if any(keyword in text_lower for keyword in critical_keywords):
            return CriticalityLevel.CRITICAL
        elif any(keyword in text_lower for keyword in high_keywords):
            return CriticalityLevel.HIGH
        else:
            return CriticalityLevel.LOW
    
    @classmethod
    def detect_context_from_text(cls, text: str) -> ContextType:
        """Detecta contexto baseado no texto"""
        text_lower = text.lower()
        
        # Palavras-chave por contexto
        context_keywords = {
            ContextType.ENVIRONMENTAL: [
                "ambiente", "clima", "tempo", "chuva", "seca", "poluição",
                "desmatamento", "água", "ar", "solo", "natureza"
            ],
            ContextType.EMERGENCY: [
                "emergência", "socorro", "ajuda", "urgente", "911", "192",
                "bombeiros", "polícia", "ambulância", "resgate"
            ],
            ContextType.HEALTH: [
                "saúde", "médico", "hospital", "remédio", "tratamento",
                "sintoma", "doença", "medicina", "primeiros socorros"
            ],
            ContextType.EDUCATION: [
                "ensino", "escola", "professor", "aluno", "aprender",
                "estudar", "lição", "matéria", "educação", "conhecimento"
            ],
            ContextType.AGRICULTURE: [
                "agricultura", "plantação", "colheita", "fazenda", "roça",
                "sementes", "fertilizante", "praga", "irrigação", "cultivo"
            ],
            ContextType.ACCESSIBILITY: [
                "acessibilidade", "deficiência", "inclusão", "adaptação",
                "voz", "áudio", "visual", "motor", "cognitivo"
            ]
        }
        
        # Conta ocorrências por contexto
        context_scores = {}
        for context, keywords in context_keywords.items():
            score = sum(1 for keyword in keywords if keyword in text_lower)
            if score > 0:
                context_scores[context] = score
        
        # Retorna contexto com maior pontuação
        if context_scores:
            return max(context_scores, key=context_scores.get)
        
        return ContextType.GENERAL
    
    @classmethod
    def detect_context(cls, text: str) -> ContextType:
        """Detecta o tipo de contexto baseado no texto"""
        text_lower = text.lower()
        
        # Palavras-chave por contexto
        medical_keywords = [
            'médico', 'saúde', 'doença', 'sintoma', 'tratamento',
            'medicamento', 'hospital', 'doutor', 'enfermeiro',
            'ferimento', 'dor', 'febre', 'parto', 'gravidez'
        ]
        
        agricultural_keywords = [
            'agricultura', 'plantio', 'colheita', 'sementes', 'solo',
            'irrigação', 'fertilizante', 'praga', 'cultivo',
            'mandioca', 'arroz', 'milho', 'horta', 'roça'
        ]
        
        educational_keywords = [
            'educação', 'ensino', 'escola', 'professor', 'aluno',
            'aula', 'matemática', 'português', 'ciências',
            'aprender', 'estudar', 'livro', 'material'
        ]
        
        environmental_keywords = [
            'ambiente', 'clima', 'tempo', 'chuva', 'seca',
            'enchente', 'vento', 'temperatura', 'poluição'
        ]
        
        # Verificar contexto
        if any(keyword in text_lower for keyword in medical_keywords):
            return ContextType.HEALTH
        elif any(keyword in text_lower for keyword in agricultural_keywords):
            return ContextType.AGRICULTURE
        elif any(keyword in text_lower for keyword in educational_keywords):
            return ContextType.EDUCATION
        elif any(keyword in text_lower for keyword in environmental_keywords):
            return ContextType.ENVIRONMENTAL
        else:
            return ContextType.GENERAL
    
    @classmethod
    def select_model(
        cls,
        text: str = "",
        context: Optional[ContextType] = None,
        criticality: Optional[CriticalityLevel] = None,
        forced_model: Optional[str] = None,
        device_specs: Optional[Dict[str, Any]] = None
    ) -> Tuple[str, ModelConfig]:
        """Seleciona o modelo mais adequado baseado em criticidade, contexto e qualidade do dispositivo
        
        Args:
            text: Texto para análise automática
            context: Contexto específico (opcional)
            criticality: Nível de criticidade específico (opcional)
            forced_model: Força uso de modelo específico
            device_specs: Especificações do dispositivo (opcional, será detectado automaticamente)
            
        Returns:
            Tuple[str, ModelConfig]: (modelo_ollama, configuração)
        """
        
        # Se modelo forçado, verifica se o dispositivo pode executá-lo
        if forced_model and forced_model in cls.MODELS:
            model_config = cls.MODELS[forced_model]
            if DeviceDetector.can_run_model(model_config, device_specs):
                logger.info(f"Usando modelo forçado: {forced_model}")
                return forced_model, model_config
            else:
                logger.warning(f"Dispositivo não atende aos requisitos do modelo forçado {forced_model}, selecionando automaticamente")
        
        # Detecta qualidade do dispositivo
        if device_specs is None:
            device_specs = DeviceDetector.get_device_specs()
        device_quality = DeviceDetector.detect_device_quality(device_specs)
        
        # Detecta contexto e criticidade automaticamente se não fornecidos
        if context is None and text:
            context = cls.detect_context_from_text(text)
        
        if criticality is None and text:
            criticality = cls.detect_criticality_from_text(text)
        
        # Se ainda não detectou, usa padrões
        if context is None:
            context = ContextType.GENERAL
        
        if criticality is None:
            # Usa criticidade baseada no contexto
            criticality = cls.CONTEXT_CRITICALITY.get(context, CriticalityLevel.LOW)
        
        # Lista de modelos candidatos baseados na criticidade (em ordem de preferência)
        candidate_models = []
        
        if criticality == CriticalityLevel.CRITICAL:
            candidate_models = ["gemma3n:e4b", "gemma3n:e2b", "gemma3n:latest", "gemma3n:lite"]
        elif criticality == CriticalityLevel.HIGH:
            candidate_models = ["gemma3n:e2b", "gemma3n:latest", "gemma3n:lite"]
        else:
            candidate_models = ["gemma3n:latest", "gemma3n:lite"]
        
        # Seleciona o melhor modelo que o dispositivo pode executar
        selected_model = None
        fallback_reason = ""
        
        for model_name in candidate_models:
            if model_name in cls.MODELS:
                model_config = cls.MODELS[model_name]
                if DeviceDetector.can_run_model(model_config, device_specs):
                    selected_model = model_name
                    break
                else:
                    fallback_reason = f"Dispositivo não atende aos requisitos de {model_name}"
        
        # Se nenhum modelo pode ser executado, usa o mais leve como último recurso
        if selected_model is None:
            selected_model = "gemma3n:lite"
            logger.warning(f"Forçando uso do modelo mais leve devido a limitações de hardware: {fallback_reason}")
        
        model_config = cls.MODELS[selected_model]
        
        # Log detalhado da seleção
        ram_gb = device_specs.get('ram_gb', 0)
        cpu_cores = device_specs.get('cpu_cores_physical', 0)
        
        logger.info(
            f"Modelo selecionado: {model_config.name} | "
            f"Contexto: {context.value} | "
            f"Criticidade: {criticality.value} | "
            f"Qualidade do dispositivo: {device_quality.value} | "
            f"RAM: {ram_gb}GB | CPU: {cpu_cores} cores | "
            f"Temperatura: {model_config.temperature}"
        )
        
        if fallback_reason:
            logger.info(f"Razão do fallback: {fallback_reason}")
        
        return selected_model, model_config
    
    @classmethod
    def get_model_info(cls, model_name: str) -> Dict[str, Any]:
        """Retorna informações sobre um modelo específico"""
        if model_name in cls.MODELS:
            config = cls.MODELS[model_name]
            return {
                "name": config.name,
                "ollama_model": config.ollama_model,
                "description": config.description,
                "criticality_threshold": config.criticality_threshold.value,
                "contexts": [ctx.value for ctx in config.contexts],
                "config": {
                    "temperature": config.temperature,
                    "top_p": config.top_p,
                    "max_tokens": config.max_tokens
                }
            }
        return {}
    
    @classmethod
    def list_available_models(cls) -> Dict[str, Dict[str, Any]]:
        """Lista todos os modelos disponíveis"""
        return {model: cls.get_model_info(model) for model in cls.MODELS.keys()}