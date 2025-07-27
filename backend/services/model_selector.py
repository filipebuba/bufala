import os
import psutil
import torch
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
import logging

logger = logging.getLogger(__name__)

class ModelSize(Enum):
    """Tamanhos de modelo disponíveis"""
    TINY = "1b"
    SMALL = "3b" 
    MEDIUM = "4b"
    LARGE = "12b"
    XLARGE = "27b"

class ModelType(Enum):
    """Tipos de modelo disponíveis"""
    INSTRUCT = "it"
    BASE = "base"

@dataclass
class SystemResources:
    """Recursos do sistema disponíveis"""
    total_ram_gb: float
    available_ram_gb: float
    gpu_memory_gb: float
    cpu_cores: int
    has_cuda: bool
    
class ModelSelector:
    """Seletor automático de modelos Unsloth baseado em recursos e uso"""
    
    # Lista completa de modelos fourbit conforme especificado
    FOURBIT_MODELS = [
        # 4bit dynamic quants for superior accuracy and low memory use
        "unsloth/gemma-3n-E4B-it-unsloth-bnb-4bit",
        "unsloth/gemma-3n-E2B-it-unsloth-bnb-4bit",
        
        # Pretrained models
        "unsloth/gemma-3n-E4B-unsloth-bnb-4bit",
        "unsloth/gemma-3n-E2B-unsloth-bnb-4bit",
        
        # Other Gemma 3 quants
        "unsloth/gemma-3-1b-it-unsloth-bnb-4bit",
        "unsloth/gemma-3-4b-it-unsloth-bnb-4bit", 
        "unsloth/gemma-3-12b-it-unsloth-bnb-4bit",
        "unsloth/gemma-3-27b-it-unsloth-bnb-4bit",
    ]
    
    # Mapeamento de modelos por tamanho e tipo
    MODEL_MAPPING = {
        (ModelSize.TINY, ModelType.INSTRUCT): "unsloth/gemma-3-1b-it-unsloth-bnb-4bit",
        (ModelSize.SMALL, ModelType.INSTRUCT): "unsloth/gemma-3n-E2B-it-unsloth-bnb-4bit",
        (ModelSize.MEDIUM, ModelType.INSTRUCT): "unsloth/gemma-3-4b-it-unsloth-bnb-4bit",
        (ModelSize.LARGE, ModelType.INSTRUCT): "unsloth/gemma-3-12b-it-unsloth-bnb-4bit",
        (ModelSize.XLARGE, ModelType.INSTRUCT): "unsloth/gemma-3-27b-it-unsloth-bnb-4bit",
        (ModelSize.SMALL, ModelType.BASE): "unsloth/gemma-3n-E2B-unsloth-bnb-4bit",
        (ModelSize.MEDIUM, ModelType.BASE): "unsloth/gemma-3n-E4B-unsloth-bnb-4bit",
    }
    
    # Requisitos mínimos de RAM por modelo (em GB)
    MODEL_RAM_REQUIREMENTS = {
        "unsloth/gemma-3-1b-it-unsloth-bnb-4bit": 2.0,
        "unsloth/gemma-3n-E2B-it-unsloth-bnb-4bit": 4.0,
        "unsloth/gemma-3-4b-it-unsloth-bnb-4bit": 6.0,
        "unsloth/gemma-3n-E4B-it-unsloth-bnb-4bit": 6.0,
        "unsloth/gemma-3-12b-it-unsloth-bnb-4bit": 12.0,
        "unsloth/gemma-3-27b-it-unsloth-bnb-4bit": 24.0,
        "unsloth/gemma-3n-E2B-unsloth-bnb-4bit": 4.0,
        "unsloth/gemma-3n-E4B-unsloth-bnb-4bit": 6.0,
    }
    
    # Configurações otimizadas por modelo
    MODEL_CONFIGS = {
        "unsloth/gemma-3-1b-it-unsloth-bnb-4bit": {
            "max_seq_length": 2048,
            "dtype": "bfloat16",
            "load_in_4bit": True,
            "use_gradient_checkpointing": True,
        },
        "unsloth/gemma-3n-E2B-it-unsloth-bnb-4bit": {
            "max_seq_length": 4096,
            "dtype": "bfloat16", 
            "load_in_4bit": True,
            "use_gradient_checkpointing": True,
        },
        "unsloth/gemma-3-4b-it-unsloth-bnb-4bit": {
            "max_seq_length": 4096,
            "dtype": "bfloat16",
            "load_in_4bit": True,
            "use_gradient_checkpointing": True,
        },
        "unsloth/gemma-3n-E4B-it-unsloth-bnb-4bit": {
            "max_seq_length": 8192,
            "dtype": "bfloat16",
            "load_in_4bit": True,
            "use_gradient_checkpointing": True,
        },
        "unsloth/gemma-3-12b-it-unsloth-bnb-4bit": {
            "max_seq_length": 4096,
            "dtype": "bfloat16",
            "load_in_4bit": True,
            "use_gradient_checkpointing": True,
        },
        "unsloth/gemma-3-27b-it-unsloth-bnb-4bit": {
            "max_seq_length": 2048,
            "dtype": "bfloat16",
            "load_in_4bit": True,
            "use_gradient_checkpointing": True,
        },
    }
    
    @classmethod
    def get_system_resources(cls) -> SystemResources:
        """Detecta recursos do sistema disponíveis"""
        # Memória RAM
        memory = psutil.virtual_memory()
        total_ram_gb = memory.total / (1024**3)
        available_ram_gb = memory.available / (1024**3)
        
        # CPU
        cpu_cores = psutil.cpu_count(logical=True)
        
        # GPU
        has_cuda = torch.cuda.is_available()
        gpu_memory_gb = 0.0
        
        if has_cuda:
            try:
                gpu_memory_gb = torch.cuda.get_device_properties(0).total_memory / (1024**3)
            except Exception as e:
                logger.warning(f"Erro ao detectar memória GPU: {e}")
                gpu_memory_gb = 0.0
        
        return SystemResources(
            total_ram_gb=total_ram_gb,
            available_ram_gb=available_ram_gb,
            gpu_memory_gb=gpu_memory_gb,
            cpu_cores=cpu_cores,
            has_cuda=has_cuda
        )
    
    @classmethod
    def select_optimal_model(cls, 
                           task_complexity: str = "medium",
                           prefer_accuracy: bool = True,
                           force_model: Optional[str] = None) -> Tuple[str, Dict]:
        """Seleciona o modelo ótimo baseado em recursos e requisitos
        
        Args:
            task_complexity: "low", "medium", "high", "extreme"
            prefer_accuracy: Se True, prefere modelos maiores quando possível
            force_model: Força uso de modelo específico
            
        Returns:
            Tuple[str, Dict]: (nome_do_modelo, configurações)
        """
        if force_model and force_model in cls.FOURBIT_MODELS:
            return force_model, cls.MODEL_CONFIGS.get(force_model, {})
        
        resources = cls.get_system_resources()
        
        # Filtra modelos compatíveis com recursos disponíveis
        compatible_models = []
        for model in cls.FOURBIT_MODELS:
            required_ram = cls.MODEL_RAM_REQUIREMENTS.get(model, 8.0)
            if resources.available_ram_gb >= required_ram:
                compatible_models.append(model)
        
        if not compatible_models:
            # Fallback para o menor modelo
            model = "unsloth/gemma-3-1b-it-unsloth-bnb-4bit"
            logger.warning(f"Recursos insuficientes, usando modelo mínimo: {model}")
            return model, cls.MODEL_CONFIGS.get(model, {})
        
        # Seleciona modelo baseado na complexidade da tarefa
        if task_complexity == "low":
            # Prefere modelos menores e rápidos
            preferred_models = [
                "unsloth/gemma-3-1b-it-unsloth-bnb-4bit",
                "unsloth/gemma-3n-E2B-it-unsloth-bnb-4bit",
            ]
        elif task_complexity == "medium":
            # Balanceio entre velocidade e qualidade
            preferred_models = [
                "unsloth/gemma-3n-E2B-it-unsloth-bnb-4bit",
                "unsloth/gemma-3n-E4B-it-unsloth-bnb-4bit",
                "unsloth/gemma-3-4b-it-unsloth-bnb-4bit",
            ]
        elif task_complexity == "high":
            # Prefere qualidade
            preferred_models = [
                "unsloth/gemma-3n-E4B-it-unsloth-bnb-4bit",
                "unsloth/gemma-3-4b-it-unsloth-bnb-4bit",
                "unsloth/gemma-3-12b-it-unsloth-bnb-4bit",
            ]
        else:  # extreme
            # Máxima qualidade
            preferred_models = [
                "unsloth/gemma-3-12b-it-unsloth-bnb-4bit",
                "unsloth/gemma-3-27b-it-unsloth-bnb-4bit",
                "unsloth/gemma-3n-E4B-it-unsloth-bnb-4bit",
            ]
        
        # Encontra o melhor modelo disponível
        for model in preferred_models:
            if model in compatible_models:
                logger.info(f"Modelo selecionado: {model} para complexidade {task_complexity}")
                return model, cls.MODEL_CONFIGS.get(model, {})
        
        # Fallback para qualquer modelo compatível
        model = compatible_models[0]
        logger.info(f"Usando modelo fallback: {model}")
        return model, cls.MODEL_CONFIGS.get(model, {})
    
    @classmethod
    def get_model_for_domain(cls, domain: str) -> Tuple[str, Dict]:
        """Seleciona modelo otimizado para domínio específico
        
        Args:
            domain: "medical", "education", "agriculture", "translation", "general"
            
        Returns:
            Tuple[str, Dict]: (nome_do_modelo, configurações)
        """
        domain_complexity = {
            "medical": "high",      # Requer alta precisão
            "education": "medium",  # Balanceio
            "agriculture": "medium", # Balanceio
            "translation": "high",  # Requer alta qualidade
            "general": "medium",    # Uso geral
            "emergency": "high",    # Situações críticas
        }
        
        complexity = domain_complexity.get(domain, "medium")
        prefer_accuracy = domain in ["medical", "translation", "emergency"]
        
        return cls.select_optimal_model(
            task_complexity=complexity,
            prefer_accuracy=prefer_accuracy
        )
    
    @classmethod
    def get_fallback_chain(cls) -> List[str]:
        """Retorna cadeia de fallback ordenada por confiabilidade"""
        return [
            "unsloth/gemma-3n-E4B-it-unsloth-bnb-4bit",  # Primário
            "unsloth/gemma-3n-E2B-it-unsloth-bnb-4bit",  # Secundário
            "unsloth/gemma-3-4b-it-unsloth-bnb-4bit",    # Terciário
            "unsloth/gemma-3-1b-it-unsloth-bnb-4bit",    # Mínimo
        ]
    
    @classmethod
    def validate_model_availability(cls, model_name: str) -> bool:
        """Valida se o modelo está na lista de modelos suportados"""
        return model_name in cls.FOURBIT_MODELS
    
    @classmethod
    def get_model_info(cls, model_name: str) -> Dict:
        """Retorna informações detalhadas sobre um modelo"""
        if not cls.validate_model_availability(model_name):
            return {}
        
        return {
            "name": model_name,
            "ram_requirement_gb": cls.MODEL_RAM_REQUIREMENTS.get(model_name, 8.0),
            "config": cls.MODEL_CONFIGS.get(model_name, {}),
            "is_instruct": "-it-" in model_name,
            "is_quantized": "bnb-4bit" in model_name,
            "provider": "unsloth"
        }
    
    @classmethod
    def auto_configure_for_system(cls) -> Dict:
        """Configuração automática completa baseada no sistema atual"""
        resources = cls.get_system_resources()
        primary_model, primary_config = cls.select_optimal_model()
        fallback_chain = cls.get_fallback_chain()
        
        return {
            "system_resources": {
                "total_ram_gb": resources.total_ram_gb,
                "available_ram_gb": resources.available_ram_gb,
                "gpu_memory_gb": resources.gpu_memory_gb,
                "cpu_cores": resources.cpu_cores,
                "has_cuda": resources.has_cuda,
            },
            "selected_model": primary_model,
            "model_config": primary_config,
            "fallback_models": fallback_chain,
            "all_available_models": cls.FOURBIT_MODELS,
            "quantization_settings": {
                "use_quantization": True,
                "quantization_bits": 4,
                "use_bnb_4bit": True,
                "bnb_4bit_compute_dtype": "bfloat16",
                "bnb_4bit_use_double_quant": True,
            }
        }