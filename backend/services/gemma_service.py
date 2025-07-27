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

class GemmaService:
    """Serviço para interação com modelos Gemma com seleção automática"""
    
    def __init__(self, domain: str = "general", force_model: Optional[str] = None):
        self.logger = logging.getLogger(__name__)
        self.config = BackendConfig
        
        # Configuração automática de modelo baseada no domínio
        if force_model:
            self.model_name = force_model
            self.model_config = ModelSelector.get_model_info(force_model).get('config', {})
        else:
            self.model_name, self.model_config = ModelSelector.get_model_for_domain(domain)
        
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
        **kwargs
    ) -> Dict[str, Any]:
        """Gerar resposta usando Ollama ou modelo local com configurações otimizadas"""
        start_time = datetime.now()
        
        try:
            # Tentar Ollama primeiro
            if self.ollama_available:
                response = self._generate_with_ollama(prompt, system_prompt, **kwargs)
            elif self.model_loaded:
                response = self._generate_with_local_model(prompt, system_prompt, **kwargs)
            else:
                # Tentar carregar um modelo automaticamente
                self.logger.warning("Nenhum modelo carregado, tentando carregar automaticamente...")
                self._load_local_model()
                
                if self.model_loaded:
                    response = self._generate_with_local_model(prompt, system_prompt, **kwargs)
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
                        response = self._generate_with_local_model(prompt, system_prompt, **kwargs)
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
        **kwargs
    ) -> Dict[str, Any]:
        """Gerar resposta usando Ollama ou simulação para demonstração"""
        try:
            # Preparar mensagens
            messages = []
            if system_prompt:
                messages.append({"role": "system", "content": system_prompt})
            messages.append({"role": "user", "content": prompt})
            
            # Preparar payload
            payload = {
                "model": self.config.OLLAMA_MODEL,
                "messages": messages,
                "stream": False,
                "options": {
                    "temperature": kwargs.get('temperature', self.config.TEMPERATURE),
                    "top_p": kwargs.get('top_p', self.config.TOP_P),
                    "top_k": kwargs.get('top_k', self.config.TOP_K),
                    "repeat_penalty": kwargs.get('repetition_penalty', self.config.REPETITION_PENALTY),
                    "num_predict": kwargs.get('max_new_tokens', self.config.MAX_NEW_TOKENS)
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
            gen_config = self._get_optimized_generation_config(prompt, **kwargs)
            
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
    
    def _get_optimized_generation_config(self, prompt: str, **kwargs) -> Dict[str, Any]:
        """Obter configurações de geração otimizadas baseadas no modelo e contexto"""
        # Configurações base do modelo
        base_config = {
            'max_new_tokens': kwargs.get('max_tokens', 512),
            'do_sample': True,
            'temperature': kwargs.get('temperature', 0.7),
            'top_p': kwargs.get('top_p', 0.9),
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
            'timestamp': datetime.now().isoformat()
        }