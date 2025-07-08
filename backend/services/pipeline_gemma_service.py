"""
Serviço Gemma 3n Pipeline - Baseado na Documentação Oficial
Implementação otimizada usando pipeline API para máxima velocidade
"""

import os
import logging
import torch
import time
from transformers import pipeline
from config.settings import BackendConfig
from utils.fallback_responses import FallbackResponseGenerator

logger = logging.getLogger(__name__)

class PipelineGemmaService:
    """Serviço Gemma 3n usando pipeline API da documentação oficial"""
    
    def __init__(self):
        self.pipe = None
        self.is_initialized = False
        self.fallback_generator = FallbackResponseGenerator()
        self.model_path = BackendConfig.MODEL_PATH
        self.initialize()
    
    def initialize(self):
        """Inicializar pipeline otimizado conforme documentação oficial"""
        try:
            logger.info("🚀 Inicializando Pipeline Gemma Service...")
            
            if not os.path.exists(self.model_path):
                logger.error(f"❌ Modelo não encontrado: {self.model_path}")
                return False
            
            start_time = time.time()
            
            # Pipeline otimizado conforme documentação oficial
            logger.info("🔥 Criando pipeline otimizado...")
            self.pipe = pipeline(
                "text-generation",     # Task correta para modelos de texto
                model=self.model_path,
                device_map=None,       # Usar None para evitar meta tensors
                torch_dtype=torch.float32,  # Usar float32 para estabilidade
                trust_remote_code=True,
                local_files_only=True
            )
            
            load_time = time.time() - start_time
            self.is_initialized = True
            
            logger.info(f"✅ Pipeline Gemma carregado em {load_time:.2f}s!")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização: {e}")
            return False
    
    def _create_chat_messages(self, prompt, context="agricultura"):
        """Criar mensagens usando chat template da documentação oficial"""
        
        # Sistema especializado por contexto
        system_prompts = {
            "agricultura": "Você é um especialista em agricultura brasileira. Responda de forma clara, prática e útil sobre cultivo, plantio, pragas, solo e técnicas agrícolas.",
            "medico": "Você é um assistente médico especializado. Forneça informações médicas precisas, mas sempre recomende consultar um profissional de saúde.",
            "educacao": "Você é um educador experiente. Explique conceitos de forma didática, clara e adequada ao nível do estudante.",
            "geral": "Você é um assistente útil e conhecedor. Responda de forma clara, precisa e informativa."
        }
        
        system_content = system_prompts.get(context, system_prompts["geral"])
        
        # Formato de mensagens conforme documentação oficial
        messages = [
            {
                "role": "system",
                "content": [{"type": "text", "text": system_content}]
            },
            {
                "role": "user", 
                "content": [{"type": "text", "text": prompt}]
            }
        ]
        
        return messages
    
    def ask_gemma(self, prompt, context="agricultura", timeout=60):
        """Método principal usando pipeline API otimizada"""
        try:
            if not self.is_initialized:
                logger.warning("⚠️ Pipeline não inicializado, usando fallback")
                return self._fallback_response(prompt, context)
            
            start_time = time.time()
            
            # Criar prompt simples
            system_prompts = {
                "agricultura": "Você é um especialista em agricultura brasileira. Responda de forma clara, prática e útil sobre cultivo, plantio, pragas, solo e técnicas agrícolas.",
                "medico": "Você é um assistente médico especializado. Forneça informações médicas precisas, mas sempre recomende consultar um profissional de saúde.",
                "educacao": "Você é um educador experiente. Explique conceitos de forma didática, clara e adequada ao nível do estudante.",
                "geral": "Você é um assistente útil e conhecedor. Responda de forma clara, precisa e informativa."
            }
            
            system_content = system_prompts.get(context, system_prompts["geral"])
            full_prompt = f"{system_content}\n\nUsuário: {prompt}\nAssistente:"
            
            logger.info(f"🤖 Gerando resposta com pipeline para: {prompt[:50]}...")
            
            # Gerar usando pipeline
            output = self.pipe(
                full_prompt,
                max_new_tokens=512,
                temperature=0.8,
                top_p=0.9,
                do_sample=True,
                return_full_text=False
            )
            
            generation_time = time.time() - start_time
            
            # Extrair resposta gerada
            if output and len(output) > 0:
                if isinstance(output, list):
                    generated_text = output[0].get("generated_text", "")
                else:
                    generated_text = str(output)
                
                result = generated_text.strip()
                
                if result and len(result) > 10:
                    logger.info(f"✅ Resposta pipeline gerada em {generation_time:.2f}s")
                    return f"{result}\n\n[Pipeline Gemma • {generation_time:.1f}s]"
            
            logger.warning("⚠️ Resposta vazia do pipeline")
            return self._fallback_response(prompt, context)
            
        except Exception as e:
            logger.error(f"❌ Erro na geração pipeline: {e}")
            return self._fallback_response(prompt, context)
    
    def _fallback_response(self, prompt, context="agricultura"):
        """Resposta de fallback contextualizada"""
        response = self.fallback_generator.generate_response(prompt, context)
        return f"{response}\n\n[Fallback Response • Pipeline não disponível]"
    
    def get_status(self):
        """Status do serviço"""
        return {
            "service": "Pipeline Gemma Service",
            "initialized": self.is_initialized,
            "model_path": self.model_path,
            "backend": "transformers.pipeline",
            "optimizations": ["auto_device_map", "auto_dtype", "chat_templates"]
        }
    
    def test_connection(self):
        """Teste rápido de conexão"""
        try:
            if not self.is_initialized:
                return False, "Pipeline não inicializado"
            
            test_prompt = "Olá, como você está?"
            start_time = time.time()
            
            response = self.ask_gemma(test_prompt, context="geral")
            test_time = time.time() - start_time
            
            if "Fallback" not in response:
                return True, f"Pipeline funcionando ({test_time:.1f}s)"
            else:
                return False, "Pipeline retornou fallback"
                
        except Exception as e:
            return False, f"Erro no teste: {e}"
