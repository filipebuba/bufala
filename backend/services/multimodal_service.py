"""
Serviço Multimodal para Gemma 3n
Implementa funcionalidades de texto, imagem, áudio e vídeo conforme documentação oficial
"""

import os
import logging
import base64
import tempfile
import torch
from PIL import Image
from transformers import AutoProcessor, AutoModelForImageTextToText, pipeline
from io import BytesIO
import requests
from typing import Dict, List, Any, Union, Optional

from config.settings import BackendConfig

logger = logging.getLogger(__name__)

class MultimodalService:
    """Serviço para processamento multimodal com Gemma 3n"""
    
    def __init__(self, gemma_service):
        self.gemma_service = gemma_service
        self.processor = None
        self.model = None
        self.image_text_pipeline = None
        self.initialized = False
        
        self._initialize_multimodal()
    
    def _initialize_multimodal(self):
        """Inicializar componentes multimodais de forma otimizada"""
        try:
            logger.info("🎨 Inicializando serviços multimodais Gemma 3n (modo otimizado)...")
            
            # Verificar se o serviço principal foi inicializado
            if not self.gemma_service.is_initialized:
                logger.warning("⚠️ Serviço Gemma principal não inicializado, usando modo fallback multimodal")
                self.initialized = False
                return False
            
            # Verificar se o modelo principal já tem processor (para reutilizar)
            if hasattr(self.gemma_service, 'processor') and self.gemma_service.processor:
                logger.info("♻️ Reutilizando processor do serviço principal")
                self.processor = self.gemma_service.processor
                
            # Verificar se já tem modelo multimodal (para reutilizar)
            if hasattr(self.gemma_service, 'chat_model') and self.gemma_service.chat_model:
                logger.info("♻️ Reutilizando modelo multimodal do serviço principal")
                self.model = self.gemma_service.chat_model
                
            # Verificar se já tem pipeline (para reutilizar)
            if hasattr(self.gemma_service, 'pipeline') and self.gemma_service.pipeline:
                logger.info("♻️ Reutilizando pipeline do serviço principal")
                self.image_text_pipeline = self.gemma_service.pipeline
            
            # Se conseguiu reutilizar componentes, marcar como inicializado
            if self.processor or self.model or self.image_text_pipeline:
                self.initialized = True
                logger.info("🎯 Serviços multimodais inicializados (modo reutilização)!")
                return True
            else:
                logger.warning("⚠️ Nenhum componente multimodal disponível para reutilização")
                self.initialized = False
                return False
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização multimodal: {e}")
            self.initialized = False
            return False
    
    def analyze_image(self, image_data: Union[str, bytes], prompt: str = "Descreva esta imagem em detalhes.", language: str = "pt-BR") -> Dict[str, Any]:
        """
        Analisar imagem usando Gemma 3n
        Baseado na documentação oficial: image-text-to-text
        """
        try:
            if not self.initialized:
                return self._fallback_image_response(prompt, language)
            
            # Processar imagem
            image = self._process_image_input(image_data)
            if not image:
                return {"error": "Falha ao processar imagem"}
            
            # MÉTODO 1: Pipeline API (recomendado)
            if self.image_text_pipeline:
                response = self._analyze_with_pipeline(image, prompt, language)
                if response:
                    return response
            
            # MÉTODO 2: Chat Template com multimodal
            if self.processor and self.model:
                response = self._analyze_with_chat_template(image, prompt, language)
                if response:
                    return response
            
            # Fallback
            return self._fallback_image_response(prompt, language)
            
        except Exception as e:
            logger.error(f"❌ Erro na análise de imagem: {e}")
            return {"error": f"Erro na análise: {str(e)}"}
    
    def _analyze_with_pipeline(self, image: Image.Image, prompt: str, language: str) -> Optional[Dict[str, Any]]:
        """Analisar imagem usando Pipeline API"""
        try:
            # Usar format de mensagens conforme documentação
            messages = [
                {
                    "role": "system",
                    "content": [{"type": "text", "text": "Você é um assistente especializado em análise de imagens. Responda em português brasileiro."}]
                },
                {
                    "role": "user",
                    "content": [
                        {"type": "image", "image": image},
                        {"type": "text", "text": prompt}
                    ]
                }
            ]
            
            output = self.image_text_pipeline(
                text=messages, 
                max_new_tokens=300,
                do_sample=True,
                temperature=0.7
            )
            
            response_text = output[0]["generated_text"][-1]["content"]
            
            return {
                "success": True,
                "analysis": response_text,
                "method": "pipeline",
                "image_processed": True,
                "language": language
            }
            
        except Exception as e:
            logger.warning(f"⚠️ Pipeline de imagem falhou: {e}")
            return None
    
    def _analyze_with_chat_template(self, image: Image.Image, prompt: str, language: str) -> Optional[Dict[str, Any]]:
        """Analisar imagem usando Chat Template"""
        try:
            # Mensagens multimodais conforme documentação oficial
            messages = [
                {
                    "role": "system",
                    "content": [{"type": "text", "text": "Você é um assistente especializado em análise de imagens. Responda em português brasileiro."}]
                },
                {
                    "role": "user",
                    "content": [
                        {"type": "image", "image": image},
                        {"type": "text", "text": prompt}
                    ]
                }
            ]
            
            inputs = self.processor.apply_chat_template(
                messages,
                add_generation_prompt=True,
                tokenize=True,
                return_dict=True,
                return_tensors="pt"
            ).to(self.model.device, dtype=BackendConfig.get_torch_dtype())
            
            input_len = inputs["input_ids"].shape[-1]
            
            with torch.inference_mode():
                generation = self.model.generate(
                    **inputs, 
                    max_new_tokens=300,
                    do_sample=True,
                    temperature=0.7,
                    top_p=0.9
                )
                
            decoded = self.processor.decode(
                generation[0][input_len:], 
                skip_special_tokens=True
            )
            
            return {
                "success": True,
                "analysis": decoded,
                "method": "chat_template",
                "image_processed": True,
                "language": language
            }
            
        except Exception as e:
            logger.warning(f"⚠️ Chat Template de imagem falhou: {e}")
            return None
    
    def process_audio(self, audio_data: Union[str, bytes], prompt: str = "Transcreva este áudio e complete o que foi dito.", language: str = "pt-BR") -> Dict[str, Any]:
        """
        Processar áudio usando Gemma 3n
        Baseado na documentação: audio-text-to-text
        """
        try:
            if not self.initialized:
                return self._fallback_audio_response(prompt, language)
            
            # Processar dados de áudio
            audio_path = self._process_audio_input(audio_data)
            if not audio_path:
                return {"error": "Falha ao processar áudio"}
            
            # Usar chat template para áudio conforme documentação
            messages = [
                {
                    "role": "user",
                    "content": [
                        {"type": "audio", "audio": audio_path},
                        {"type": "text", "text": prompt}
                    ]
                }
            ]
            
            inputs = self.processor.apply_chat_template(
                messages,
                add_generation_prompt=True,
                tokenize=True,
                return_dict=True,
                return_tensors="pt"
            ).to(self.model.device, dtype=BackendConfig.get_torch_dtype())
            
            input_len = inputs["input_ids"].shape[-1]
            
            with torch.inference_mode():
                generation = self.model.generate(
                    **inputs,
                    max_new_tokens=400,
                    do_sample=True,
                    temperature=0.7
                )
            
            decoded = self.processor.decode(
                generation[0][input_len:], 
                skip_special_tokens=True
            )
            
            # Limpar arquivo temporário
            if os.path.exists(audio_path):
                os.remove(audio_path)
            
            return {
                "success": True,
                "transcription": decoded,
                "method": "chat_template",
                "audio_processed": True,
                "language": language
            }
            
        except Exception as e:
            logger.error(f"❌ Erro no processamento de áudio: {e}")
            return {"error": f"Erro no áudio: {str(e)}"}
    
    def analyze_medical_image(self, image_data: Union[str, bytes], symptoms: str = "", language: str = "pt-BR") -> Dict[str, Any]:
        """Análise médica especializada de imagens"""
        medical_prompt = f"""
        Analise esta imagem médica cuidadosamente. 
        Sintomas relatados: {symptoms}
        
        Forneça:
        1. Observações visuais detalhadas
        2. Possíveis condições a considerar
        3. Recomendações para consulta médica
        
        IMPORTANTE: Esta é apenas uma análise preliminar. Sempre consulte um médico profissional.
        """
        
        result = self.analyze_image(image_data, medical_prompt, language)
        if result.get("success"):
            result["medical_analysis"] = True
            result["disclaimer"] = "Esta análise não substitui consulta médica profissional"
        
        return result
    
    def _process_image_input(self, image_data: Union[str, bytes]) -> Optional[Image.Image]:
        """Processar dados de entrada de imagem"""
        try:
            if isinstance(image_data, str):
                # Se for base64
                if image_data.startswith('data:image'):
                    image_data = image_data.split(',')[1]
                    image_bytes = base64.b64decode(image_data)
                    return Image.open(BytesIO(image_bytes))
                # Se for URL
                elif image_data.startswith('http'):
                    response = requests.get(image_data)
                    return Image.open(BytesIO(response.content))
                # Se for path
                elif os.path.exists(image_data):
                    return Image.open(image_data)
            
            elif isinstance(image_data, bytes):
                return Image.open(BytesIO(image_data))
            
            return None
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar imagem: {e}")
            return None
    
    def _process_audio_input(self, audio_data: Union[str, bytes]) -> Optional[str]:
        """Processar dados de entrada de áudio"""
        try:
            # Criar arquivo temporário
            temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.wav')
            
            if isinstance(audio_data, str):
                # Se for base64
                if audio_data.startswith('data:audio'):
                    audio_data = audio_data.split(',')[1]
                    audio_bytes = base64.b64decode(audio_data)
                    temp_file.write(audio_bytes)
                # Se for URL
                elif audio_data.startswith('http'):
                    response = requests.get(audio_data)
                    temp_file.write(response.content)
                # Se for path
                elif os.path.exists(audio_data):
                    with open(audio_data, 'rb') as f:
                        temp_file.write(f.read())
            
            elif isinstance(audio_data, bytes):
                temp_file.write(audio_data)
            
            temp_file.close()
            return temp_file.name
            
        except Exception as e:
            logger.error(f"❌ Erro ao processar áudio: {e}")
            return None
    
    def _fallback_image_response(self, prompt: str, language: str) -> Dict[str, Any]:
        """Resposta de fallback para análise de imagem"""
        return {
            "success": False,
            "analysis": "Serviço de análise de imagem temporariamente indisponível. O modelo Gemma 3n multimodal não está carregado.",
            "method": "fallback",
            "image_processed": False,
            "language": language
        }
    
    def _fallback_audio_response(self, prompt: str, language: str) -> Dict[str, Any]:
        """Resposta de fallback para processamento de áudio"""
        return {
            "success": False,
            "transcription": "Serviço de processamento de áudio temporariamente indisponível. O modelo Gemma 3n multimodal não está carregado.",
            "method": "fallback", 
            "audio_processed": False,
            "language": language
        }
    
    def get_capabilities(self) -> Dict[str, Any]:
        """Obter capacidades multimodais disponíveis (otimizado)"""
        try:
            # Verificação rápida sem operações custosas
            has_processor = hasattr(self, 'processor') and self.processor is not None
            has_model = hasattr(self, 'model') and self.model is not None  
            has_pipeline = hasattr(self, 'image_text_pipeline') and self.image_text_pipeline is not None
            
            return {
                "text_generation": True,  # Sempre disponível via serviço principal
                "image_analysis": self.initialized and (has_pipeline or (has_processor and has_model)),
                "audio_processing": self.initialized and has_processor and has_model,
                "video_processing": False,  # Implementar futuramente
                "supported_image_formats": ["JPEG", "PNG", "WEBP", "BMP"],
                "supported_audio_formats": ["WAV", "MP3", "M4A"],
                "max_image_size": "768x768",
                "max_audio_duration": "60 seconds",
                "context_length": "32K tokens",
                "initialized": self.initialized,
                "components_loaded": {
                    "processor": has_processor,
                    "model": has_model,
                    "pipeline": has_pipeline
                }
            }
        except Exception as e:
            logger.error(f"❌ Erro ao obter capacidades: {e}")
            # Retornar resposta de fallback mesmo com erro
            return {
                "text_generation": True,
                "image_analysis": False,
                "audio_processing": False,
                "video_processing": False,
                "supported_image_formats": [],
                "supported_audio_formats": [],
                "max_image_size": "N/A",
                "max_audio_duration": "N/A",
                "context_length": "N/A",
                "initialized": False,
                "error": str(e)
            }
