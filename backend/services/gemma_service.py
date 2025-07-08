"""
Serviço principal do modelo Gemma-3n
Implementa os métodos da documentação oficial
"""

import os
import logging
import time
import traceback
import torch
from datetime import datetime
from transformers import (
    AutoTokenizer, 
    AutoModelForCausalLM, 
    AutoProcessor,
    AutoModelForImageTextToText,
    pipeline
)

from config.settings import BackendConfig, SystemPrompts
from utils.fallback_responses import FallbackResponseGenerator
from utils.response_cache import get_cache
from utils.performance_metrics import get_metrics

logger = logging.getLogger(__name__)

class GemmaService:
    """Serviço principal para gerenciar o modelo Gemma-3n com suporte multimodal"""
    
    def __init__(self):
        self.model = None
        self.tokenizer = None
        self.pipeline = None
        self.processor = None
        self.chat_model = None
        self.is_initialized = False
        self.loading_method = None
        self.generation_config = BackendConfig.get_generation_config()
        self.fallback_generator = FallbackResponseGenerator()
        self.cache = get_cache()  # Sistema de cache
        self.metrics = get_metrics()  # Sistema de métricas
        
        # Inicializar modelo
        self.initialize()
    
    def initialize(self):
        """Inicializar modelo com métodos da documentação oficial"""
        try:
            logger.info("🚀 Inicializando Gemma-3n com melhorias da documentação oficial...")
            
            # Verificar se modelo existe
            if not os.path.exists(BackendConfig.MODEL_PATH):
                logger.error(f"❌ Modelo não encontrado em: {BackendConfig.MODEL_PATH}")
                self.is_initialized = False
                return False
            
            # MÉTODO 1: Pipeline API (recomendado oficialmente)
            if self._load_with_pipeline_api():
                logger.info("✅ Pipeline API carregado - usando método oficial")
                self.loading_method = "pipeline"
                
            # MÉTODO 2: Chat Templates com AutoProcessor
            elif self._load_with_chat_template():
                logger.info("✅ Chat Template carregado - usando método oficial")
                self.loading_method = "chat_template"
                
            # MÉTODO 3: Método tradicional otimizado
            elif self._load_traditional_optimized():
                logger.info("✅ Método tradicional otimizado carregado")
                self.loading_method = "traditional"
            
            else:
                logger.error("❌ Falha em todos os métodos de carregamento")
                self.is_initialized = False
                return False
            
            # Aplicar otimizações de produção
            self._optimize_for_production()
            
            self.is_initialized = True
            logger.info(f"🎯 Gemma-3n inicializado com método: {self.loading_method}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização: {e}")
            logger.error(f"❌ Traceback: {traceback.format_exc()}")
            self.is_initialized = False
            return False
    
    def _load_with_pipeline_api(self):
        """Carregar usando Pipeline API oficial - conforme documentação Gemma 3n"""
        try:
            logger.info("🔧 Carregando com Pipeline API oficial...")
            
            device = BackendConfig.get_device()
            torch_dtype = BackendConfig.get_torch_dtype()
            
            # Para multimodal, usar image-text-to-text conforme documentação
            try:
                self.pipeline = pipeline(
                    "image-text-to-text",
                    model=BackendConfig.MODEL_PATH,
                    device_map="auto" if device == "cuda" else None,
                    torch_dtype=torch_dtype,
                    trust_remote_code=True,
                    local_files_only=True
                )
                logger.info("✅ Pipeline multimodal (image-text-to-text) carregado")
            except Exception as e:
                logger.warning(f"⚠️ Pipeline multimodal falhou: {e}")
                # Fallback para text-generation
                self.pipeline = pipeline(
                    "text-generation",
                    model=BackendConfig.MODEL_PATH,
                    device=device,
                    torch_dtype=torch_dtype,
                    trust_remote_code=True,
                    local_files_only=True
                )
                logger.info("✅ Pipeline text-generation carregado como fallback")
            
            # Teste rápido
            test_response = self.pipeline(
                "Olá",
                max_new_tokens=5,
                do_sample=False
            )
            
            logger.info(f"✅ Pipeline testado: {test_response[0]['generated_text'][:30]}...")
            return True
            
        except Exception as e:
            logger.warning(f"⚠️ Pipeline API falhou: {e}")
            return False
    
    def _load_with_chat_template(self):
        """Carregar usando Chat Templates e AutoProcessor"""
        try:
            logger.info("💬 Carregando com Chat Templates...")
            
            # Carregar processor
            self.processor = AutoProcessor.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True
            )
            
            # Carregar modelo específico para multimodal
            device = BackendConfig.get_device()
            self.chat_model = AutoModelForImageTextToText.from_pretrained(
                BackendConfig.MODEL_PATH,
                device_map="auto" if device == "cuda" else None,
                torch_dtype=BackendConfig.get_torch_dtype(),
                local_files_only=True,
                trust_remote_code=True
            ).eval()
            
            # Teste com chat template
            messages = [
                {
                    "role": "system",
                    "content": [{"type": "text", "text": "Você é um assistente útil."}]
                },
                {
                    "role": "user",
                    "content": [{"type": "text", "text": "Olá"}]
                }
            ]
            
            inputs = self.processor.apply_chat_template(
                messages,
                add_generation_prompt=True,
                tokenize=True,
                return_dict=True,
                return_tensors="pt"
            ).to(self.chat_model.device, dtype=BackendConfig.get_torch_dtype())
            
            with torch.inference_mode():
                generation = self.chat_model.generate(**inputs, max_new_tokens=5)
                
            test_response = self.processor.decode(generation[0], skip_special_tokens=True)
            logger.info(f"✅ Chat Template testado: {test_response[:30]}...")
            return True
            
        except Exception as e:
            logger.warning(f"⚠️ Chat Template falhou: {e}")
            return False
    
    def _load_traditional_optimized(self):
        """Carregar usando método tradicional com otimizações"""
        try:
            logger.info("🔄 Carregando com método tradicional otimizado...")
            
            device = BackendConfig.get_device()
            torch_dtype = BackendConfig.get_torch_dtype()
            
            # Configurar otimizações CUDA
            if device == "cuda":
                torch.backends.cudnn.benchmark = True
                torch.backends.cuda.matmul.allow_tf32 = True
            
            # Carregar tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True,
                padding_side='left'
            )
            
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            # Carregar modelo
            self.model = AutoModelForCausalLM.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True,
                torch_dtype=torch_dtype,
                device_map="auto" if device == "cuda" else None,
                low_cpu_mem_usage=True,
                attn_implementation="flash_attention_2" if device == "cuda" else "eager"
            )
            
            if device == "cpu":
                self.model = self.model.to(device)
            
            self.model.eval()
            
            # Atualizar configurações de geração
            self.generation_config.update({
                'pad_token_id': self.tokenizer.pad_token_id,
                'eos_token_id': self.tokenizer.eos_token_id
            })
            
            # Teste rápido
            test_inputs = self.tokenizer("Olá", return_tensors="pt")
            if device == "cuda":
                test_inputs = {k: v.to(device) for k, v in test_inputs.items()}
            
            with torch.no_grad():
                test_outputs = self.model.generate(
                    **test_inputs,
                    max_new_tokens=5,
                    do_sample=False
                )
            
            test_response = self.tokenizer.decode(test_outputs[0], skip_special_tokens=True)
            logger.info(f"✅ Método tradicional testado: {test_response[:30]}...")
            return True
            
        except Exception as e:
            logger.warning(f"⚠️ Método tradicional falhou: {e}")
            return False
    
    def _optimize_for_production(self):
        """Aplicar otimizações de produção"""
        if not BackendConfig.ENABLE_OPTIMIZATIONS:
            return
            
        try:
            logger.info("⚡ Aplicando otimizações de produção...")
            
            # torch.compile
            if hasattr(torch, 'compile') and hasattr(self, 'model') and self.model:
                try:
                    self.model = torch.compile(self.model, mode="reduce-overhead")
                    logger.info("✅ torch.compile aplicado")
                except Exception as e:
                    logger.warning(f"⚠️ torch.compile falhou: {e}")
            
            # Flash Attention
            if torch.cuda.is_available():
                try:
                    torch.backends.cuda.enable_flash_sdp(True)
                    logger.info("⚡ Flash Attention habilitado")
                except Exception as e:
                    logger.warning(f"⚠️ Flash Attention falhou: {e}")
            
        except Exception as e:
            logger.warning(f"⚠️ Erro nas otimizações: {e}")
    
    def _validate_context_length(self, text):
        """Validar e truncar contexto se necessário"""
        if not hasattr(self, 'tokenizer') or not self.tokenizer:
            return text, 0, False
            
        try:
            tokens = self.tokenizer.encode(text)
            token_count = len(tokens)
            
            if token_count > BackendConfig.MAX_CONTEXT_TOKENS:
                logger.warning(f"✂️ Truncando contexto: {token_count} -> {BackendConfig.MAX_CONTEXT_TOKENS} tokens")
                truncated_tokens = tokens[-BackendConfig.MAX_CONTEXT_TOKENS:]
                truncated_text = self.tokenizer.decode(truncated_tokens, skip_special_tokens=True)
                return truncated_text, token_count, True
            
            return text, token_count, False
            
        except Exception as e:
            logger.warning(f"⚠️ Erro na validação de contexto: {e}")
            return text, 0, False
    
    def generate_response(self, prompt, language='pt-BR', subject='general'):
        """Gerar resposta usando métodos hierárquicos com cache"""
        try:
            if not prompt or not prompt.strip():
                return self.fallback_generator.generate_response(prompt, language, subject)
            
            # Verificar cache primeiro
            cached_response = self.cache.get(prompt, language, subject)
            if cached_response:
                logger.debug(f"🎯 Resposta obtida do cache para: {prompt[:30]}...")
                self.metrics.record_generation(0, 0, "cache", from_cache=True)
                return cached_response
            
            # Validar contexto
            validated_prompt, token_count, was_truncated = self._validate_context_length(prompt)
            if was_truncated:
                logger.info(f"✂️ Contexto truncado de {token_count} tokens")
            
            generated_response = None
            
            # MÉTODO 1: Pipeline API
            if self.loading_method == "pipeline" and self.pipeline:
                generated_response = self._generate_with_pipeline(validated_prompt, language, subject)
                if generated_response:
                    self.cache.set(prompt, generated_response, language, subject)
                    return generated_response
            
            # MÉTODO 2: Chat Template
            if self.loading_method == "chat_template" and self.chat_model and self.processor:
                generated_response = self._generate_with_chat_template(validated_prompt, language, subject)
                if generated_response:
                    self.cache.set(prompt, generated_response, language, subject)
                    return generated_response
            
            # MÉTODO 3: Tradicional
            if self.loading_method == "traditional" and self.model and self.tokenizer:
                generated_response = self._generate_with_traditional(validated_prompt, language, subject)
                if generated_response:
                    self.cache.set(prompt, generated_response, language, subject)
                    return generated_response
            
            # Fallback
            logger.warning("⚠️ Todos os métodos falharam, usando fallback")
            self.metrics.record_fallback()
            fallback_response = self.fallback_generator.generate_response(validated_prompt, language, subject)
            # Não cachear respostas de fallback para permitir retry
            return fallback_response
            
        except Exception as e:
            logger.error(f"❌ Erro na geração: {e}")
            return self.fallback_generator.generate_response(prompt, language, subject)
    
    def _generate_with_pipeline(self, prompt, language, subject):
        """Gerar resposta usando Pipeline API"""
        start_time = time.time()
        try:
            formatted_prompt = self._format_prompt(prompt, language, subject)
            logger.info(f"🔧 Gerando resposta com Pipeline para: {prompt[:50]}...")
            
            # Configuração otimizada para respostas mais completas
            generation_config = self.generation_config.copy()
            generation_config.update({
                'max_new_tokens': min(512, generation_config.get('max_new_tokens', 512)),
                'pad_token_id': getattr(self.pipeline.tokenizer, 'pad_token_id', None),
                'eos_token_id': getattr(self.pipeline.tokenizer, 'eos_token_id', None)
            })
            
            response = self.pipeline(
                formatted_prompt,
                **generation_config
            )
            
            generated_text = response[0]['generated_text']
            cleaned_response = generated_text.replace(formatted_prompt, "").strip()
            
            logger.info(f"📝 Resposta gerada ({len(cleaned_response)} chars): {cleaned_response[:100]}...")
            
            if cleaned_response and len(cleaned_response.strip()) >= 20:  # Aumentado de 10 para 20
                # Registrar métricas
                generation_time = time.time() - start_time
                token_count = len(cleaned_response.split())
                self.metrics.record_generation(generation_time, token_count, "pipeline")
                
                timestamp = datetime.now().strftime("%H:%M:%S")
                return f"{cleaned_response}\n\n[Gerado por Gemma-3n Pipeline às {timestamp}]"
            else:
                logger.warning(f"⚠️ Resposta muito curta ou vazia: '{cleaned_response}'")
                
        except Exception as e:
            logger.warning(f"⚠️ Pipeline falhou: {e}")
            logger.warning(f"⚠️ Traceback: {traceback.format_exc()}")
        return None
    
    def _generate_with_chat_template(self, prompt, language, subject):
        """Gerar resposta usando Chat Template"""
        start_time = time.time()
        try:
            logger.info(f"💬 Gerando resposta com Chat Template para: {prompt[:50]}...")
            
            system_prompt = SystemPrompts.get_prompt(subject)
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
            
            inputs = self.processor.apply_chat_template(
                messages,
                add_generation_prompt=True,
                tokenize=True,
                return_dict=True,
                return_tensors="pt"
            ).to(self.chat_model.device, dtype=BackendConfig.get_torch_dtype())
            
            input_len = inputs["input_ids"].shape[-1]
            
            # Configuração melhorada para geração
            generation_config = self.generation_config.copy()
            generation_config.update({
                'max_new_tokens': min(512, generation_config.get('max_new_tokens', 512)),
                'pad_token_id': self.processor.tokenizer.pad_token_id,
                'eos_token_id': self.processor.tokenizer.eos_token_id
            })
            
            with torch.inference_mode():
                generation = self.chat_model.generate(
                    **inputs,
                    **generation_config
                )
                generation = generation[0][input_len:]
            
            decoded_response = self.processor.decode(generation, skip_special_tokens=True)
            
            logger.info(f"📝 Resposta Chat Template ({len(decoded_response)} chars): {decoded_response[:100]}...")
            
            if decoded_response and len(decoded_response.strip()) >= 20:  # Aumentado de 10 para 20
                # Registrar métricas
                generation_time = time.time() - start_time
                token_count = len(decoded_response.split())
                self.metrics.record_generation(generation_time, token_count, "chat_template")
                
                timestamp = datetime.now().strftime("%H:%M:%S")
                return f"{decoded_response}\n\n[Gerado por Gemma-3n Chat Template às {timestamp}]"
            else:
                logger.warning(f"⚠️ Resposta Chat Template muito curta: '{decoded_response}'")
                
        except Exception as e:
            logger.warning(f"⚠️ Chat Template falhou: {e}")
            logger.warning(f"⚠️ Traceback: {traceback.format_exc()}")
        return None
    
    def _generate_with_traditional(self, prompt, language, subject):
        """Gerar resposta usando método tradicional"""
        start_time = time.time()
        try:
            logger.info(f"🔄 Gerando resposta com método tradicional para: {prompt[:50]}...")
            
            formatted_prompt = self._format_prompt(prompt, language, subject)
            
            inputs = self.tokenizer(
                formatted_prompt,
                return_tensors="pt",
                padding=True,
                truncation=True,
                max_length=BackendConfig.MAX_INPUT_LENGTH
            )
            
            device = next(self.model.parameters()).device
            inputs = {k: v.to(device) for k, v in inputs.items()}
            
            # Configuração melhorada para geração
            generation_config = self.generation_config.copy()
            generation_config.update({
                'max_new_tokens': min(512, generation_config.get('max_new_tokens', 512)),
                'pad_token_id': self.tokenizer.pad_token_id,
                'eos_token_id': self.tokenizer.eos_token_id
            })
            
            with torch.no_grad():
                if device.type == "cuda":
                    with torch.cuda.amp.autocast():
                        outputs = self.model.generate(**inputs, **generation_config)
                else:
                    outputs = self.model.generate(**inputs, **generation_config)
            
            generated_tokens = outputs[0][inputs['input_ids'].shape[1]:]
            generated_text = self.tokenizer.decode(generated_tokens, skip_special_tokens=True).strip()
            
            logger.info(f"📝 Resposta Tradicional ({len(generated_text)} chars): {generated_text[:100]}...")
            
            if generated_text and len(generated_text.strip()) >= 20:  # Aumentado de 10 para 20
                # Registrar métricas
                generation_time = time.time() - start_time
                token_count = len(generated_text.split())
                self.metrics.record_generation(generation_time, token_count, "traditional")
                
                timestamp = datetime.now().strftime("%H:%M:%S")
                return f"{generated_text}\n\n[Gerado por Gemma-3n Tradicional às {timestamp}]"
            else:
                logger.warning(f"⚠️ Resposta Tradicional muito curta: '{generated_text}'")
                
        except Exception as e:
            logger.warning(f"⚠️ Método tradicional falhou: {e}")
            logger.warning(f"⚠️ Traceback: {traceback.format_exc()}")
        return None
    
    def _format_prompt(self, prompt, language, subject):
        """Formatar prompt para o assunto específico com contexto melhorado"""
        prompts = {
            'medical': f"""Como assistente médico especializado, responda à seguinte pergunta de saúde:

Pergunta: {prompt}

Por favor, forneça uma resposta detalhada e útil, sempre recomendando consultar um profissional de saúde para casos específicos.

Resposta:""",
            'education': f"""Como professor educativo especializado, responda à seguinte pergunta educacional:

Pergunta: {prompt}

Por favor, explique de forma clara, didática e completa, adequada para aprendizado.

Resposta:""",
            'agriculture': f"""Como especialista em agricultura sustentável, responda à seguinte pergunta:

Pergunta: {prompt}

Por favor, forneça conselhos práticos e detalhados sobre agricultura e cultivo.

Resposta:""",
            'wellness': f"""Como coach de bem-estar e saúde mental, responda à seguinte pergunta:

Pergunta: {prompt}

Por favor, forneça orientações completas para uma vida mais saudável e equilibrada.

Resposta:""",
            'translate': f"""Como tradutor profissional especializado em português e crioulo da Guiné-Bissau, traduza o seguinte:

Texto para traduzir: {prompt}

Por favor, forneça uma tradução precisa e culturalmente apropriada.

Tradução:""",
            'environmental': f"""Como especialista em meio ambiente e sustentabilidade, responda à seguinte pergunta:

Pergunta: {prompt}

Por favor, forneça orientações ecológicas práticas e detalhadas.

Resposta:"""
        }
        return prompts.get(subject, f"""Como assistente inteligente e útil, responda à seguinte pergunta:

Pergunta: {prompt}

Por favor, forneça uma resposta completa, informativa e útil.

Resposta:""")
    
    def get_status(self):
        """Obter status do serviço com estatísticas de cache"""
        cache_stats = self.cache.get_stats() if hasattr(self, 'cache') else {}
        
        return {
            'initialized': self.is_initialized,
            'loading_method': self.loading_method,
            'device': BackendConfig.get_device(),
            'model_path': BackendConfig.MODEL_PATH,
            'optimizations_enabled': BackendConfig.ENABLE_OPTIMIZATIONS,
            'multimodal_capable': hasattr(self, 'processor') and self.processor is not None,
            'supports_image_analysis': BackendConfig.ENABLE_MULTIMODAL and self.is_initialized,
            'supports_audio_processing': BackendConfig.ENABLE_MULTIMODAL and self.is_initialized,
            'model_version': 'gemma-3n-e2b-it',
            'cache_stats': cache_stats
        }
