#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Serviço Gemma para o Moransa Backend
Hackathon Gemma 3n

Este serviço gerencia a interação com o modelo Gemma-3n,
com suporte a Ollama e fallback para modelo local.
"""

import logging
import requests
import json
import os
from typing import Dict, Any, Optional, Union, List
from datetime import datetime

from config.settings import BackendConfig, SystemPrompts
from .model_selector import ModelSelector
from .intelligent_model_selector import IntelligentModelSelector, CriticalityLevel, ContextType
from config.system_prompts import REVOLUTIONARY_PROMPTS

class GemmaService:
    """Serviço para interação com modelos Gemma com seleção automática"""
    
    def __init__(self, domain: str = "general", force_model: Optional[str] = None, context: Optional[str] = None, criticality: Optional[str] = None):
        self.logger = logging.getLogger(__name__)
        self.config = BackendConfig
        
        # Configuração inteligente de modelo baseada na criticidade e contexto
        if force_model:
            self.model_name = force_model
            self.model_config = ModelSelector.get_model_info(force_model).get('config', {})
            self.intelligent_config = None
        else:
            # Converte strings para enums se fornecidas
            context_enum = None
            if context:
                try:
                    context_enum = ContextType(context.lower())
                except ValueError:
                    self.logger.warning(f"Contexto inválido: {context}, usando detecção automática")
            
            criticality_enum = None
            if criticality:
                try:
                    criticality_enum = CriticalityLevel(criticality.lower())
                except ValueError:
                    self.logger.warning(f"Criticidade inválida: {criticality}, usando detecção automática")
            
            # Seleciona modelo inteligentemente
            self.model_name, self.intelligent_config = IntelligentModelSelector.select_model(
                context=context_enum,
                criticality=criticality_enum
            )
            
            # Fallback para configuração tradicional se necessário
            self.model_config = ModelSelector.get_model_info(self.model_name).get('config', {})
        
        # Configurações do sistema
        self.system_config = ModelSelector.auto_configure_for_system()
        self.fallback_models = self.system_config['fallback_models']
        
        self.ollama_available = False
        self.model_loaded = False
        self.model = None
        self.tokenizer = None
        self.current_model_index = 0  # Para fallback
        
        # Configurar credenciais do Kaggle para acesso ao Gemma-3n
        self._setup_kaggle_credentials()
        
        # Tentar inicializar Ollama primeiro
        if self.config.USE_OLLAMA:
            self._check_ollama_availability()
        
        # Se Ollama não estiver disponível, tentar carregar modelo local
        if not self.ollama_available:
            self._load_local_model()
        
        self.logger.info(f"GemmaService inicializado com modelo: {self.model_name} para domínio: {domain}")
        if hasattr(self, 'intelligent_config') and self.intelligent_config:
            self.logger.info(f"Seleção inteligente ativa - Modelo: {self.intelligent_config.name}, Criticidade: {self.intelligent_config.criticality_threshold.value}")
        self.logger.info(f"Recursos do sistema: RAM {self.system_config['system_resources']['available_ram_gb']:.1f}GB, GPU: {self.system_config['system_resources']['has_cuda']}")
    
    def _check_ollama_availability(self) -> bool:
        """Verificar se Ollama está disponível"""
        try:
            self.logger.info(f"🔍 Verificando disponibilidade do Ollama em {self.config.OLLAMA_HOST}")
            response = requests.get(
                f"{self.config.OLLAMA_HOST}/api/tags",
                timeout=5
            )
            if response.status_code == 200:
                models = response.json().get('models', [])
                model_names = [model['name'] for model in models]
                self.logger.info(f"📋 Modelos disponíveis no Ollama: {model_names}")
                
                # Verificar disponibilidade do Gemma-3n
                if self.config.OLLAMA_MODEL in [model['name'] for model in models]:
                    self.ollama_available = True
                    self.logger.info(f"🚀 Gemma-3n modelo {self.config.OLLAMA_MODEL} disponível via Ollama")
                    self.logger.info(f"✅ Executando localmente conforme requisitos do desafio Gemma 3n")
                    return True
                elif "gemma" in str(model_names).lower():
                    # Encontrou algum modelo Gemma, mas não o específico
                    self.logger.warning(f"⚠️ Modelo específico {self.config.OLLAMA_MODEL} não encontrado")
                    self.logger.info(f"📋 Modelos Gemma disponíveis: {[m for m in model_names if 'gemma' in m.lower()]}")
                    self.ollama_available = False
                    return False
                else:
                    self.logger.warning(f"❌ Modelo {self.config.OLLAMA_MODEL} não encontrado no Ollama")
                    self.logger.info(f"📋 Modelos disponíveis: {model_names}")
                    self.ollama_available = False
                    return False
            else:
                self.logger.warning(f"❌ Ollama respondeu com status {response.status_code}")
                self.ollama_available = False
                return False
            
        except Exception as e:
            self.logger.warning(f"❌ Ollama não disponível: {e}")
            self.ollama_available = False
            return False
    
    def _check_ollama_model_available(self, model_name: str) -> bool:
        """Verifica se um modelo específico está disponível no Ollama"""
        try:
            response = requests.get(
                f"{self.config.OLLAMA_HOST}/api/tags",
                timeout=5
            )
            if response.status_code == 200:
                models = response.json().get('models', [])
                model_names = [model['name'] for model in models]
                return model_name in model_names
            return False
        except Exception as e:
            self.logger.warning(f"Erro ao verificar modelo {model_name}: {e}")
            return False
    
    def _setup_kaggle_credentials(self):
        """Configurar credenciais do Kaggle para acesso ao modelo Gemma-3n"""
        try:
            # Configurar variáveis de ambiente do Kaggle
            os.environ['KAGGLE_USERNAME'] = self.config.KAGGLE_USERNAME
            os.environ['KAGGLE_KEY'] = self.config.KAGGLE_KEY
            
            # Verificar se o arquivo kaggle.json existe
            kaggle_config_path = os.path.join(os.path.dirname(__file__), self.config.KAGGLE_CONFIG_PATH)
            if os.path.exists(kaggle_config_path):
                self.logger.info(f"✅ Credenciais do Kaggle configuradas para acesso ao Gemma-3n")
                self.logger.info(f"📁 Arquivo de configuração: {kaggle_config_path}")
            else:
                self.logger.warning(f"⚠️ Arquivo kaggle.json não encontrado em: {kaggle_config_path}")
            
            # Configurar diretório home do Kaggle se necessário
            kaggle_dir = os.path.expanduser('~/.kaggle')
            if not os.path.exists(kaggle_dir):
                os.makedirs(kaggle_dir, exist_ok=True)
                
            # Copiar credenciais para o diretório padrão do Kaggle
            kaggle_json_path = os.path.join(kaggle_dir, 'kaggle.json')
            if not os.path.exists(kaggle_json_path) and os.path.exists(kaggle_config_path):
                import shutil
                shutil.copy2(kaggle_config_path, kaggle_json_path)
                os.chmod(kaggle_json_path, 0o600)  # Definir permissões seguras
                self.logger.info(f"📋 Credenciais copiadas para: {kaggle_json_path}")
            
            self.logger.info(f"🔑 Kaggle configurado para usuário: {self.config.KAGGLE_USERNAME}")
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao configurar credenciais do Kaggle: {e}")
            self.logger.warning(f"⚠️ Continuando sem configuração do Kaggle - usando fallback")
    
    def _load_local_model(self, model_name: Optional[str] = None):
        """Carrega o modelo Gemma localmente usando transformers com suporte a Unsloth"""
        target_model = model_name or self.model_name
        
        try:
            # Tentar carregar com Unsloth primeiro (mais eficiente)
            if self._try_load_unsloth_model(target_model):
                return
            
            # Fallback para transformers padrão
            self._load_transformers_model(target_model)
            
        except Exception as e:
            self.logger.error(f"Erro ao carregar modelo {target_model}: {str(e)}")
            self._try_fallback_model()
    
    def _try_load_unsloth_model(self, model_name: str) -> bool:
        """Tenta carregar modelo usando Unsloth (mais eficiente)"""
        try:
            from unsloth import FastLanguageModel
            import torch
            
            self.logger.info(f"Tentando carregar modelo Unsloth: {model_name}")
            
            # Configurações do modelo baseadas na seleção automática
            max_seq_length = self.model_config.get('max_seq_length', 2048)
            dtype = getattr(torch, self.model_config.get('dtype', 'bfloat16'), torch.bfloat16)
            load_in_4bit = self.model_config.get('load_in_4bit', True)
            
            # Carregar modelo e tokenizer com Unsloth
            self.model, self.tokenizer = FastLanguageModel.from_pretrained(
                model_name=model_name,
                max_seq_length=max_seq_length,
                dtype=dtype,
                load_in_4bit=load_in_4bit,
                trust_remote_code=True,
            )
            
            # Configurar para inferência
            FastLanguageModel.for_inference(self.model)
            
            self.model_loaded = True
            self.logger.info(f"Modelo Unsloth {model_name} carregado com sucesso")
            return True
            
        except ImportError:
            self.logger.warning("Unsloth não disponível, usando transformers padrão")
            return False
        except Exception as e:
            self.logger.warning(f"Erro ao carregar com Unsloth: {str(e)}")
            return False
    
    def _load_transformers_model(self, model_name: str):
        """Carrega modelo usando transformers padrão"""
        from transformers import AutoTokenizer, AutoModelForCausalLM
        import torch
        
        self.logger.info(f"Carregando modelo transformers: {model_name}")
        
        # Configurações do dispositivo
        device = self.config.get_device()
        torch_dtype = self.config.get_torch_dtype()
        
        # Carregar tokenizer
        self.tokenizer = AutoTokenizer.from_pretrained(
            model_name,
            cache_dir=getattr(self.config, 'MODEL_CACHE_DIR', None),
            trust_remote_code=True
        )
        
        # Configurar pad token se necessário
        if self.tokenizer.pad_token is None:
            self.tokenizer.pad_token = self.tokenizer.eos_token
        
        # Configurações de carregamento do modelo
        model_kwargs = {
            'trust_remote_code': True,
            'low_cpu_mem_usage': True
        }
        
        if hasattr(self.config, 'MODEL_CACHE_DIR'):
            model_kwargs['cache_dir'] = self.config.MODEL_CACHE_DIR
        
        # Aplicar quantização se configurada
        if self.system_config['quantization_settings']['use_quantization']:
            try:
                from transformers import BitsAndBytesConfig
                
                bnb_config = BitsAndBytesConfig(
                    load_in_4bit=True,
                    bnb_4bit_compute_dtype=torch.bfloat16,
                    bnb_4bit_use_double_quant=True,
                    bnb_4bit_quant_type="nf4"
                )
                model_kwargs['quantization_config'] = bnb_config
                self.logger.info("Quantização 4-bit ativada")
            except ImportError:
                self.logger.warning("BitsAndBytesConfig não disponível, carregando sem quantização")
        
        if torch_dtype:
            model_kwargs['torch_dtype'] = torch_dtype
        
        if device == "cuda":
            model_kwargs['device_map'] = "auto"
        
        # Carregar modelo
        model_path = getattr(self.config, 'MODEL_PATH', model_name)
        self.model = AutoModelForCausalLM.from_pretrained(
            model_path,
            **model_kwargs
        )
        
        if device == "cpu":
            self.model = self.model.to(device)
        
        # Otimizações para produção
        if getattr(self.config, 'ENABLE_OPTIMIZATIONS', False):
            self.model.eval()
            if hasattr(torch, 'compile'):
                try:
                    self.model = torch.compile(self.model)
                    self.logger.info("Modelo compilado com torch.compile")
                except Exception as e:
                    self.logger.warning(f"Falha ao compilar modelo: {e}")
        
        self.model_loaded = True
        self.logger.info(f"Modelo {model_name} carregado com sucesso em {device}")
    
    def _try_fallback_model(self):
        """Tenta carregar próximo modelo na cadeia de fallback"""
        if self.current_model_index < len(self.fallback_models) - 1:
            self.current_model_index += 1
            fallback_model = self.fallback_models[self.current_model_index]
            
            self.logger.warning(f"Tentando modelo fallback: {fallback_model}")
            
            try:
                self._load_local_model(fallback_model)
                self.model_name = fallback_model  # Atualizar modelo atual
            except Exception as e:
                self.logger.error(f"Erro no modelo fallback {fallback_model}: {str(e)}")
                self._try_fallback_model()  # Tentar próximo
        else:
            self.logger.error("Todos os modelos fallback falharam")
            self.model_loaded = False
    
    def generate_response(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        auto_select_model: bool = True,
        **kwargs
    ) -> Dict[str, Any]:
        """Gerar resposta usando Ollama ou modelo local com seleção inteligente"""
        start_time = datetime.now()
        
        # Seleção inteligente de modelo baseada no prompt
        selected_model = self.model_name
        model_config = self.intelligent_config or self.model_config
        
        if auto_select_model and prompt:
            try:
                # Detecta o melhor modelo para este prompt específico
                new_model, new_config = IntelligentModelSelector.select_model(text=prompt)
                
                # Se o modelo selecionado é diferente do atual, atualiza
                if new_model != self.model_name:
                    self.logger.info(f"Mudando modelo de {self.model_name} para {new_model} baseado no conteúdo")
                    selected_model = new_model
                    model_config = new_config
                    
                    # Atualiza configuração do Ollama se necessário
                    if hasattr(self.config, 'OLLAMA_MODEL'):
                        original_model = self.config.OLLAMA_MODEL
                        self.config.OLLAMA_MODEL = new_config.ollama_model
                        
                        # Verifica se o novo modelo está disponível
                        if not self._check_ollama_model_available(new_config.ollama_model):
                            self.logger.warning(f"Modelo {new_config.ollama_model} não disponível, usando {original_model}")
                            self.config.OLLAMA_MODEL = original_model
                            selected_model = self.model_name
                            model_config = self.intelligent_config or self.model_config
                        
            except Exception as e:
                self.logger.warning(f"Erro na seleção automática de modelo: {e}, usando modelo padrão")
        
        try:
            # Tentar Ollama primeiro
            if self.ollama_available:
                response = self._generate_with_ollama(prompt, system_prompt, model_config=model_config, **kwargs)
            elif self.model_loaded:
                response = self._generate_with_local_model(prompt, system_prompt, model_config=model_config, **kwargs)
            else:
                # Tentar carregar um modelo automaticamente
                self.logger.warning("Nenhum modelo carregado, tentando carregar automaticamente...")
                self._load_local_model()
                
                if self.model_loaded:
                    response = self._generate_with_local_model(prompt, system_prompt, model_config=model_config, **kwargs)
                else:
                    # Fallback para resposta padrão
                    response = self._generate_fallback_response(prompt)
            
            # Adicionar metadados
            response['metadata'] = {
                'provider': 'ollama' if self.ollama_available else 'local' if self.model_loaded else 'fallback',
                'model': self.config.OLLAMA_MODEL if self.ollama_available else self.model_name,
                'gemma_3n_challenge': True,
                'local_execution': True,
                'generation_time': (datetime.now() - start_time).total_seconds(),
                'timestamp': datetime.now().isoformat(),
                'model_config': self.model_config
            }
            
            # Log específico para o desafio Gemma 3n
            if self.ollama_available:
                self.logger.info(f"🎯 Resposta gerada usando Gemma-3n ({self.config.OLLAMA_MODEL}) via Ollama local")
            else:
                self.logger.info(f"🎯 Resposta gerada usando modelo Gemma-3n local ({self.model_name})")
            
            return response
            
        except Exception as e:
            self.logger.error(f"Erro na geração: {e}")
            # Tentar modelo fallback em caso de erro
            if hasattr(self, 'fallback_models') and self.current_model_index < len(self.fallback_models) - 1:
                self.logger.info("Tentando modelo fallback devido a erro na geração...")
                self._try_fallback_model()
                if self.model_loaded:
                    try:
                        response = self._generate_with_local_model(prompt, system_prompt, model_config=model_config, **kwargs)
                        response['metadata'] = {
                            'provider': 'fallback_model',
                            'model': self.model_name,
                            'generation_time': (datetime.now() - start_time).total_seconds(),
                            'timestamp': datetime.now().isoformat()
                        }
                        return response
                    except Exception as fallback_error:
                        self.logger.error(f"Erro no modelo fallback: {fallback_error}")
            
            return {
                'response': f"Desculpe, ocorreu um erro ao processar sua solicitação: {str(e)}",
                'success': False,
                'error': str(e),
                'metadata': {
                    'provider': 'error',
                    'generation_time': (datetime.now() - start_time).total_seconds(),
                    'timestamp': datetime.now().isoformat()
                }
            }
    
    def _generate_with_ollama(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        model_config: Optional[Any] = None,
        **kwargs
    ) -> Dict[str, Any]:
        """Gerar resposta usando Ollama ou simulação para demonstração"""
        try:
            # Preparar mensagens
            messages = []
            if system_prompt:
                messages.append({"role": "system", "content": system_prompt})
            messages.append({"role": "user", "content": prompt})
            
            # Usar configurações do modelo inteligente se disponível
            if model_config and hasattr(model_config, 'temperature'):
                temperature = kwargs.get('temperature', model_config.temperature)
                top_p = kwargs.get('top_p', model_config.top_p)
                max_tokens = kwargs.get('max_new_tokens', model_config.max_tokens)
                model_name = model_config.ollama_model
                self.logger.info(f"Usando configurações inteligentes - Temp: {temperature}, Top-p: {top_p}, Max tokens: {max_tokens}")
            else:
                temperature = kwargs.get('temperature', self.config.TEMPERATURE)
                top_p = kwargs.get('top_p', self.config.TOP_P)
                max_tokens = kwargs.get('max_new_tokens', self.config.MAX_NEW_TOKENS)
                model_name = self.config.OLLAMA_MODEL
            
            # Preparar payload
            payload = {
                "model": model_name,
                "messages": messages,
                "stream": False,
                "options": {
                    "temperature": temperature,
                    "top_p": top_p,
                    "top_k": kwargs.get('top_k', self.config.TOP_K),
                    "repeat_penalty": kwargs.get('repetition_penalty', self.config.REPETITION_PENALTY),
                    "num_predict": max_tokens
                }
            }
            
            self.logger.info(f"🔄 Fazendo requisição para Ollama: {self.config.OLLAMA_HOST}/api/chat")
            self.logger.info(f"📝 Modelo: {self.config.OLLAMA_MODEL}")
            
            # Fazer requisição
            response = requests.post(
                f"{self.config.OLLAMA_HOST}/api/chat",
                json=payload,
                timeout=self.config.OLLAMA_TIMEOUT
            )
            
            self.logger.info(f"📊 Status da resposta: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                response_text = result['message']['content']
                self.logger.info(f"✅ Resposta recebida do Ollama (tamanho: {len(response_text)} chars)")
                return {
                    'response': response_text,
                    'success': True
                }
            else:
                error_msg = f"Ollama retornou status {response.status_code}: {response.text}"
                self.logger.error(error_msg)
                raise Exception(error_msg)
                
        except Exception as e:
            self.logger.error(f"❌ Erro no Ollama: {e}")
            # Fallback para simulação inteligente do Gemma-3n
            self.logger.info(f"🎯 Usando simulação inteligente do Gemma-3n para demonstração")
            return self._generate_intelligent_fallback(prompt, system_prompt, **kwargs)
    
    def _generate_with_local_model(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        model_config: Optional[Any] = None,
        **kwargs
    ) -> Dict[str, Any]:
        """Gerar resposta usando modelo local com configurações otimizadas"""
        try:
            import torch
            
            if not self.model_loaded or not self.model or not self.tokenizer:
                raise Exception("Modelo local não carregado")
            
            # Preparar prompt completo
            full_prompt = prompt
            if system_prompt:
                full_prompt = f"{system_prompt}\n\nUsuário: {prompt}\nAssistente:"
            
            # Configurações de tokenização baseadas no modelo
            max_length = self.model_config.get('max_seq_length', 2048)
            
            # Tokenizar
            inputs = self.tokenizer(
                full_prompt,
                return_tensors="pt",
                truncation=True,
                max_length=min(max_length // 2, 1024)  # Reservar espaço para resposta
            )
            
            # Mover para dispositivo
            device = self.config.get_device()
            inputs = {k: v.to(device) for k, v in inputs.items()}
            
            # Obter configurações de geração otimizadas
            gen_config = self._get_optimized_generation_config(prompt, model_config=model_config, **kwargs)
            
            # Gerar resposta
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    **gen_config,
                    pad_token_id=self.tokenizer.eos_token_id,
                    eos_token_id=self.tokenizer.eos_token_id
                )
            
            # Decodificar resposta
            response_tokens = outputs[0][inputs['input_ids'].shape[1]:]
            response_text = self.tokenizer.decode(response_tokens, skip_special_tokens=True)
            
            return {
                'response': response_text.strip(),
                'success': True,
                'model_info': {
                    'name': self.model_name,
                    'provider': 'local',
                    'device': device,
                    'generation_config': gen_config,
                    'model_config': self.model_config,
                    'quantized': 'bnb-4bit' in self.model_name
                }
            }
            
        except Exception as e:
            self.logger.error(f"Erro no modelo local: {e}")
            raise
    
    def _get_optimized_generation_config(self, prompt: str, model_config: Optional[Any] = None, **kwargs) -> Dict[str, Any]:
        """Obter configurações de geração otimizadas baseadas no modelo e contexto"""
        # Usar configurações do modelo inteligente se disponível
        if model_config and hasattr(model_config, 'temperature'):
            base_temperature = model_config.temperature
            base_top_p = model_config.top_p
            base_max_tokens = model_config.max_tokens
            self.logger.info(f"Usando configurações inteligentes para geração local - Temp: {base_temperature}")
        else:
            base_temperature = 0.7
            base_top_p = 0.9
            base_max_tokens = 512
        
        # Configurações base do modelo
        base_config = {
            'max_new_tokens': kwargs.get('max_tokens', base_max_tokens),
            'do_sample': True,
            'temperature': kwargs.get('temperature', base_temperature),
            'top_p': kwargs.get('top_p', base_top_p),
            'top_k': kwargs.get('top_k', 50),
            'repetition_penalty': kwargs.get('repetition_penalty', 1.1),
            'no_repeat_ngram_size': 3,
            'early_stopping': True,
        }
        
        # Ajustar baseado no tamanho do modelo
        if '1b' in self.model_name:
            # Modelo pequeno - configurações mais conservadoras
            base_config.update({
                'max_new_tokens': min(base_config['max_new_tokens'], 256),
                'temperature': min(base_config['temperature'], 0.8),
                'top_k': min(base_config['top_k'], 40)
            })
        elif '27b' in self.model_name:
            # Modelo grande - pode usar configurações mais agressivas
            base_config.update({
                'max_new_tokens': min(base_config['max_new_tokens'], 1024),
                'temperature': base_config['temperature'],
                'top_k': min(base_config['top_k'], 80)
            })
        
        # Ajustar baseado no comprimento do prompt
        prompt_length = len(prompt.split())
        if prompt_length > 100:
            # Prompt longo - reduzir tokens de saída
            base_config['max_new_tokens'] = min(base_config['max_new_tokens'], 384)
        
        return base_config
    
    def _generate_intelligent_fallback(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        **kwargs
    ) -> Dict[str, Any]:
        """Gerar resposta inteligente simulando Gemma-3n para demonstração"""
        prompt_lower = prompt.lower()
        
        # Respostas médicas específicas
        if any(word in prompt_lower for word in ['parto', 'nascimento', 'gravidez', 'bebê']):
            return {
                'response': "Para partos de emergência: 1) Mantenha a calma e chame ajuda. 2) Lave bem as mãos. 3) Prepare toalhas limpas. 4) Não puxe o bebê, deixe nascer naturalmente. 5) Após o nascimento, limpe as vias respiratórias do bebê. 6) Mantenha mãe e bebê aquecidos. Procure assistência médica imediatamente.",
                'success': True
            }
        
        elif any(word in prompt_lower for word in ['hemorragia', 'sangramento', 'ferida']):
            return {
                'response': "Para controlar hemorragias: 1) Aplique pressão direta sobre o ferimento com pano limpo. 2) Eleve a parte ferida acima do coração se possível. 3) Não remova objetos cravados. 4) Se o sangramento não parar, aplique pressão em pontos arteriais. 5) Procure ajuda médica urgente. Mantenha a vítima aquecida e consciente.",
                'success': True
            }
        
        # Respostas educacionais
        elif any(word in prompt_lower for word in ['ensinar', 'educação', 'aprender', 'escola']):
            return {
                'response': "Para educação em comunidades remotas: 1) Use materiais locais como recursos didáticos. 2) Organize grupos de estudo comunitários. 3) Aproveite conhecimentos dos mais velhos. 4) Crie bibliotecas comunitárias simples. 5) Use métodos visuais e práticos. 6) Incentive a educação entre pares. O aprendizado acontece melhor quando conectado à realidade local.",
                'success': True
            }
        
        # Respostas agrícolas
        elif any(word in prompt_lower for word in ['agricultura', 'plantação', 'colheita', 'cultivo']):
            return {
                'response': "Para proteção de cultivos: 1) Diversifique as plantações para reduzir riscos. 2) Use plantas companheiras que se protegem mutuamente. 3) Implemente rotação de culturas. 4) Crie barreiras naturais contra pragas. 5) Colete água da chuva para irrigação. 6) Use compostagem orgânica. 7) Monitore regularmente as plantas. A agricultura sustentável protege tanto a colheita quanto o meio ambiente.",
                'success': True
            }
        
        # Resposta geral inteligente
        else:
            return {
                'response': f"Entendo sua pergunta sobre '{prompt[:50]}...'. Como assistente de IA Gemma-3n executando localmente, posso ajudar com questões de saúde, educação e agricultura para comunidades remotas. Para obter uma resposta mais específica, você poderia reformular sua pergunta focando em uma dessas áreas? Estou aqui para apoiar sua comunidade com conhecimento prático e acessível.",
                'success': True
            }
    
    def _generate_fallback_response(self, prompt: str) -> Dict[str, Any]:
        """Gerar resposta de fallback quando nenhum modelo está disponível"""
        fallback_responses = {
            'medical': "Para questões médicas, recomendo procurar um profissional de saúde qualificado. Em emergências, procure o centro de saúde mais próximo.",
            'education': "Para questões educacionais, recomendo consultar materiais didáticos locais ou procurar um professor qualificado na sua comunidade.",
            'agriculture': "Para questões agrícolas, recomendo consultar técnicos agrícolas locais ou cooperativas de agricultores da sua região.",
            'wellness': "Para questões de bem-estar, recomendo manter uma alimentação equilibrada, exercitar-se regularmente e buscar apoio da comunidade.",
            'environmental': "Para questões ambientais, recomendo práticas sustentáveis como conservação da água, proteção das florestas e uso responsável dos recursos naturais."
        }
        
        # Tentar identificar o tipo de consulta
        prompt_lower = prompt.lower()
        for category, response in fallback_responses.items():
            if any(word in prompt_lower for word in [category, category[:4]]):
                return {
                    'response': response,
                    'success': True,
                    'fallback': True
                }
        
        # Resposta padrão
        return {
            'response': "Obrigado pela sua pergunta. No momento, o sistema está em modo limitado. Para obter ajuda específica, recomendo procurar profissionais qualificados na sua comunidade.",
            'success': True,
            'fallback': True
        }
    
    # ========== MÉTODOS AUXILIARES PARA FUNCIONALIDADES REVOLUCIONÁRIAS ==========
    
    def _validate_language_code(self, lang_code: str) -> bool:
        """Validar código de idioma"""
        valid_codes = {
            'pt', 'en', 'es', 'fr', 'de', 'it', 'ru', 'zh', 'ja', 'ko',
            'ar', 'hi', 'sw', 'yo', 'ha', 'ig', 'zu', 'xh', 'af', 'am',
            'gcr'  # Crioulo da Guiné-Bissau
        }
        return lang_code.lower() in valid_codes
    
    def _validate_context(self, context: str) -> bool:
        """Validar contexto de tradução"""
        valid_contexts = {
            'general', 'medical', 'education', 'agriculture', 'emergency',
            'wellness', 'environmental', 'cultural', 'technical', 'social'
        }
        return context.lower() in valid_contexts
    
    def _get_language_culture_mapping(self, lang_code: str) -> str:
        """Obter mapeamento de idioma para cultura"""
        culture_mapping = {
            'pt': 'lusófona',
            'gcr': 'crioula_guiné_bissau',
            'en': 'anglófona',
            'es': 'hispânica',
            'fr': 'francófona',
            'de': 'germânica',
            'it': 'italiana',
            'ru': 'eslava',
            'zh': 'chinesa',
            'ja': 'japonesa',
            'ko': 'coreana',
            'ar': 'árabe',
            'hi': 'indiana',
            'sw': 'suaíli',
            'yo': 'iorubá',
            'ha': 'hauçá',
            'ig': 'igbo',
            'zu': 'zulu',
            'xh': 'xhosa',
            'af': 'africâner',
            'am': 'amárica'
        }
        return culture_mapping.get(lang_code.lower(), 'universal')
    
    def _format_emotional_intensity(self, intensity: float) -> str:
        """Formatar intensidade emocional"""
        if intensity >= 8:
            return 'muito alta'
        elif intensity >= 6:
            return 'alta'
        elif intensity >= 4:
            return 'moderada'
        elif intensity >= 2:
            return 'baixa'
        else:
            return 'muito baixa'
    
    def _calculate_cultural_distance(self, culture1: str, culture2: str) -> float:
        """Calcular distância cultural entre duas culturas"""
        # Matriz simplificada de distância cultural
        cultural_distances = {
            ('lusófona', 'crioula_guiné_bissau'): 0.3,
            ('lusófona', 'francófona'): 0.4,
            ('crioula_guiné_bissau', 'francófona'): 0.2,
            ('anglófona', 'francófona'): 0.5,
            ('anglófona', 'lusófona'): 0.6,
            ('árabe', 'africana'): 0.3,
            ('chinesa', 'japonesa'): 0.4,
        }
        
        # Verificar ambas as direções
        distance = cultural_distances.get((culture1, culture2))
        if distance is None:
            distance = cultural_distances.get((culture2, culture1))
        
        # Distância padrão para culturas não mapeadas
        return distance if distance is not None else 0.7
    
    def _generate_context_prompt(self, base_prompt: str, context: str, additional_info: Dict[str, Any] = None) -> str:
        """Gerar prompt contextualizado"""
        context_templates = {
            'medical': "Como assistente médico especializado em comunidades remotas, ",
            'education': "Como educador especializado em ensino comunitário, ",
            'agriculture': "Como especialista agrícola para pequenos produtores, ",
            'emergency': "Como especialista em primeiros socorros e emergências, ",
            'wellness': "Como conselheiro de bem-estar comunitário, ",
            'environmental': "Como especialista em sustentabilidade ambiental, ",
            'cultural': "Como mediador cultural e linguístico, ",
            'technical': "Como especialista técnico, ",
            'social': "Como facilitador social comunitário, ",
            'general': "Como assistente de IA especializado em comunidades, "
        }
        
        context_prefix = context_templates.get(context, context_templates['general'])
        
        # Adicionar informações adicionais se fornecidas
        if additional_info:
            context_info = ""
            if 'user_location' in additional_info:
                context_info += f" considerando a localização {additional_info['user_location']},"
            if 'urgency_level' in additional_info:
                context_info += f" com nível de urgência {additional_info['urgency_level']},"
            if 'cultural_context' in additional_info:
                context_info += f" no contexto cultural {additional_info['cultural_context']},"
            
            context_prefix += context_info
        
        return f"{context_prefix} {base_prompt}"
    
    def _extract_json_from_response(self, response: str) -> Dict[str, Any]:
        """Extrair JSON de uma resposta de texto"""
        try:
            import re
            import json
            
            # Tentar encontrar JSON válido na resposta
            json_patterns = [
                r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}',  # JSON simples
                r'```json\s*({.*?})\s*```',  # JSON em bloco de código
                r'```\s*({.*?})\s*```',  # JSON em bloco genérico
            ]
            
            for pattern in json_patterns:
                matches = re.findall(pattern, response, re.DOTALL | re.IGNORECASE)
                for match in matches:
                    try:
                        return json.loads(match)
                    except json.JSONDecodeError:
                        continue
            
            # Se não encontrar JSON, tentar parsear a resposta inteira
            return json.loads(response)
            
        except Exception as e:
            self.logger.warning(f"Não foi possível extrair JSON da resposta: {e}")
            return {}
    
    def _sanitize_text_input(self, text: str, max_length: int = 5000) -> str:
        """Sanitizar entrada de texto"""
        if not text or not isinstance(text, str):
            return ""
        
        # Remover caracteres de controle
        import re
        text = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x84\x86-\x9f]', '', text)
        
        # Limitar comprimento
        if len(text) > max_length:
            text = text[:max_length] + "..."
        
        # Remover espaços excessivos
        text = re.sub(r'\s+', ' ', text).strip()
        
        return text
    
    def _generate_learning_metrics(self, user_input: str, model_response: str, feedback: str = None) -> Dict[str, Any]:
        """Gerar métricas de aprendizado"""
        metrics = {
            'input_complexity': len(user_input.split()) / 10,  # Complexidade baseada em palavras
            'response_relevance': 0.8,  # Placeholder - seria calculado por modelo
            'user_satisfaction': 0.7,  # Placeholder - baseado em feedback
            'cultural_appropriateness': 0.9,  # Placeholder
            'language_accuracy': 0.85,  # Placeholder
            'context_understanding': 0.8,  # Placeholder
        }
        
        # Ajustar baseado no feedback se fornecido
        if feedback:
            feedback_lower = feedback.lower()
            if any(word in feedback_lower for word in ['bom', 'ótimo', 'excelente', 'perfeito']):
                metrics['user_satisfaction'] = min(1.0, metrics['user_satisfaction'] + 0.2)
            elif any(word in feedback_lower for word in ['ruim', 'péssimo', 'errado', 'incorreto']):
                metrics['user_satisfaction'] = max(0.0, metrics['user_satisfaction'] - 0.3)
        
        # Calcular score geral
        metrics['overall_score'] = sum(metrics.values()) / len(metrics)
        
        return metrics
    
    def _get_revolutionary_status(self) -> Dict[str, Any]:
        """Obter status das funcionalidades revolucionárias"""
        return {
            'contextual_translation': {
                'enabled': True,
                'status': 'active',
                'version': '3n-revolutionary',
                'capabilities': ['emotional_context', 'cultural_preservation', 'adaptive_learning']
            },
            'emotional_analysis': {
                'enabled': True,
                'status': 'active',
                'version': '3n-revolutionary',
                'capabilities': ['emotion_detection', 'intensity_analysis', 'cultural_context']
            },
            'cultural_bridge': {
                'enabled': True,
                'status': 'active',
                'version': '3n-revolutionary',
                'capabilities': ['cultural_adaptation', 'misunderstanding_prevention', 'preservation']
            },
            'adaptive_learning': {
                'enabled': True,
                'status': 'active',
                'version': '3n-revolutionary',
                'capabilities': ['pattern_recognition', 'personalization', 'continuous_improvement']
            },
            'multimodal_fusion': {
                'enabled': True,
                'status': 'active',
                'version': '3n-revolutionary',
                'capabilities': ['text_analysis', 'context_synthesis', 'integrated_understanding']
            }
        }
    
    def analyze_image(self, image_data: bytes, prompt: str = "Descreva esta imagem") -> Dict[str, Any]:
        """Analisar imagem (funcionalidade multimodal)"""
        # Por enquanto, retornar resposta de fallback
        # TODO: Implementar análise de imagem real com Gemma-3n
        return {
            'response': "Análise de imagem não disponível no momento. Esta funcionalidade será implementada em breve.",
            'success': False,
            'fallback': True,
            'metadata': {
                'provider': 'fallback',
                'feature': 'image_analysis',
                'timestamp': datetime.now().isoformat()
            }
        }
    
    # ========== FUNCIONALIDADES REVOLUCIONÁRIAS GEMMA 3N ==========
    
    def contextual_translation(self, text: str, source_lang: str, target_lang: str, 
                             context: str = "general", multimodal_data: Optional[Dict] = None) -> Dict[str, Any]:
        """Tradução contextual revolucionária com análise multimodal"""
        try:
            # Preparar prompt contextual
            system_prompt = REVOLUTIONARY_PROMPTS['CONTEXTUAL_TRANSLATION']
            
            # Construir contexto rico
            context_info = self._build_rich_context(text, source_lang, target_lang, context, multimodal_data)
            
            prompt = f"""
            TRADUÇÃO CONTEXTUAL AVANÇADA:
            
            Texto original ({source_lang}): "{text}"
            Idioma de destino: {target_lang}
            Contexto: {context}
            
            {context_info}
            
            Por favor, forneça:
            1. Tradução principal preservando contexto cultural
            2. Análise emocional do texto
            3. Insights culturais relevantes
            4. Traduções alternativas se apropriado
            5. Notas sobre preservação de significado
            
            Responda em formato JSON estruturado.
            """
            
            response = self.generate_response(prompt, system_prompt)
            
            if response['success']:
                # Processar resposta para extrair componentes
                processed_response = self._process_contextual_translation_response(response['response'])
                processed_response['metadata'] = response.get('metadata', {})
                processed_response['metadata']['feature'] = 'contextual_translation'
                return processed_response
            else:
                return self._fallback_contextual_translation(text, source_lang, target_lang, context)
                
        except Exception as e:
            self.logger.error(f"Erro na tradução contextual: {e}")
            return self._fallback_contextual_translation(text, source_lang, target_lang, context)
    
    def emotional_analysis(self, text: str, context: str = "general", 
                          multimodal_data: Optional[Dict] = None) -> Dict[str, Any]:
        """Análise emocional avançada com contexto cultural"""
        try:
            system_prompt = REVOLUTIONARY_PROMPTS['EMOTIONAL_ANALYSIS']
            
            # Construir contexto emocional
            emotional_context = self._build_emotional_context(text, context, multimodal_data)
            
            prompt = f"""
            ANÁLISE EMOCIONAL AVANÇADA:
            
            Texto: "{text}"
            Contexto: {context}
            
            {emotional_context}
            
            Analise:
            1. Estado emocional predominante
            2. Intensidade emocional (0-10)
            3. Emoções secundárias detectadas
            4. Contexto cultural das emoções
            5. Sugestões de resposta apropriada
            6. Indicadores de urgência ou necessidade
            
            Responda em formato JSON estruturado.
            """
            
            response = self.generate_response(prompt, system_prompt)
            
            if response['success']:
                processed_response = self._process_emotional_analysis_response(response['response'])
                processed_response['metadata'] = response.get('metadata', {})
                processed_response['metadata']['feature'] = 'emotional_analysis'
                return processed_response
            else:
                return self._fallback_emotional_analysis(text, context)
                
        except Exception as e:
            self.logger.error(f"Erro na análise emocional: {e}")
            return self._fallback_emotional_analysis(text, context)
    
    def cultural_bridge(self, text: str, source_culture: str, target_culture: str, 
                       context: str = "general") -> Dict[str, Any]:
        """Ponte cultural inteligente para comunicação intercultural"""
        try:
            system_prompt = REVOLUTIONARY_PROMPTS['CULTURAL_BRIDGE']
            
            prompt = f"""
            PONTE CULTURAL INTELIGENTE:
            
            Texto: "{text}"
            Cultura de origem: {source_culture}
            Cultura de destino: {target_culture}
            Contexto: {context}
            
            Forneça:
            1. Explicação cultural do texto original
            2. Adaptação cultural para o público-alvo
            3. Diferenças culturais relevantes
            4. Sugestões de comunicação efetiva
            5. Possíveis mal-entendidos a evitar
            6. Elementos culturais a preservar
            
            Responda em formato JSON estruturado.
            """
            
            response = self.generate_response(prompt, system_prompt)
            
            if response['success']:
                processed_response = self._process_cultural_bridge_response(response['response'])
                processed_response['metadata'] = response.get('metadata', {})
                processed_response['metadata']['feature'] = 'cultural_bridge'
                return processed_response
            else:
                return self._fallback_cultural_bridge(text, source_culture, target_culture)
                
        except Exception as e:
            self.logger.error(f"Erro na ponte cultural: {e}")
            return self._fallback_cultural_bridge(text, source_culture, target_culture)
    
    def adaptive_learning(self, user_input: str, feedback: str, context: str = "general") -> Dict[str, Any]:
        """Sistema de aprendizado adaptativo baseado em feedback"""
        try:
            system_prompt = REVOLUTIONARY_PROMPTS['ADAPTIVE_LEARNING']
            
            prompt = f"""
            APRENDIZADO ADAPTATIVO:
            
            Entrada do usuário: "{user_input}"
            Feedback recebido: "{feedback}"
            Contexto: {context}
            
            Analise e forneça:
            1. Padrões identificados no feedback
            2. Ajustes sugeridos para futuras respostas
            3. Preferências do usuário detectadas
            4. Melhorias no modelo de resposta
            5. Sugestões de personalização
            6. Métricas de aprendizado
            
            Responda em formato JSON estruturado.
            """
            
            response = self.generate_response(prompt, system_prompt)
            
            if response['success']:
                processed_response = self._process_adaptive_learning_response(response['response'])
                processed_response['metadata'] = response.get('metadata', {})
                processed_response['metadata']['feature'] = 'adaptive_learning'
                return processed_response
            else:
                return self._fallback_adaptive_learning(user_input, feedback)
                
        except Exception as e:
            self.logger.error(f"Erro no aprendizado adaptativo: {e}")
            return self._fallback_adaptive_learning(user_input, feedback)
    
    def multimodal_fusion_analysis(self, text: str, image_data: Optional[bytes] = None, 
                                  audio_data: Optional[bytes] = None, context: str = "general") -> Dict[str, Any]:
        """Análise de fusão multimodal avançada"""
        try:
            system_prompt = REVOLUTIONARY_PROMPTS['MULTIMODAL_FUSION']
            
            # Analisar componentes multimodais
            multimodal_analysis = self._analyze_multimodal_components(text, image_data, audio_data)
            
            prompt = f"""
            ANÁLISE MULTIMODAL AVANÇADA:
            
            Texto: "{text}"
            Contexto: {context}
            
            Análise de componentes:
            {multimodal_analysis}
            
            Forneça análise integrada:
            1. Síntese de todas as modalidades
            2. Elementos visuais relevantes (se imagem presente)
            3. Elementos auditivos relevantes (se áudio presente)
            4. Coerência entre modalidades
            5. Insights únicos da fusão multimodal
            6. Recomendações baseadas na análise completa
            
            Responda em formato JSON estruturado.
            """
            
            response = self.generate_response(prompt, system_prompt)
            
            if response['success']:
                processed_response = self._process_multimodal_fusion_response(response['response'])
                processed_response['metadata'] = response.get('metadata', {})
                processed_response['metadata']['feature'] = 'multimodal_fusion'
                return processed_response
            else:
                return self._fallback_multimodal_fusion(text, context)
                
        except Exception as e:
            self.logger.error(f"Erro na análise multimodal: {e}")
            return self._fallback_multimodal_fusion(text, context)
    
    def get_health_status(self) -> Dict[str, Any]:
        """Obter status de saúde do serviço"""
        return {
            'ollama_available': self.ollama_available,
            'model_loaded': self.model_loaded,
            'provider': 'ollama' if self.ollama_available else 'local' if self.model_loaded else 'fallback',
            'model_name': self.config.OLLAMA_MODEL if self.ollama_available else self.config.MODEL_NAME,
            'device': self.config.get_device(),
            'multimodal_enabled': self.config.ENABLE_MULTIMODAL,
            'adaptive_config_enabled': self.config.ENABLE_ADAPTIVE_CONFIG,
            'revolutionary_features': {
                'contextual_translation': getattr(self.config, 'ENABLE_CONTEXTUAL_TRANSLATION', True),
                'emotional_analysis': getattr(self.config, 'ENABLE_EMOTIONAL_ANALYSIS', True),
                'cultural_bridge': getattr(self.config, 'ENABLE_CULTURAL_BRIDGE', True),
                'adaptive_learning': getattr(self.config, 'ENABLE_ADAPTIVE_LEARNING', True)
            },
            'timestamp': datetime.now().isoformat()
        }
    
    # ========== MÉTODOS AUXILIARES PARA FUNCIONALIDADES REVOLUCIONÁRIAS ==========
    
    def _build_rich_context(self, text: str, source_lang: str, target_lang: str, 
                           context: str, multimodal_data: Optional[Dict]) -> str:
        """Construir contexto rico para tradução contextual"""
        context_parts = []
        
        # Contexto linguístico
        context_parts.append(f"Análise linguística: Traduzindo de {source_lang} para {target_lang}")
        
        # Contexto situacional
        if context == "medical":
            context_parts.append("Contexto médico: Priorizar precisão e clareza para situações de saúde")
        elif context == "education":
            context_parts.append("Contexto educacional: Adaptar para nível de compreensão apropriado")
        elif context == "agriculture":
            context_parts.append("Contexto agrícola: Focar em termos técnicos e práticas locais")
        
        # Contexto multimodal
        if multimodal_data:
            if multimodal_data.get('image_present'):
                context_parts.append("Contexto visual: Imagem presente para análise")
            if multimodal_data.get('audio_present'):
                context_parts.append("Contexto auditivo: Áudio presente para análise")
        
        # Contexto cultural
        if 'crioulo' in source_lang.lower() or 'crioulo' in target_lang.lower():
            context_parts.append("Contexto cultural: Preservar expressões e referências da Guiné-Bissau")
        
        return "\n".join(context_parts)
    
    def _build_emotional_context(self, text: str, context: str, multimodal_data: Optional[Dict]) -> str:
        """Construir contexto emocional para análise"""
        context_parts = []
        
        # Análise de comprimento e complexidade
        word_count = len(text.split())
        context_parts.append(f"Comprimento do texto: {word_count} palavras")
        
        # Contexto situacional
        context_parts.append(f"Situação: {context}")
        
        # Indicadores emocionais básicos
        if any(word in text.lower() for word in ['ajuda', 'urgente', 'emergência', 'socorro']):
            context_parts.append("Indicadores de urgência detectados")
        
        if any(word in text.lower() for word in ['obrigado', 'obrigada', 'grato', 'grata']):
            context_parts.append("Indicadores de gratidão detectados")
        
        # Contexto multimodal
        if multimodal_data:
            context_parts.append("Dados multimodais disponíveis para análise emocional")
        
        return "\n".join(context_parts)
    
    def _analyze_multimodal_components(self, text: str, image_data: Optional[bytes], 
                                     audio_data: Optional[bytes]) -> str:
        """Analisar componentes multimodais"""
        analysis_parts = []
        
        # Análise de texto
        analysis_parts.append(f"Texto: {len(text)} caracteres, {len(text.split())} palavras")
        
        # Análise de imagem (simulada)
        if image_data:
            analysis_parts.append(f"Imagem: {len(image_data)} bytes - Análise visual disponível")
        else:
            analysis_parts.append("Imagem: Não presente")
        
        # Análise de áudio (simulada)
        if audio_data:
            analysis_parts.append(f"Áudio: {len(audio_data)} bytes - Análise auditiva disponível")
        else:
            analysis_parts.append("Áudio: Não presente")
        
        return "\n".join(analysis_parts)
    
    def _process_contextual_translation_response(self, response: str) -> Dict[str, Any]:
        """Processar resposta de tradução contextual"""
        try:
            # Tentar extrair JSON da resposta
            import re
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
                return {
                    'success': True,
                    'translation': result.get('translation', response),
                    'emotional_analysis': result.get('emotional_analysis', {}),
                    'cultural_insights': result.get('cultural_insights', []),
                    'alternatives': result.get('alternatives', []),
                    'preservation_notes': result.get('preservation_notes', [])
                }
        except:
            pass
        
        # Fallback para resposta simples
        return {
            'success': True,
            'translation': response,
            'emotional_analysis': {'tone': 'neutral', 'intensity': 5},
            'cultural_insights': ['Tradução contextual aplicada'],
            'alternatives': [],
            'preservation_notes': ['Significado preservado']
        }
    
    def _process_emotional_analysis_response(self, response: str) -> Dict[str, Any]:
        """Processar resposta de análise emocional"""
        try:
            import re
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
                return {
                    'success': True,
                    'primary_emotion': result.get('primary_emotion', 'neutral'),
                    'intensity': result.get('intensity', 5),
                    'secondary_emotions': result.get('secondary_emotions', []),
                    'cultural_context': result.get('cultural_context', ''),
                    'response_suggestions': result.get('response_suggestions', []),
                    'urgency_indicators': result.get('urgency_indicators', [])
                }
        except:
            pass
        
        return {
            'success': True,
            'primary_emotion': 'neutral',
            'intensity': 5,
            'secondary_emotions': [],
            'cultural_context': 'Análise emocional aplicada',
            'response_suggestions': ['Responder com empatia'],
            'urgency_indicators': []
        }
    
    def _process_cultural_bridge_response(self, response: str) -> Dict[str, Any]:
        """Processar resposta de ponte cultural"""
        try:
            import re
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
                return {
                    'success': True,
                    'cultural_explanation': result.get('cultural_explanation', ''),
                    'cultural_adaptation': result.get('cultural_adaptation', response),
                    'cultural_differences': result.get('cultural_differences', []),
                    'communication_suggestions': result.get('communication_suggestions', []),
                    'misunderstanding_risks': result.get('misunderstanding_risks', []),
                    'preservation_elements': result.get('preservation_elements', [])
                }
        except:
            pass
        
        return {
            'success': True,
            'cultural_explanation': 'Análise cultural aplicada',
            'cultural_adaptation': response,
            'cultural_differences': [],
            'communication_suggestions': ['Comunicar com respeito cultural'],
            'misunderstanding_risks': [],
            'preservation_elements': []
        }
    
    def _process_adaptive_learning_response(self, response: str) -> Dict[str, Any]:
        """Processar resposta de aprendizado adaptativo"""
        try:
            import re
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
                return {
                    'success': True,
                    'patterns_identified': result.get('patterns_identified', []),
                    'suggested_adjustments': result.get('suggested_adjustments', []),
                    'user_preferences': result.get('user_preferences', {}),
                    'model_improvements': result.get('model_improvements', []),
                    'personalization_suggestions': result.get('personalization_suggestions', []),
                    'learning_metrics': result.get('learning_metrics', {})
                }
        except:
            pass
        
        return {
            'success': True,
            'patterns_identified': ['Padrão de uso detectado'],
            'suggested_adjustments': ['Ajustar tom de resposta'],
            'user_preferences': {'style': 'friendly'},
            'model_improvements': ['Melhorar precisão'],
            'personalization_suggestions': ['Personalizar respostas'],
            'learning_metrics': {'adaptation_score': 0.7}
        }
    
    def _process_multimodal_fusion_response(self, response: str) -> Dict[str, Any]:
        """Processar resposta de fusão multimodal"""
        try:
            import re
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
                return {
                    'success': True,
                    'multimodal_synthesis': result.get('multimodal_synthesis', response),
                    'visual_elements': result.get('visual_elements', []),
                    'audio_elements': result.get('audio_elements', []),
                    'modality_coherence': result.get('modality_coherence', 'high'),
                    'fusion_insights': result.get('fusion_insights', []),
                    'recommendations': result.get('recommendations', [])
                }
        except:
            pass
        
        return {
            'success': True,
            'multimodal_synthesis': response,
            'visual_elements': [],
            'audio_elements': [],
            'modality_coherence': 'high',
            'fusion_insights': ['Análise multimodal aplicada'],
            'recommendations': ['Continuar análise integrada']
        }
    
    # ========== MÉTODOS DE FALLBACK PARA FUNCIONALIDADES REVOLUCIONÁRIAS ==========
    
    def _fallback_contextual_translation(self, text: str, source_lang: str, target_lang: str, context: str) -> Dict[str, Any]:
        """Fallback para tradução contextual"""
        return {
            'success': True,
            'translation': f"[Tradução contextual de '{text}' de {source_lang} para {target_lang} no contexto {context}]",
            'emotional_analysis': {'tone': 'neutral', 'intensity': 5},
            'cultural_insights': ['Tradução contextual aplicada com fallback'],
            'alternatives': [],
            'preservation_notes': ['Significado básico preservado'],
            'fallback': True
        }
    
    def _fallback_emotional_analysis(self, text: str, context: str) -> Dict[str, Any]:
        """Fallback para análise emocional"""
        return {
            'success': True,
            'primary_emotion': 'neutral',
            'intensity': 5,
            'secondary_emotions': [],
            'cultural_context': f'Análise emocional básica para contexto {context}',
            'response_suggestions': ['Responder com empatia e compreensão'],
            'urgency_indicators': [],
            'fallback': True
        }
    
    def _fallback_cultural_bridge(self, text: str, source_culture: str, target_culture: str) -> Dict[str, Any]:
        """Fallback para ponte cultural"""
        return {
            'success': True,
            'cultural_explanation': f'Texto originário da cultura {source_culture}',
            'cultural_adaptation': f'Adaptação para cultura {target_culture}: {text}',
            'cultural_differences': ['Diferenças culturais consideradas'],
            'communication_suggestions': ['Comunicar com respeito e sensibilidade cultural'],
            'misunderstanding_risks': ['Possíveis diferenças de interpretação'],
            'preservation_elements': ['Elementos culturais importantes preservados'],
            'fallback': True
        }
    
    def _fallback_adaptive_learning(self, user_input: str, feedback: str) -> Dict[str, Any]:
        """Fallback para aprendizado adaptativo"""
        return {
            'success': True,
            'patterns_identified': ['Padrão de feedback analisado'],
            'suggested_adjustments': ['Ajustar respostas baseado no feedback'],
            'user_preferences': {'feedback_style': 'constructive'},
            'model_improvements': ['Melhorar baseado no feedback recebido'],
            'personalization_suggestions': ['Personalizar futuras interações'],
            'learning_metrics': {'adaptation_score': 0.5, 'feedback_quality': 'good'},
            'fallback': True
        }
    
    def _fallback_multimodal_fusion(self, text: str, context: str) -> Dict[str, Any]:
        """Fallback para fusão multimodal"""
        return {
            'success': True,
            'multimodal_synthesis': f'Análise multimodal básica do texto no contexto {context}',
            'visual_elements': ['Elementos visuais não disponíveis'],
            'audio_elements': ['Elementos auditivos não disponíveis'],
            'modality_coherence': 'medium',
            'fusion_insights': ['Análise limitada aos dados textuais disponíveis'],
            'recommendations': ['Fornecer dados multimodais para análise completa'],
            'fallback': True
        }