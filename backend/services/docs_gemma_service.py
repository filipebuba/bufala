"""
Serviço Gemma 3n Docs - Baseado na Documentação Oficial
Implementação simplificada que funciona, inspirada na documentação oficial
"""

import os
import logging
import torch
import time
from transformers import AutoTokenizer, AutoModelForCausalLM  # CORRIGIDO: igual ao notebook
from config.settings import BackendConfig
from utils.fallback_responses import FallbackResponseGenerator

logger = logging.getLogger(__name__)

class DocsGemmaService:
    """Serviço Gemma 3n baseado na documentação oficial"""
    
    def __init__(self):
        self.tokenizer = None  # CORRIGIDO: usar tokenizer como no notebook
        self.model = None
        self.is_initialized = False
        self.fallback_generator = FallbackResponseGenerator()
        self.initialize()
    
    def initialize(self):
        """Inicializar modelo com melhorias da documentação oficial"""
        try:
            logger.info("📋 Inicializando Docs Gemma Service...")
            
            if not os.path.exists(BackendConfig.MODEL_PATH):
                logger.error(f"❌ Modelo não encontrado: {BackendConfig.MODEL_PATH}")
                return False
            
            start_time = time.time()
            
            # Tokenizer otimizado (igual ao notebook)
            logger.info("📦 Carregando AutoTokenizer...")
            self.tokenizer = AutoTokenizer.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True
            )
            
            # Modelo correto (igual ao notebook)
            logger.info("🧠 Carregando AutoModelForCausalLM...")
            self.model = AutoModelForCausalLM.from_pretrained(
                BackendConfig.MODEL_PATH,
                torch_dtype=torch.float32,  # Igual ao notebook
                device_map=None,            
                local_files_only=True,
                trust_remote_code=True
            )
            
            # Mover para CPU conforme funcionou antes
            self.model = self.model.to("cpu")
            
            load_time = time.time() - start_time
            self.is_initialized = True
            
            logger.info(f"✅ Docs Gemma carregado em {load_time:.2f}s!")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização docs: {e}")
            return False
    
    def _create_structured_prompt(self, prompt, context="agricultura"):
        """Criar prompt simples baseado no notebook (sem templates complexos)"""
        
        # Prompts simples como no notebook
        context_prefixes = {
            "agricultura": "Como especialista em agricultura: ",
            "medico": "Como especialista médico: ",
            "educacao": "Como educador: ",
            "geral": ""
        }
        
        prefix = context_prefixes.get(context, "")
        return f"{prefix}{prompt}"
    
    def ask_gemma(self, prompt, context="agricultura", timeout=90):
        """Método principal baseado no notebook"""
        try:
            if not self.is_initialized:
                logger.warning("⚠️ Modelo não inicializado")
                return self._fallback_response(prompt, context)
            
            start_time = time.time()
            
            # Criar prompt simples (como no notebook)
            simple_prompt = self._create_structured_prompt(prompt, context)
            
            logger.info(f"🤖 Processando com Gemma: {prompt[:50]}...")
            
            # Tokenizar (igual ao notebook)
            if self.tokenizer is None:
                logger.error("❌ Tokenizer não inicializado corretamente")
                return self._fallback_response(prompt, context)
            if self.model is None:
                logger.error("❌ Modelo não inicializado corretamente")
                return self._fallback_response(prompt, context)
            inputs = self.tokenizer.encode(simple_prompt, return_tensors="pt")
            
            # Gerar resposta (igual ao notebook)
            with torch.no_grad():  # CORRIGIDO: usar no_grad como no notebook
                pad_token_id = getattr(self.tokenizer, "pad_token_id", None)
                eos_token_id = getattr(self.tokenizer, "eos_token_id", None)
                outputs = self.model.generate(
                    inputs,
                    max_new_tokens=150,         # CORRIGIDO: usar 150 como no notebook
                    do_sample=True,             
                    temperature=0.7,            # CORRIGIDO: usar 0.7 como no notebook
                    top_p=0.9,                  
                    top_k=50,                   
                    repetition_penalty=1.1,     
                    pad_token_id=pad_token_id,  # Safe access to tokenizer attribute
                    eos_token_id=eos_token_id,  # Safe access to tokenizer attribute
                )
            
            # Decodificar (igual ao notebook)
            if self.tokenizer is None:
                logger.error("❌ Tokenizer não inicializado corretamente")
                return self._fallback_response(prompt, context)
            response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            
            generation_time = time.time() - start_time
            
            # Limpar o prompt da resposta (igual ao notebook)
            if simple_prompt in response:
                response = response.replace(simple_prompt, "").strip()
            
            if response and len(response) > 10:
                logger.info(f"✅ Resposta gerada em {generation_time:.2f}s")
                return f"{response}\n\n[Docs Gemma • {generation_time:.1f}s]"
            else:
                logger.warning("⚠️ Resposta vazia ou muito curta")
                return self._fallback_response(prompt, context)
            
        except Exception as e:
            logger.error(f"❌ Erro na geração: {e}")
            return self._fallback_response(prompt, context)
    
    def _fallback_response(self, prompt, context="agricultura"):
        """Resposta de fallback contextualizada"""
        response = self.fallback_generator.generate_response(prompt, context)
        return f"{response}\n\n[Fallback Response • Docs Gemma indisponível]"
    
    def get_status(self):
        """Status do serviço baseado no notebook"""
        return {
            "service": "Docs Gemma Service",
            "initialized": self.is_initialized,
            "model_path": BackendConfig.MODEL_PATH,
            "backend": "AutoModelForCausalLM",  # CORRIGIDO
            "optimizations": [
                "simple_prompts", "torch_no_grad", "float32_stable",
                "cpu_processing", "nucleus_sampling", "max_tokens_150"
            ]
        }
    
    def test_connection(self):
        """Teste de funcionamento"""
        try:
            if not self.is_initialized:
                return False, "Docs Gemma não inicializado"
            
            test_prompt = "Como plantar alface?"
            start_time = time.time()
            
            response = self.ask_gemma(test_prompt, context="agricultura")
            test_time = time.time() - start_time
            
            if "Fallback" not in response:
                return True, f"Docs Gemma funcionando ({test_time:.1f}s)"
            else:
                return False, "Docs Gemma retornou fallback"
                
        except Exception as e:
            return False, f"Erro no teste docs: {e}"
    
    def generate_response(self, prompt, language="pt-BR", context="agricultura"):
        """Método de compatibilidade com as rotas existentes"""
        try:
            logger.info(f"🔄 Redirecionando para ask_gemma: {prompt[:50]}...")
            
            # Mapear contextos para o formato esperado
            context_mapping = {
                'medical': 'medico',
                'agriculture': 'agricultura',
                'education': 'educacao',
                'agricultura': 'agricultura', 
                'medico': 'medico',
                'educacao': 'educacao'
            }
            
            mapped_context = context_mapping.get(context, context)
            
            # Chamar o método principal
            response = self.ask_gemma(prompt, mapped_context)
            
            logger.info(f"✅ Resposta redirecionada com sucesso")
            return response
            
        except Exception as e:
            logger.error(f"❌ Erro no redirecionamento: {e}")
            return self._fallback_response(prompt, context)
    
    def transcribe_and_translate(self, text, target_language="pt-BR"):
        """Transcrição e tradução para acessibilidade"""
        try:
            logger.info(f"🎯 Transcrevendo e traduzindo para {target_language}")
            
            # Prompt para tradução usando Gemma-3n
            translation_prompt = f"Traduza o seguinte texto para {target_language}: {text}"
            
            response = self.ask_gemma(translation_prompt, context="traducao")
            
            return {
                "original_text": text,
                "translated_text": response,
                "target_language": target_language,
                "success": True
            }
            
        except Exception as e:
            logger.error(f"❌ Erro na tradução: {e}")
            return {
                "original_text": text,
                "translated_text": text,  # Fallback para texto original
                "target_language": target_language,
                "success": False,
                "error": str(e)
            }
    
    def describe_environment(self, description_prompt):
        """Descrição de ambiente para deficientes visuais"""
        try:
            logger.info("👁️ Gerando descrição de ambiente")
            
            accessibility_prompt = f"Descreva de forma clara e detalhada para uma pessoa com deficiência visual: {description_prompt}"
            
            response = self.ask_gemma(accessibility_prompt, context="acessibilidade")
            
            return {
                "description": response,
                "audio_guidance": True,
                "success": True
            }
            
        except Exception as e:
            logger.error(f"❌ Erro na descrição: {e}")
            return {
                "description": "Ambiente não identificado no momento.",
                "audio_guidance": False,
                "success": False,
                "error": str(e)
            }
    
    def navigation_assistance(self, current_location, destination):
        """Assistência de navegação para mobilidade reduzida"""
        try:
            logger.info(f"🧭 Gerando orientação de navegação")
            
            navigation_prompt = f"Como ir de {current_location} para {destination} considerando acessibilidade para pessoas com mobilidade reduzida?"
            
            response = self.ask_gemma(navigation_prompt, context="navegacao")
            
            return {
                "instructions": response,
                "accessible_route": True,
                "voice_guidance": True,
                "success": True
            }
            
        except Exception as e:
            logger.error(f"❌ Erro na navegação: {e}")
            return {
                "instructions": "Rota não disponível no momento.",
                "accessible_route": False,
                "voice_guidance": False,
                "success": False,
                "error": str(e)
            }
