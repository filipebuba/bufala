#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Serviço Gemma para o Bu Fala Backend
Hackathon Gemma 3n

Este serviço gerencia a interação com o modelo Gemma-3n,
com suporte a Ollama e fallback para modelo local.
"""

import logging
import requests
import json
from typing import Dict, Any, Optional, Union, List
from datetime import datetime

from config.settings import BackendConfig, SystemPrompts

class GemmaService:
    """Serviço para interação com o modelo Gemma-3n"""
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.config = BackendConfig
        self.ollama_available = False
        self.model_loaded = False
        self.model = None
        self.tokenizer = None
        
        # Tentar inicializar Ollama primeiro
        if self.config.USE_OLLAMA:
            self._check_ollama_availability()
        
        # Se Ollama não estiver disponível, tentar carregar modelo local
        if not self.ollama_available:
            self._load_local_model()
    
    def _check_ollama_availability(self) -> bool:
        """Verificar se Ollama está disponível"""
        try:
            response = requests.get(
                f"{self.config.OLLAMA_HOST}/api/tags",
                timeout=5
            )
            if response.status_code == 200:
                models = response.json().get('models', [])
                model_names = [model['name'] for model in models]
                
                if self.config.OLLAMA_MODEL in model_names:
                    self.ollama_available = True
                    self.logger.info(f"Ollama disponível com modelo {self.config.OLLAMA_MODEL}")
                    return True
                else:
                    self.logger.warning(f"Modelo {self.config.OLLAMA_MODEL} não encontrado no Ollama")
                    self.logger.info(f"Modelos disponíveis: {model_names}")
            
        except Exception as e:
            self.logger.warning(f"Ollama não disponível: {e}")
        
        self.ollama_available = False
        return False
    
    def _load_local_model(self):
        """Carregar modelo Gemma-3n local"""
        try:
            self.logger.info("Tentando carregar modelo Gemma-3n local...")
            
            # Importar bibliotecas necessárias
            from transformers import AutoTokenizer, AutoModelForCausalLM
            import torch
            
            # Configurar dispositivo
            device = self.config.get_device()
            torch_dtype = self.config.get_torch_dtype()
            
            self.logger.info(f"Usando dispositivo: {device}")
            self.logger.info(f"Usando dtype: {torch_dtype}")
            
            # Carregar tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(
                self.config.MODEL_PATH,
                trust_remote_code=True
            )
            
            # Configurar pad token se necessário
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            # Carregar modelo
            model_kwargs = {
                'torch_dtype': torch_dtype,
                'trust_remote_code': True,
                'low_cpu_mem_usage': True
            }
            
            if device == "cuda":
                model_kwargs['device_map'] = "auto"
            
            self.model = AutoModelForCausalLM.from_pretrained(
                self.config.MODEL_PATH,
                **model_kwargs
            )
            
            if device == "cpu":
                self.model = self.model.to(device)
            
            # Otimizações para produção
            if self.config.ENABLE_OPTIMIZATIONS:
                self.model.eval()
                if hasattr(torch, 'compile'):
                    try:
                        self.model = torch.compile(self.model)
                        self.logger.info("Modelo compilado com torch.compile")
                    except Exception as e:
                        self.logger.warning(f"Falha ao compilar modelo: {e}")
            
            self.model_loaded = True
            self.logger.info("Modelo Gemma-3n carregado com sucesso")
            
        except Exception as e:
            self.logger.error(f"Erro ao carregar modelo local: {e}")
            self.model_loaded = False
    
    def generate_response(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        **kwargs
    ) -> Dict[str, Any]:
        """Gerar resposta usando Ollama ou modelo local"""
        start_time = datetime.now()
        
        try:
            # Tentar Ollama primeiro
            if self.ollama_available:
                response = self._generate_with_ollama(prompt, system_prompt, **kwargs)
            elif self.model_loaded:
                response = self._generate_with_local_model(prompt, system_prompt, **kwargs)
            else:
                # Fallback para resposta padrão
                response = self._generate_fallback_response(prompt)
            
            # Adicionar metadados
            response['metadata'] = {
                'provider': 'ollama' if self.ollama_available else 'local' if self.model_loaded else 'fallback',
                'model': self.config.OLLAMA_MODEL if self.ollama_available else self.config.MODEL_NAME,
                'generation_time': (datetime.now() - start_time).total_seconds(),
                'timestamp': datetime.now().isoformat()
            }
            
            return response
            
        except Exception as e:
            self.logger.error(f"Erro na geração: {e}")
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
        """Gerar resposta usando Ollama"""
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
            
            # Fazer requisição
            response = requests.post(
                f"{self.config.OLLAMA_HOST}/api/chat",
                json=payload,
                timeout=self.config.OLLAMA_TIMEOUT
            )
            
            if response.status_code == 200:
                result = response.json()
                return {
                    'response': result['message']['content'],
                    'success': True
                }
            else:
                raise Exception(f"Ollama retornou status {response.status_code}")
                
        except Exception as e:
            self.logger.error(f"Erro no Ollama: {e}")
            raise
    
    def _generate_with_local_model(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        **kwargs
    ) -> Dict[str, Any]:
        """Gerar resposta usando modelo local"""
        try:
            import torch
            
            # Preparar prompt completo
            full_prompt = prompt
            if system_prompt:
                full_prompt = f"{system_prompt}\n\nUsuário: {prompt}\nAssistente:"
            
            # Tokenizar
            inputs = self.tokenizer(
                full_prompt,
                return_tensors="pt",
                truncation=True,
                max_length=self.config.MAX_INPUT_LENGTH
            )
            
            # Mover para dispositivo
            device = self.config.get_device()
            inputs = {k: v.to(device) for k, v in inputs.items()}
            
            # Obter configurações de geração
            gen_config = self.config.get_generation_config(prompt)
            gen_config.update(kwargs)
            
            # Gerar resposta
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    **gen_config,
                    pad_token_id=self.tokenizer.eos_token_id
                )
            
            # Decodificar resposta
            response_tokens = outputs[0][inputs['input_ids'].shape[1]:]
            response_text = self.tokenizer.decode(response_tokens, skip_special_tokens=True)
            
            return {
                'response': response_text.strip(),
                'success': True
            }
            
        except Exception as e:
            self.logger.error(f"Erro no modelo local: {e}")
            raise
    
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