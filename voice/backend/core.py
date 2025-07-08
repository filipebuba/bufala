"""
VoiceGuide AI - Core Module
Assistente de navegação inclusiva usando Gemma 3n
"""

import torch
import cv2
import numpy as np
from PIL import Image
import speech_recognition as sr
import pyttsx3
import threading
import queue
import time
from typing import Optional, Dict, List, Tuple
from loguru import logger
from transformers import (
    pipeline, 
    AutoProcessor, 
    Gemma3nForConditionalGeneration,
    AutoTokenizer
)

class VoiceGuideAI:
    """Classe principal do assistente VoiceGuide AI"""
    
    def __init__(self, model_size: str = "2b", device: str = "auto"):
        """
        Inicializa o VoiceGuide AI
        
        Args:
            model_size: Tamanho do modelo ("2b" ou "4b")
            device: Dispositivo para execução ("auto", "cpu", "cuda")
        """
        self.model_size = model_size
        self.device = device
        self.model_id = f"google/gemma-3n-e{model_size}-it"
        
        logger.info(f"Inicializando VoiceGuide AI com modelo {self.model_id}")
        
        # Inicializar modelo Gemma 3n
        self._initialize_model()
        
        # Configurar componentes de áudio
        self._initialize_audio()
        
        # Estado do sistema
        self.is_active = False
        self.current_destination = None
        self.last_analysis_time = 0
        self.analysis_interval = 3  # segundos
        
        logger.success("VoiceGuide AI inicializado com sucesso!")
    
    def _initialize_model(self):
        """Inicializa o modelo Gemma 3n"""
        try:
            # Carregar modelo
            self.model = Gemma3nForConditionalGeneration.from_pretrained(
                self.model_id,
                device_map=self.device,
                torch_dtype=torch.bfloat16,
                trust_remote_code=True
            ).eval()
            
            # Carregar processador
            self.processor = AutoProcessor.from_pretrained(
                self.model_id,
                trust_remote_code=True
            )
            
            # Pipeline para processamento multimodal
            self.vision_pipe = pipeline(
                "image-text-to-text",
                model=self.model_id,
                device=0 if torch.cuda.is_available() else -1,
                torch_dtype=torch.bfloat16
            )
            
            logger.info("Modelo Gemma 3n carregado com sucesso")
            
        except Exception as e:
            logger.error(f"Erro ao carregar modelo: {e}")
            raise
    
    def _initialize_audio(self):
        """Inicializa componentes de áudio"""
        try:
            # Text-to-Speech
            self.tts_engine = pyttsx3.init()
            self.tts_engine.setProperty('rate', 150)  # Velocidade da fala
            self.tts_engine.setProperty('volume', 0.9)  # Volume
            
            # Speech Recognition
            self.speech_recognizer = sr.Recognizer()
            self.microphone = sr.Microphone()
            
            # Calibrar microfone
            with self.microphone as source:
                self.speech_recognizer.adjust_for_ambient_noise(source)
            
            logger.info("Componentes de áudio inicializados")
            
        except Exception as e:
            logger.warning(f"Erro ao inicializar áudio: {e}")
    
    def analyze_environment(self, image: Image.Image, context: str = "") -> str:
        """
        Analisa o ambiente usando visão computacional + Gemma 3n
        
        Args:
            image: Imagem PIL para análise
            context: Contexto adicional para análise
            
        Returns:
            Descrição do ambiente para navegação
        """
        try:
            base_prompt = """Você é um assistente de navegação para pessoas com deficiência visual. 
            Descreva o ambiente de forma clara e concisa, focando em:
            1. Obstáculos e perigos
            2. Caminhos livres
            3. Pontos de referência importantes
            4. Direções seguras para caminhar
            
            Seja específico sobre distâncias e posições (esquerda, direita, frente)."""
            
            if context:
                prompt = f"{base_prompt}\n\nContexto específico: {context}"
            else:
                prompt = base_prompt
            
            messages = [
                {
                    "role": "system",
                    "content": [{"type": "text", "text": prompt}]
                },
                {
                    "role": "user",
                    "content": [
                        {"type": "image", "image": image},
                        {"type": "text", "text": "Descreva este ambiente para navegação segura."}
                    ]
                }
            ]
            
            result = self.vision_pipe(text=messages, max_new_tokens=200)
            analysis = result[0]["generated_text"][-1]["content"]
            
            logger.debug(f"Análise do ambiente: {analysis[:100]}...")
            return analysis
            
        except Exception as e:
            logger.error(f"Erro na análise do ambiente: {e}")
            return "Não foi possível analisar o ambiente no momento."
    
    def generate_navigation_instructions(self, scene_description: str, destination: str) -> str:
        """
        Gera instruções de navegação personalizadas
        
        Args:
            scene_description: Descrição da cena atual
            destination: Destino desejado
            
        Returns:
            Instruções de navegação passo a passo
        """
        try:
            messages = [
                {
                    "role": "system",
                    "content": [{"type": "text", "text": """Gere instruções de navegação claras e seguras para uma pessoa com deficiência visual.
                    As instruções devem ser:
                    - Passo a passo
                    - Específicas sobre direções
                    - Alertas sobre obstáculos
                    - Fáceis de seguir por áudio"""}]
                },
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": f"""
                        Ambiente atual: {scene_description}
                        Destino: {destination}
                        
                        Forneça instruções de navegação seguras e detalhadas.
                        """}
                    ]
                }
            ]
            
            inputs = self.processor.apply_chat_template(
                messages,
                add_generation_prompt=True,
                tokenize=True,
                return_dict=True,
                return_tensors="pt",
            ).to(self.model.device, dtype=torch.bfloat16)
            
            input_len = inputs["input_ids"].shape[-1]
            
            with torch.inference_mode():
                generation = self.model.generate(
                    **inputs, 
                    max_new_tokens=150, 
                    do_sample=False,
                    temperature=0.7
                )
                generation = generation[0][input_len:]
            
            instructions = self.processor.decode(generation, skip_special_tokens=True)
            
            logger.debug(f"Instruções geradas: {instructions[:100]}...")
            return instructions
            
        except Exception as e:
            logger.error(f"Erro ao gerar instruções: {e}")
            return "Não foi possível gerar instruções no momento."
    
    def speak_text(self, text: str, priority: bool = False):
        """
        Converte texto em fala
        
        Args:
            text: Texto para falar
            priority: Se True, interrompe fala atual
        """
        try:
            if priority:
                self.tts_engine.stop()
            
            self.tts_engine.say(text)
            self.tts_engine.runAndWait()
            
        except Exception as e:
            logger.error(f"Erro na síntese de voz: {e}")
    
    def listen_for_command(self, timeout: int = 5) -> Optional[str]:
        """
        Escuta comando de voz do usuário
        
        Args:
            timeout: Tempo limite em segundos
            
        Returns:
            Comando reconhecido ou None
        """
        try:
            with self.microphone as source:
                logger.info("Escutando comando...")
                audio = self.speech_recognizer.listen(source, timeout=timeout)
            
            command = self.speech_recognizer.recognize_google(audio, language='pt-BR')
            logger.info(f"Comando reconhecido: {command}")
            return command.lower()
            
        except sr.WaitTimeoutError:
            logger.debug("Timeout na escuta")
            return None
        except sr.UnknownValueError:
            logger.debug("Não foi possível entender o áudio")
            return None
        except Exception as e:
            logger.error(f"Erro no reconhecimento de voz: {e}")
            return None
    
    def emergency_analysis(self, image: Image.Image) -> str:
        """
        Análise de emergência para identificar perigos imediatos
        
        Args:
            image: Imagem para análise
            
        Returns:
            Alerta de segurança
        """
        emergency_context = """MODO EMERGÊNCIA: Identifique rapidamente perigos imediatos 
        ou obstáculos que possam prejudicar uma pessoa com deficiência visual. 
        Priorize avisos de segurança."""
        
        return self.analyze_environment(image, emergency_context)
    
    def set_destination(self, destination: str):
        """Define o destino atual"""
        self.current_destination = destination
        logger.info(f"Destino definido: {destination}")
    
    def get_status(self) -> Dict:
        """Retorna status atual do sistema"""
        return {
            "active": self.is_active,
            "destination": self.current_destination,
            "model_size": self.model_size,
            "device": str(self.model.device) if hasattr(self.model, 'device') else "unknown"
        }

# Classe para funcionalidades avançadas
class AdvancedGemmaFeatures:
    """Funcionalidades avançadas específicas do Gemma 3n"""
    
    def __init__(self, voice_guide_ai: VoiceGuideAI):
        self.ai = voice_guide_ai
        
    def dynamic_model_switching(self, complexity_level: str) -> str:
        """
        Usa o recurso mix'n'match do Gemma 3n
        
        Args:
            complexity_level: "simple" ou "complex"
            
        Returns:
            Configuração do modelo utilizada
        """
        if complexity_level == "simple":
            # Para respostas rápidas, usar configuração otimizada
            self.ai.vision_pipe.model.config.max_new_tokens = 50
            return "Modo rápido ativado (otimizado para velocidade)"
        else:
            # Para análises complexas, usar configuração completa
            self.ai.vision_pipe.model.config.max_new_tokens = 200
            return "Modo completo ativado (análise detalhada)"
    
    def offline_multilingual_support(self, language: str = "pt") -> str:
        """
        Suporte multilíngue offline
        
        Args:
            language: Código do idioma ("pt", "en", "es", etc.)
            
        Returns:
            Prompt no idioma especificado
        """
        language_prompts = {
            "pt": "Descreva o ambiente para navegação em português claro e objetivo",
            "en": "Describe the environment for navigation in clear and objective English",
            "es": "Describe el entorno para navegación en español claro y objetivo",
            "fr": "Décrivez l'environnement pour la navigation en français clair et objectif",
            "de": "Beschreiben Sie die Umgebung für die Navigation in klarem und objektivem Deutsch"
        }
        return language_prompts.get(language, language_prompts["pt"])
    
    def context_aware_analysis(self, image: Image.Image, user_profile: Dict) -> str:
        """
        Análise contextual baseada no perfil do usuário
        
        Args:
            image: Imagem para análise
            user_profile: Perfil com preferências e necessidades
            
        Returns:
            Análise personalizada
        """
        mobility_level = user_profile.get("mobility_level", "standard")
        preferences = user_profile.get("preferences", [])
        
        context = f"""
        Perfil do usuário:
        - Nível de mobilidade: {mobility_level}
        - Preferências: {', '.join(preferences)}
        
        Adapte a análise para estas necessidades específicas.
        """
        
        return self.ai.analyze_environment(image, context)
