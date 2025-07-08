"""
Serviço Gemma 3n Ultra Rápido - Implementação Simplificada
"""

import os
import logging
import torch
import time
from transformers import AutoProcessor, AutoModelForImageTextToText
from config.settings import BackendConfig
from utils.fallback_responses import FallbackResponseGenerator

logger = logging.getLogger(__name__)

class UltraFastGemmaService:
    """Serviço Gemma 3n ultra rápido baseado na implementação de sucesso"""
    
    def __init__(self):
        self.processor = None
        self.model = None
        self.is_initialized = False
        self.fallback_generator = FallbackResponseGenerator()
        self.initialize()
    
    def initialize(self):
        """Inicializar modelo de forma ultra otimizada"""
        try:
            logger.info("⚡ Inicializando Ultra Fast Gemma Service...")
            
            if not os.path.exists(BackendConfig.MODEL_PATH):
                logger.error(f"❌ Modelo não encontrado: {BackendConfig.MODEL_PATH}")
                return False
            
            start_time = time.time()
            
            # Carregar processor
            logger.info("📦 Carregando processor...")
            self.processor = AutoProcessor.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True
            )
            
            # Carregar modelo com as configurações que funcionaram
            logger.info("🧠 Carregando modelo...")
            self.model = AutoModelForImageTextToText.from_pretrained(
                BackendConfig.MODEL_PATH,
                torch_dtype="auto",
                device_map="auto", 
                local_files_only=True,
                trust_remote_code=True
            )
            
            load_time = time.time() - start_time
            self.is_initialized = True
            
            logger.info(f"✅ Ultra Fast Gemma carregado em {load_time:.2f}s!")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização: {e}")
            return False
    
    def ask_gemma(self, prompt):
        """Método principal baseado no exemplo de sucesso"""
        try:
            if not self.is_initialized:
                return self._fallback_response(prompt)
            
            start_time = time.time()
            
            # Processar input como no exemplo que funcionou
            input_ids = self.processor(
                text=prompt, 
                return_tensors="pt"
            ).to(self.model.device, dtype=self.model.dtype)
            
            # Gerar com configurações otimizadas
            outputs = self.model.generate(
                **input_ids, 
                max_new_tokens=256,         # Tamanho moderado
                do_sample=True,
                temperature=0.8,
                top_p=0.9,
                disable_compile=True        # Chave para velocidade!
            )
            
            # Decodificar como no exemplo
            text = self.processor.batch_decode(
                outputs,
                skip_special_tokens=False,
                clean_up_tokenization_spaces=False
            )
            
            generation_time = time.time() - start_time
            result = text[0]
            
            logger.info(f"✅ Resposta gerada em {generation_time:.2f}s")
            return f"{result}\n\n[Ultra Fast Gemma • {generation_time:.1f}s]"
            
        except Exception as e:
            logger.error(f"❌ Erro na geração: {e}")
            return self._fallback_response(prompt)
    
    def generate_response(self, prompt, language='pt-BR', subject='general'):
        """Interface compatível com o sistema existente"""
        # Formatar prompt baseado no assunto
        formatted_prompt = self._format_prompt(prompt, language, subject)
        return self.ask_gemma(formatted_prompt)
    
    def _format_prompt(self, prompt, language, subject):
        """Formatar prompt de forma simples e eficaz"""
        if subject == 'agriculture':
            return f"Como especialista em agricultura da Guiné-Bissau, responda em português: {prompt}"
        elif subject == 'medical':
            return f"Como profissional de saúde, responda em português: {prompt}"
        elif subject == 'education':
            return f"Como educador, explique em português: {prompt}"
        else:
            return f"Responda em português de forma útil: {prompt}"
    
    def _fallback_response(self, prompt):
        """Resposta de fallback"""
        return self.fallback_generator.generate_response(prompt, 'pt-BR', 'general')
    
    def get_status(self):
        """Status do serviço ultra rápido"""
        return {
            'service_type': 'ultra_fast_gemma',
            'initialized': self.is_initialized,
            'model_loaded': self.model is not None,
            'processor_loaded': self.processor is not None,
            'model_path': BackendConfig.MODEL_PATH,
            'optimizations': [
                'torch_dtype_auto',
                'device_map_auto', 
                'disable_compile',
                'simplified_processing'
            ],
            'version': 'gemma-3n-ultra-fast'
        }
