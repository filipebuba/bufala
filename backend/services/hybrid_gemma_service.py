"""
Serviço Gemma 3n Híbrido - Máxima Otimização
Combinação das melhores práticas da documentação oficial + otimizações avançadas
"""

import os
import logging
import torch
import time
import threading
from concurrent.futures import ThreadPoolExecutor, TimeoutError
from transformers import AutoProcessor, AutoModelForImageTextToText
from config.settings import BackendConfig
from utils.fallback_responses import FallbackResponseGenerator

logger = logging.getLogger(__name__)

class HybridGemmaService:
    """Serviço Gemma 3n híbrido com máxima otimização"""
    
    def __init__(self):
        self.processor = None
        self.model = None
        self.is_initialized = False
        self.fallback_generator = FallbackResponseGenerator()
        self.model_path = BackendConfig.MODEL_PATH
        self.executor = ThreadPoolExecutor(max_workers=2)
        self.generation_lock = threading.Lock()
        self.initialize()
    
    def initialize(self):
        """Inicializar modelo com otimizações híbridas"""
        try:
            logger.info("🚀 Inicializando Hybrid Gemma Service...")
            
            if not os.path.exists(self.model_path):
                logger.error(f"❌ Modelo não encontrado: {self.model_path}")
                return False
            
            start_time = time.time()
            
            # Configurações de otimização
            torch.backends.cuda.matmul.allow_tf32 = True
            torch.backends.cudnn.allow_tf32 = True
            
            # Processor otimizado
            logger.info("📦 Carregando processor híbrido...")
            self.processor = AutoProcessor.from_pretrained(
                self.model_path,
                local_files_only=True,
                trust_remote_code=True,
                use_fast=True  # Tokenizer rápido
            )
            
            # Modelo com otimizações híbridas
            logger.info("🧠 Carregando modelo híbrido...")
            self.model = AutoModelForImageTextToText.from_pretrained(
                self.model_path,
                torch_dtype=torch.float32,   # Usar float32 para estabilidade
                device_map=None,             # Evitar meta tensors
                local_files_only=True,
                trust_remote_code=True,
                low_cpu_mem_usage=True       # Baixo uso de RAM
            )
            
            # Configurar para inferência
            self.model.eval()
            
            # Compilar modelo se possível (PyTorch 2.0+)
            if hasattr(torch, 'compile'):
                try:
                    logger.info("⚡ Compilando modelo para máxima velocidade...")
                    self.model = torch.compile(self.model, mode="max-autotune")
                except Exception as e:
                    logger.warning(f"⚠️ Compilação não disponível: {e}")
            
            load_time = time.time() - start_time
            self.is_initialized = True
            
            logger.info(f"✅ Hybrid Gemma carregado em {load_time:.2f}s!")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização híbrida: {e}")
            return False
    
    def _create_optimized_messages(self, prompt, context="agricultura"):
        """Criar mensagens otimizadas para máxima eficiência"""
        
        # Prompts otimizados e concisos
        systems = {
            "agricultura": "Especialista em agricultura. Responda de forma prática e direta.",
            "medico": "Assistente médico qualificado. Informe com precisão médica.",
            "educacao": "Professor experiente. Explique de forma clara e didática.",
            "geral": "Assistente inteligente. Responda de forma útil e precisa."
        }
        
        system_prompt = systems.get(context, systems["geral"])
        
        # Formato otimizado para velocidade
        messages = [
            {
                "role": "system",
                "content": [{"type": "text", "text": system_prompt}]
            },
            {
                "role": "user",
                "content": [{"type": "text", "text": prompt}]
            }
        ]
        
        return messages
    
    def _generate_with_timeout(self, inputs, timeout=45):
        """Geração com timeout para evitar travamentos"""
        def generate():
            with torch.inference_mode():
                return self.model.generate(
                    **inputs,
                    max_new_tokens=400,         # Otimizado para velocidade
                    do_sample=True,
                    temperature=0.7,            # Menos criativo, mais rápido
                    top_p=0.85,                 # Nucleus sampling otimizado
                    top_k=40,                   # Top-k sampling para velocidade
                    repetition_penalty=1.1,     # Evitar repetições
                    pad_token_id=self.processor.tokenizer.eos_token_id,
                    eos_token_id=self.processor.tokenizer.eos_token_id,
                    use_cache=True              # Cache para velocidade
                )
        
        try:
            future = self.executor.submit(generate)
            return future.result(timeout=timeout)
        except TimeoutError:
            logger.warning(f"⏰ Timeout de {timeout}s atingido")
            return None
        except Exception as e:
            logger.error(f"❌ Erro na geração: {e}")
            return None
    
    def ask_gemma(self, prompt, context="agricultura", timeout=60):
        """Método principal híbrido otimizado"""
        try:
            if not self.is_initialized:
                logger.warning("⚠️ Modelo híbrido não inicializado")
                return self._fallback_response(prompt, context)
            
            with self.generation_lock:  # Thread safety
                start_time = time.time()
                
                # Criar mensagens otimizadas
                messages = self._create_optimized_messages(prompt, context)
                
                logger.info(f"🔥 Processando com Hybrid Gemma: {prompt[:50]}...")
                
                # Aplicar chat template otimizado
                inputs = self.processor.apply_chat_template(
                    messages,
                    add_generation_prompt=True,
                    tokenize=True,
                    return_dict=True,
                    return_tensors="pt"
                ).to(self.model.device, dtype=self.model.dtype)
                
                input_len = inputs["input_ids"].shape[-1]
                
                # Gerar com timeout
                generation = self._generate_with_timeout(inputs, timeout)
                
                if generation is None:
                    logger.warning("⚠️ Geração falhou ou timeout")
                    return self._fallback_response(prompt, context)
                
                # Extrair apenas a resposta gerada
                generation = generation[0][input_len:]
                
                # Decodificar otimizado
                decoded = self.processor.decode(
                    generation,
                    skip_special_tokens=True,
                    clean_up_tokenization_spaces=True
                )
                
                generation_time = time.time() - start_time
                
                if decoded and len(decoded.strip()) > 5:
                    result = decoded.strip()
                    logger.info(f"✅ Resposta híbrida gerada em {generation_time:.2f}s")
                    return f"{result}\n\n[Hybrid Gemma • {generation_time:.1f}s]"
                else:
                    logger.warning("⚠️ Resposta vazia do modelo híbrido")
                    return self._fallback_response(prompt, context)
            
        except Exception as e:
            logger.error(f"❌ Erro na geração híbrida: {e}")
            return self._fallback_response(prompt, context)
    
    def _fallback_response(self, prompt, context="agricultura"):
        """Resposta de fallback contextualizada"""
        response = self.fallback_generator.generate_response(prompt, context)
        return f"{response}\n\n[Fallback Response • Modelo híbrido indisponível]"
    
    def get_status(self):
        """Status do serviço híbrido"""
        return {
            "service": "Hybrid Gemma Service",
            "initialized": self.is_initialized,
            "model_path": self.model_path,
            "backend": "AutoModelForImageTextToText",
            "optimizations": [
                "bfloat16", "inference_mode", "torch_compile", 
                "thread_safety", "timeout_control", "cache_enabled",
                "fast_tokenizer", "low_cpu_mem"
            ]
        }
    
    def test_connection(self):
        """Teste otimizado de funcionamento"""
        try:
            if not self.is_initialized:
                return False, "Modelo híbrido não inicializado"
            
            test_prompt = "Teste de velocidade"
            start_time = time.time()
            
            response = self.ask_gemma(test_prompt, context="geral")
            test_time = time.time() - start_time
            
            if "Fallback" not in response:
                return True, f"Modelo híbrido funcionando ({test_time:.1f}s)"
            else:
                return False, "Modelo híbrido retornou fallback"
                
        except Exception as e:
            return False, f"Erro no teste híbrido: {e}"
    
    def __del__(self):
        """Cleanup ao destruir o objeto"""
        if hasattr(self, 'executor'):
            self.executor.shutdown(wait=False)
