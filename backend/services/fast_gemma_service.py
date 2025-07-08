"""
Serviço Gemma otimizado para velocidade máxima
Baseado na implementação de sucesso que conseguiu respostas rápidas
"""

import os
import logging
import torch
import time
import threading
from transformers import AutoProcessor, AutoModelForImageTextToText
from config.settings import BackendConfig
from utils.fallback_responses import FallbackResponseGenerator
import gc

logger = logging.getLogger(__name__)

class FastGemmaService:
    """Serviço Gemma otimizado para velocidade máxima"""
    
    def __init__(self):
        self.model = None
        self.processor = None
        self.is_initialized = False
        self.fallback_generator = FallbackResponseGenerator()
        self.max_generation_time = 30  # Timeout de 30 segundos
        
        self.initialize()
    
    def initialize(self):
        """Inicializar com foco em velocidade"""
        try:
            logger.info("🚀 Inicializando Gemma-3n para velocidade máxima...")
            
            if not os.path.exists(BackendConfig.MODEL_PATH):
                logger.error(f"❌ Modelo não encontrado: {BackendConfig.MODEL_PATH}")
                return False
            
            # Carregar processor (mais eficiente que tokenizer separado)
            logger.info("📦 Carregando processor...")
            self.processor = AutoProcessor.from_pretrained(
                BackendConfig.MODEL_PATH,
                trust_remote_code=True,
                local_files_only=True
            )
            
            # Carregar modelo com configurações otimizadas para velocidade
            logger.info("🧠 Carregando modelo com otimizações de velocidade...")
            self.model = AutoModelForImageTextToText.from_pretrained(
                BackendConfig.MODEL_PATH,
                torch_dtype="auto",         # Deixar PyTorch decidir
                device_map="auto",          # Distribuição automática
                trust_remote_code=True,
                local_files_only=True,
                low_cpu_mem_usage=True     # Otimizar uso de CPU
            )
                torch_dtype="auto",        # Deixar PyTorch decidir o melhor tipo
                device_map="auto",         # Distribuição automática otimizada
                trust_remote_code=True,
                local_files_only=True,
                low_cpu_mem_usage=True
            )
            
            # Colocar modelo em modo de avaliação
            self.model.eval()
            
            logger.info("✅ Modelo Fast Gemma carregado com sucesso!")
            self.is_initialized = True
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização Fast Gemma: {e}")
            return False
    
    def generate_response(self, prompt, language='pt-BR', subject='general'):
        """Gerar resposta com timeout agressivo"""
        if not self.is_initialized:
            return self.fallback_generator.generate_response(prompt, language, subject)
        
        try:
            # Limpar cache para otimizar memória
            if torch.cuda.is_available():
                torch.cuda.empty_cache()
            gc.collect()
            
            # Usar threading para timeout rigoroso
            result_container = [None]
            exception_container = [None]
            
            def _generate_with_timeout():
                try:
                    result_container[0] = self._fast_generate(prompt, language, subject)
                except Exception as e:
                    exception_container[0] = e
            
            thread = threading.Thread(target=_generate_with_timeout)
            thread.daemon = True
            thread.start()
            
            # Aguardar apenas 30 segundos
            thread.join(timeout=self.max_generation_time)
            
            if thread.is_alive():
                logger.warning(f"⏰ Timeout na geração ({self.max_generation_time}s) - usando fallback")
                return self.fallback_generator.generate_response(prompt, language, subject)
            
            if exception_container[0]:
                logger.error(f"❌ Erro na geração: {exception_container[0]}")
                return self.fallback_generator.generate_response(prompt, language, subject)
            
            if result_container[0]:
                return result_container[0]
            else:
                return self.fallback_generator.generate_response(prompt, language, subject)
                
        except Exception as e:
            logger.error(f"❌ Erro geral na geração: {e}")
            return self.fallback_generator.generate_response(prompt, language, subject)
    
    def _fast_generate(self, prompt, language, subject):
        """Geração rápida com configurações otimizadas"""
        start_time = time.time()
        
        # Formatar prompt de forma mais simples
        formatted_prompt = self._format_simple_prompt(prompt, subject)
        logger.info(f"🔧 Gerando resposta rápida para: {prompt[:50]}...")
        
        # Processar entrada
        input_ids = self.processor(
            text=formatted_prompt, 
            return_tensors="pt"
        ).to(self.model.device, dtype=self.model.dtype)
        
        # Configurações agressivas para velocidade
        generation_config = {
            'max_new_tokens': 100,      # Limitado para velocidade
            'min_length': 10,           # Mínimo baixo
            'do_sample': True,
            'temperature': 0.7,         # Moderado
            'top_p': 0.9,
            'top_k': 30,               # Reduzido para velocidade
            'repetition_penalty': 1.1,
            'pad_token_id': self.processor.tokenizer.pad_token_id,
            'eos_token_id': self.processor.tokenizer.eos_token_id,
            'early_stopping': True,     # Parar cedo quando possível
            'disable_compile': True,    # Importante para velocidade
            'use_cache': True
        }
        
        # Gerar com configurações otimizadas
        with torch.no_grad():
            outputs = self.model.generate(
                **input_ids,
                **generation_config
            )
        
        # Decodificar resultado
        text = self.processor.batch_decode(
            outputs,
            skip_special_tokens=True,
            clean_up_tokenization_spaces=True
        )[0]
        
        # Extrair apenas a resposta (remover prompt)
        if formatted_prompt in text:
            generated_text = text.replace(formatted_prompt, "").strip()
        else:
            generated_text = text.strip()
        
        end_time = time.time()
        duration = end_time - start_time
        
        logger.info(f"✅ Resposta gerada em {duration:.2f}s ({len(generated_text)} chars)")
        
        if generated_text and len(generated_text) >= 10:
            return f"{generated_text}\n\n[⚡ Gerado em {duration:.1f}s pelo Gemma-3n Fast]"
        else:
            logger.warning(f"⚠️ Resposta muito curta: '{generated_text}'")
            return self.fallback_generator.generate_response(prompt, language, subject)
    
    def _format_simple_prompt(self, prompt, subject):
        """Formatar prompt de forma mais simples e direta"""
        if subject == 'medical':
            return f"Como assistente de saúde, responda: {prompt}"
        elif subject == 'education':
            return f"Como professor, explique: {prompt}"
        elif subject == 'agriculture':
            return f"Como especialista agrícola, responda: {prompt}"
        elif subject == 'wellness':
            return f"Como especialista em bem-estar, responda: {prompt}"
        else:
            return f"Responda de forma útil: {prompt}"
    
    def get_status(self):
        """Status do serviço rápido"""
        return {
            'service_type': 'FastGemmaService',
            'initialized': self.is_initialized,
            'model_loaded': self.model is not None,
            'processor_loaded': self.processor is not None,
            'max_generation_time': self.max_generation_time,
            'device': str(self.model.device) if self.model else 'unknown',
            'optimized_for': 'speed',
            'fallback_available': True
        }
    
    def test_speed(self):
        """Teste de velocidade"""
        if not self.is_initialized:
            return "❌ Serviço não inicializado"
        
        test_prompt = "Olá, como está?"
        start_time = time.time()
        
        try:
            response = self.generate_response(test_prompt, 'pt-BR', 'general')
            end_time = time.time()
            duration = end_time - start_time
            
            return f"✅ Teste concluído em {duration:.2f}s: {response[:100]}..."
        except Exception as e:
            return f"❌ Teste falhou: {e}"
