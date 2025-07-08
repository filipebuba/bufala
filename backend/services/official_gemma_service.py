"""
Serviço Gemma 3n Oficial - Implementação Direta
Baseado na documentação oficial usando Gemma3nForConditionalGeneration
"""

import os
import logging
import torch
import time
from transformers import AutoProcessor, AutoModelForImageTextToText
from config.settings import BackendConfig
from utils.fallback_responses import FallbackResponseGenerator

logger = logging.getLogger(__name__)

class OfficialGemmaService:
    """Serviço Gemma 3n usando implementação oficial direta"""
    
    def __init__(self):
        self.processor = None
        self.model = None
        self.is_initialized = False
        self.fallback_generator = FallbackResponseGenerator()
        self.model_path = BackendConfig.MODEL_PATH
        self.initialize()
    
    def initialize(self):
        """Inicializar modelo conforme documentação oficial"""
        try:
            logger.info("📋 Inicializando Official Gemma Service...")
            
            if not os.path.exists(self.model_path):
                logger.error(f"❌ Modelo não encontrado: {self.model_path}")
                return False
            
            start_time = time.time()
            
            # Processor oficial
            logger.info("📦 Carregando AutoProcessor...")
            self.processor = AutoProcessor.from_pretrained(
                self.model_path,
                local_files_only=True,
                trust_remote_code=True
            )
            
            # Modelo oficial com configurações da documentação
            logger.info("🧠 Carregando AutoModelForImageTextToText...")
            self.model = AutoModelForImageTextToText.from_pretrained(
                self.model_path,
                device_map=None,        # Evitar meta tensors
                torch_dtype=torch.float32,  # Usar float32 para estabilidade
                local_files_only=True,
                trust_remote_code=True
            ).eval()  # Modo de avaliação para inferência
            
            load_time = time.time() - start_time
            self.is_initialized = True
            
            logger.info(f"✅ Official Gemma carregado em {load_time:.2f}s!")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização oficial: {e}")
            return False
    
    def _create_chat_messages(self, prompt, context="agricultura"):
        """Criar mensagens usando formato oficial da documentação"""
        
        # Sistemas especializados
        systems = {
            "agricultura": "Você é um agrônomo especialista em agricultura brasileira. Forneça conselhos práticos sobre cultivo, manejo de solo, controle de pragas e técnicas agrícolas sustentáveis.",
            "medico": "Você é um assistente médico qualificado. Forneça informações médicas precisas e atualizadas, sempre enfatizando a importância de consultar profissionais de saúde.",
            "educacao": "Você é um professor experiente e didático. Explique conceitos de forma clara, estruturada e adaptada ao nível de compreensão do estudante.",
            "geral": "Você é um assistente inteligente e útil. Responda de forma clara, precisa e informativa sobre qualquer tópico."
        }
        
        system_prompt = systems.get(context, systems["geral"])
        
        # Formato oficial da documentação
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
    
    def ask_gemma(self, prompt, context="agricultura", timeout=90):
        """Método principal usando implementação oficial"""
        try:
            if not self.is_initialized:
                logger.warning("⚠️ Modelo não inicializado, usando fallback")
                return self._fallback_response(prompt, context)
            
            start_time = time.time()
            
            # Criar mensagens com chat template
            messages = self._create_chat_messages(prompt, context)
            
            logger.info(f"🤖 Processando com Official Gemma: {prompt[:50]}...")
            
            # Aplicar chat template conforme documentação oficial
            inputs = self.processor.apply_chat_template(
                messages,
                add_generation_prompt=True,
                tokenize=True,
                return_dict=True,
                return_tensors="pt"
            ).to(self.model.device, dtype=torch.bfloat16)
            
            input_len = inputs["input_ids"].shape[-1]
            
            # Gerar com torch.inference_mode() para máxima eficiência
            with torch.inference_mode():
                generation = self.model.generate(
                    **inputs,
                    max_new_tokens=512,     # Tamanho adequado
                    do_sample=True,         # Amostragem ativa
                    temperature=0.8,        # Criatividade moderada
                    top_p=0.9,             # Nucleus sampling
                    pad_token_id=self.processor.tokenizer.eos_token_id
                )
                
                # Extrair apenas a parte gerada
                generation = generation[0][input_len:]
            
            # Decodificar conforme documentação oficial
            decoded = self.processor.decode(
                generation, 
                skip_special_tokens=True
            )
            
            generation_time = time.time() - start_time
            
            if decoded and len(decoded.strip()) > 5:
                result = decoded.strip()
                logger.info(f"✅ Resposta oficial gerada em {generation_time:.2f}s")
                return f"{result}\n\n[Official Gemma • {generation_time:.1f}s]"
            else:
                logger.warning("⚠️ Resposta vazia do modelo oficial")
                return self._fallback_response(prompt, context)
            
        except Exception as e:
            logger.error(f"❌ Erro na geração oficial: {e}")
            return self._fallback_response(prompt, context)
    
    def _fallback_response(self, prompt, context="agricultura"):
        """Resposta de fallback contextualizada"""
        response = self.fallback_generator.generate_response(prompt, context)
        return f"{response}\n\n[Fallback Response • Modelo oficial indisponível]"
    
    def get_status(self):
        """Status do serviço oficial"""
        return {
            "service": "Official Gemma Service",
            "initialized": self.is_initialized,
            "model_path": self.model_path,
            "backend": "Gemma3nForConditionalGeneration",
            "optimizations": ["inference_mode", "bfloat16", "chat_templates", "eval_mode"]
        }
    
    def test_connection(self):
        """Teste rápido de funcionamento"""
        try:
            if not self.is_initialized:
                return False, "Modelo oficial não inicializado"
            
            test_prompt = "Como cultivar tomates em casa?"
            start_time = time.time()
            
            response = self.ask_gemma(test_prompt, context="agricultura")
            test_time = time.time() - start_time
            
            if "Fallback" not in response:
                return True, f"Modelo oficial funcionando ({test_time:.1f}s)"
            else:
                return False, "Modelo oficial retornou fallback"
                
        except Exception as e:
            return False, f"Erro no teste oficial: {e}"
